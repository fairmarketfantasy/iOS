//
//  FFPredictHistoryController.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/28/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFPredictHistoryController.h"
#import "FFNavigationBarItemView.h"
#import <FlatUIKit.h>
#import "FFPredictHistoryTable.h"
#import "FFPredictHistoryCell.h"
#import "FFPredictIndividualCell.h"
#import "FFPredictHeader.h"
#import "FFRosterTableHeader.h"
#import "FFPredictionsSelector.h"
#import "FFStyle.h"
#import "FFPredictRosterPagerController.h"
// model
#import "FFPredictionSet.h"
#import "FFIndividualPrediction.h"
#import "FFRosterPrediction.h"
#import "FFMarket.h"

@interface FFPredictHistoryController () <UITableViewDataSource, UITableViewDelegate,
FFPredictionsProtocol, SBDataObjectResultSetDelegate, FFPredictHistoryProtocol>

@property(nonatomic, assign) FFPredictionsType predictionType;
@property(nonatomic, assign) FFRosterPredictionType rosterPredictionType;
@property(nonatomic) UIButton* typeButton;
@property(nonatomic) FFPredictHistoryTable* tableView;
@property(nonatomic) FFPredictionsSelector* typeSelector;
// model
@property(nonatomic) FFPredictionSet* individualPredictions;
@property(nonatomic) FFPredictionSet* rosterPredictions;

@end

@implementation FFPredictHistoryController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.predictionType = FFPredictionsTypeRoster;
    self.rosterPredictionType = FFRosterPredictionTypeSubmitted;
    self.typeSelector = FFPredictionsSelector.new;
    self.typeSelector.delegate = self;
    [self.view addSubview:self.typeSelector];
    // right bar item
    self.typeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.typeButton.frame = CGRectMake(0.f, 0.f, 200.f, 44.f);
    [self.typeButton setBackgroundImage:[UIImage imageNamed:@"button_normal"]
                               forState:UIControlStateNormal];
    [self.typeButton setBackgroundImage:[UIImage imageNamed:@"button_pressed"]
                               forState:UIControlStateHighlighted];
    self.typeButton.titleLabel.font = [FFStyle blockFont:19.f];
    self.typeButton.imageEdgeInsets = UIEdgeInsetsMake(0.f, self.typeButton.frame.size.width - 37.f, 0.f, 0.f);
    self.typeButton.titleEdgeInsets = UIEdgeInsetsMake(0.f, 0.f, 0.f, 37.f);
    [self.typeButton addTarget:self
                        action:@selector(showOrHideTypeSelectorIfNeeded)
              forControlEvents:UIControlEventTouchUpInside];
    self.typeButton.contentMode = UIViewContentModeScaleAspectFit;
    // table view
    self.tableView = [[FFPredictHistoryTable alloc] initWithFrame:self.view.bounds];
    self.tableView.historyDelegate = self;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.view bringSubviewToFront:self.typeSelector];
    // title
    self.navigationItem.titleView = self.typeButton;
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    self.individualPredictions = [FFPredictionSet.alloc initWithDataObjectClass:[FFIndividualPrediction class]
                                                                        session:self.session authorized:YES];
    self.individualPredictions.delegate = self;
    self.rosterPredictions = [FFPredictionSet.alloc initWithDataObjectClass:[FFRosterPrediction class]
                                                                    session:self.session authorized:YES];
    self.rosterPredictions.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self hideTypeSelector];
    [self refresh];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self hideTypeSelector];
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue
                 sender:(id)sender
{
    [super prepareForSegue:segue
                    sender:sender];
    if ([segue.identifier isEqualToString:@"GotoPredictRoster"]) {
        FFPredictRosterPagerController* vc = segue.destinationViewController;
        vc.roster = (FFRosterPrediction*)sender;
    }
}

#pragma mark - FFPredictionsProtocol

- (void)predictionsTypeSelected:(FFPredictionsType)type
{
    self.predictionType = type;
    [self refresh];
    [self showOrHideTypeSelectorIfNeeded];
}

#pragma mark - button actions

- (void)showOrHideTypeSelectorIfNeeded
{
    if (!self.typeSelector.userInteractionEnabled) {
        [self showTypeSelector];
    } else {
        [self hideTypeSelector];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView
 numberOfRowsInSection:(NSInteger)section
{
    switch (self.predictionType) {
        case FFPredictionsTypeIndividual:
            return self.individualPredictions.allObjects.count;
        case FFPredictionsTypeRoster:
            return self.rosterPredictions.allObjects.count;
        default:
            return 0;
    }
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (self.predictionType) {
        case FFPredictionsTypeIndividual:
        {
            FFPredictIndividualCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PredictIndividualCell"
                                                                            forIndexPath:indexPath];
            if (self.individualPredictions.allObjects.count > indexPath.row) {
                FFIndividualPrediction* prediction = self.individualPredictions.allObjects[indexPath.row];
                cell.nameLabel.text = prediction.playerName;
                cell.teamLabel.text = prediction.marketName;
                cell.dayLabel.text = [FFStyle.dayFormatter stringFromDate:prediction.gameDay];
                cell.ptLabel.text = prediction.predictThat;
                if (prediction.eventPredictions.count > 0) {
                    NSDictionary* eventPrediction = prediction.eventPredictions.firstObject;
                    if (eventPrediction) {
                        cell.predictLabel.text = [NSString stringWithFormat:@"%@: %@ %@",
                                                  [eventPrediction[@"diff"] isEqualToString:@"less"]
                                                  ? @"Under": @"Over", // TODO: refactor it and move to model
                                                  eventPrediction[@"value"],
                                                  eventPrediction[@"event_type"]];
                    }
                }
                cell.timeLabel.text = [FFStyle.timeFormatter stringFromDate:prediction.gameTime];
                cell.awaidLabel.text = prediction.award;
            }
            return cell;
        }
            break;
        case FFPredictionsTypeRoster:
        {
            FFPredictHistoryCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PredictCell"
                                                                         forIndexPath:indexPath];
            if (self.rosterPredictions.allObjects.count > indexPath.row) {
                __block FFRosterPrediction* prediction = self.rosterPredictions.allObjects[indexPath.row];
                @weakify(self)
                [cell.rosterButton setAction:kUIButtonBlockTouchUpInside
                                   withBlock:^{
                                       @strongify(self)
                                       [self performSegueWithIdentifier:@"GotoPredictRoster"
                                                                 sender:prediction]; // TODO: refactode it (?)
                                   }];
#warning CHECK fields!
                cell.nameLabel.text = prediction.ownerName;
                cell.teamLabel.text = prediction.market.name;
                cell.dayLabel.text = [FFStyle.dayFormatter stringFromDate:prediction.startedAt];
                cell.stateLabel.text = prediction.state;
                cell.pointsLabel.text = [NSString stringWithFormat:@"%i", prediction.bonusPoints.integerValue];
                cell.paidLabel.text = prediction.paidAt ? [FFStyle.dayFormatter stringFromDate:prediction.paidAt]
                : NSLocalizedString(@"N/A", nil);
                cell.raknLabel.text = [NSString stringWithFormat:@"%i", prediction.contestRank.integerValue];
                cell.awaidLabel.text = @"-"; // TODO: this
            }
            return cell;
        }
            break;
        default:
            break;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView
heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 160.f;
}

- (CGFloat)tableView:(UITableView*)tableView
heightForHeaderInSection:(NSInteger)section
{
    return 40.f;
}

- (UIView*)tableView:(UITableView*)tableView
viewForHeaderInSection:(NSInteger)section
{
    FFRosterTableHeader* header = FFRosterTableHeader.new;
    header.titleLabel.text = @"";
    switch (self.predictionType) {
        case FFPredictionsTypeIndividual:
            header.titleLabel.text = NSLocalizedString(@"Individual predictions", nil);
            break;
        case FFPredictionsTypeRoster:
            header.titleLabel.text = NSLocalizedString(@"Roster predictions", nil);
            break;
        default:
            break;
    }
    header.titleLabel.frame = CGRectMake(header.titleLabel.frame.origin.x,
                                         header.titleLabel.frame.origin.y,
                                         320.f - 2 * header.titleLabel.frame.origin.x,
                                         60.f);
    return header;
}

- (void)tableView:(UITableView*)tableView
didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
}

#pragma mark - SBDataObjectResultSetDelegate

- (void)resultSetDidReload:(SBDataObjectResultSet*)resultSet
{
    [self.tableView reloadData];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - FFPredictHistoryProtocol

- (void)changeHistory:(FUISegmentedControl*)segments
{
    BOOL isHistory = segments.selectedSegmentIndex == 1;
    self.rosterPredictionType = isHistory ? FFRosterPredictionTypeFinished : FFRosterPredictionTypeSubmitted;
    [self refresh];
}

#pragma mark - private

- (void)hideTypeSelector
{
    CGFloat typeSelectorHeight = 100.f;
    [UIView animateWithDuration:(NSTimeInterval).3f
                     animations:
     ^{
         self.typeSelector.frame = CGRectMake(0.f,
                                              -typeSelectorHeight,
                                              self.view.bounds.size.width,
                                              typeSelectorHeight);
         self.typeSelector.alpha = 0.f;
         self.typeSelector.userInteractionEnabled = NO;
         [self.typeButton setImage:[UIImage imageNamed:@"hide"]
                          forState:UIControlStateNormal];
     }];
}

- (void)showTypeSelector
{
    CGFloat typeSelectorHeight = 100.f;
    [UIView animateWithDuration:(NSTimeInterval).3f
                     animations:
     ^{
         self.typeSelector.frame = CGRectMake(0.f,
                                              0.f,
                                              self.view.bounds.size.width,
                                              typeSelectorHeight);
         self.typeSelector.alpha = 1.f;
         self.typeSelector.userInteractionEnabled = YES;
         [self.typeButton setImage:[UIImage imageNamed:@"show"]
                          forState:UIControlStateNormal];
     }];
}

- (void)refresh
{
    [self.tableView setPredictionType:self.predictionType
                 rosterPredictionType:self.rosterPredictionType];
    [self.tableView reloadData];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    switch (self.predictionType) {
        case FFPredictionsTypeIndividual:
        {
            [self.individualPredictions fetch];
            [self.typeButton setTitle:NSLocalizedString(@"Individual", nil)
                             forState:UIControlStateNormal];
        }
            break;
        case FFPredictionsTypeRoster:
        {
            switch (self.rosterPredictionType) {
                case FFRosterPredictionTypeSubmitted:
                    [self.rosterPredictions fetch];
                    break;
                case FFRosterPredictionTypeFinished:
                    [self.rosterPredictions fetchWithParameters:
                     @{ @"historical" : @"true" }]; // TODO: should be in one of MODELs
                    break;
                default:
                    break;
            }
            [self.rosterPredictions fetch];
            [self.typeButton setTitle:NSLocalizedString(@"Roster", nil)
                             forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
}

@end
