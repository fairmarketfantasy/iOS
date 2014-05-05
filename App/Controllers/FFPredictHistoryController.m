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
#import "FFNoConnectionCell.h"
#import "FFPredictHeader.h"
#import "FFRosterTableHeader.h"
#import "FFPredictionsSelector.h"
#import "FFStyle.h"
#import "FFPredictRosterPagerController.h"
#import "FFAlertView.h"
#import "Reachability.h"
// model
#import "FFPredictionSet.h"
#import "FFIndividualPrediction.h"
#import "FFRosterPrediction.h"
#import "FFMarket.h"
#import "FFGame.h"
#import "FFContestType.h"
#import "FFDate.h"

@interface FFPredictHistoryController () <UITableViewDataSource, UITableViewDelegate,
FFPredictionsProtocol, SBDataObjectResultSetDelegate, FFPredictHistoryProtocol>

@property(nonatomic, assign) FFPredictionsType predictionType;
@property(nonatomic, assign) FFRosterPredictionType rosterPredictionType;
@property(nonatomic) UIButton* typeButton;
@property(nonatomic) FFPredictHistoryTable* tableView;
@property(nonatomic) FFPredictionsSelector* typeSelector;
// model
@property(nonatomic) FFPredictionSet* individualPredictions;
@property(nonatomic) FFPredictionSet* rosterActivePredictions;
@property(nonatomic) FFPredictionSet* rosterHistoryPredictions;

@property(nonatomic, assign) NetworkStatus networkStatus;

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
    
    //refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [FFStyle lightGrey];
    [refreshControl addTarget:self action:@selector(pullToRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    // title
    self.navigationItem.titleView = self.typeButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    internetReachability = [Reachability reachabilityForInternetConnection];
	BOOL success = [internetReachability startNotifier];
	if ( !success )
		DLog(@"Failed to start notifier");
    self.networkStatus = [internetReachability currentReachabilityStatus];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    self.individualPredictions = [FFPredictionSet.alloc initWithDataObjectClass:[FFIndividualPrediction class]
                                                                        session:self.session authorized:YES];
    self.individualPredictions.delegate = self;
    self.rosterActivePredictions = [FFPredictionSet.alloc initWithDataObjectClass:[FFRosterPrediction class]
                                                                    session:self.session authorized:YES];
    self.rosterActivePredictions.delegate = self;
    self.rosterHistoryPredictions = [FFPredictionSet.alloc initWithDataObjectClass:[FFRosterPrediction class]
                                                                    session:self.session authorized:YES];
    self.rosterHistoryPredictions.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self hideTypeSelector];
    
    if (self.networkStatus != NotReachable) {
        [self refreshWithShowingAlert:NO completion:^{
            [self.tableView reloadData];
        }];        
    }
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
        vc.prediction = (FFRosterPrediction*)sender;
    }
}

#pragma mark

- (void)checkNetworkStatus:(NSNotification *)notification
{
    NetworkStatus internetStatus = [internetReachability currentReachabilityStatus];
    NetworkStatus previousStatus = self.networkStatus;
    if (internetStatus != self.networkStatus) {
        self.networkStatus = internetStatus;
        
        if ((internetStatus != NotReachable && previousStatus == NotReachable) ||
            (internetStatus == NotReachable && previousStatus != NotReachable)) {
            
            if (internetStatus == NotReachable) {
                [self.tableView reloadData];
            } else {
                [self refreshWithShowingAlert:YES completion:^{
                    [self.tableView reloadData];
                }];
            }
        }
    }
}

#pragma mark -

- (void)pullToRefresh:(UIRefreshControl *)refreshControl
{
    [self refreshWithShowingAlert:NO completion:^{
        [self.tableView reloadData];
        [refreshControl endRefreshing];
    }];
}

#pragma mark - FFPredictionsProtocol

- (void)predictionsTypeSelected:(FFPredictionsType)type
{
    self.predictionType = type;

    [self refreshWithShowingAlert:YES completion:^{
        [self.tableView reloadData];
    }];
    
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

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.networkStatus == NotReachable) {
        return 1;
    } else {
        switch (self.predictionType) {
            case FFPredictionsTypeIndividual:
                return self.individualPredictions.allObjects.count;
            case FFPredictionsTypeRoster:
            {
                switch (self.rosterPredictionType) {
                    case FFRosterPredictionTypeSubmitted:
                        return self.rosterActivePredictions.allObjects.count;
                    case FFRosterPredictionTypeFinished:
                        return self.rosterHistoryPredictions.allObjects.count;
                    default:
                        return 0;
                }
            }
            default:
                return 0;
        }
    }
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (self.networkStatus == NotReachable) {
        FFNoConnectionCell* cell = [tableView dequeueReusableCellWithIdentifier:kNoConnectionCellIdentifier
                                                                   forIndexPath:indexPath];
        return cell;
    }
    
    switch (self.predictionType) {
        case FFPredictionsTypeIndividual:
        {
            FFPredictIndividualCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PredictIndividualCell"
                                                                            forIndexPath:indexPath];
            if (self.individualPredictions.allObjects.count > indexPath.row) {
                FFIndividualPrediction* prediction = self.individualPredictions.allObjects[indexPath.row];
                cell.choiceLabel.text = prediction.playerName;
                cell.eventLabel.text = prediction.marketName;
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
                cell.resultLabel.text = [prediction.state isEqualToString:@"cancelled"]
                ? NSLocalizedString(@"Didn't play", nil)
                : (prediction.gameResult ? prediction.gameResult : NSLocalizedString(@"N/A", nil));
            }
            return cell;
        }
            break;
        case FFPredictionsTypeRoster:
        {
            FFPredictHistoryCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PredictCell"
                                                                         forIndexPath:indexPath];
            NSArray* predictions = nil;
            switch (self.rosterPredictionType) {
                case FFRosterPredictionTypeSubmitted:
                    predictions = self.rosterActivePredictions.allObjects;
                    break;
                case FFRosterPredictionTypeFinished:
                    predictions = self.rosterHistoryPredictions.allObjects;
                    break;
                default:
                    predictions = @[];
                    break;
            }
            if (predictions.count > indexPath.row) {
                __block FFRosterPrediction* prediction = predictions[indexPath.row];
                @weakify(self)
                [cell.rosterButton setAction:kUIButtonBlockTouchUpInside
                                   withBlock:^{
                                       @strongify(self)
                                       [self performSegueWithIdentifier:@"GotoPredictRoster"
                                                                 sender:prediction]; // TODO: refactode it (?)
                                   }];
                BOOL isFinished = [prediction.state isEqualToString:@"finished"];
                cell.nameLabel.text = prediction.market.name;
                cell.teamLabel.text = prediction.contestType.name;
                cell.dayLabel.text = [FFStyle.dayFormatter stringFromDate:prediction.startedAt];
                cell.stateLabel.text = prediction.state;
                cell.pointsLabel.text = isFinished ? [NSString stringWithFormat:@"%i",
                                                      prediction.score.integerValue]
                :  NSLocalizedString(@"N/A", nil);
                FFGame* firstGame = prediction.market.games.firstObject;
                NSDateFormatter* formatter = FFStyle.timeFormatter;
                cell.gameTimeLabel.text = firstGame ? [formatter stringFromDate:firstGame.gameTime]
                : NSLocalizedString(@"N/A", nil);
                cell.rankLabel.text = isFinished ? [NSString stringWithFormat:@"%i of %i",
                                                    prediction.contestRank.integerValue,
                                                    prediction.contestType.maxEntries.integerValue]
                : NSLocalizedString(@"Not started yet", nil);
                cell.awardLabel.text = isFinished ? [NSString stringWithFormat:@"%i",
                                                     prediction.contestRankPayout.integerValue / 100]
                : NSLocalizedString(@"N/A", nil);
            }
            return cell;
        }
            break;
        default:
            break;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return self.networkStatus == NotReachable ? [UIScreen mainScreen].bounds.size.height - 64.f : 160.f;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.networkStatus == NotReachable ? 0.f : 40.f;
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.networkStatus == NotReachable)
        return nil;
    
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

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
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
    [self refreshWithShowingAlert:YES completion:^{
        [self.tableView reloadData];
    }];
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

- (void)refreshWithShowingAlert:(BOOL)shouldShow completion:(void(^)(void))block
{
    if (self.networkStatus == NotReachable) {
        [self.tableView setPredictionType:self.predictionType
                     rosterPredictionType:self.rosterPredictionType];
        
        if (shouldShow) {
            [[FFAlertView noInternetConnectionAlert] showInView:self.view];
        }
        
        block();
        return;
    }
    
    __block FFAlertView* alert = nil;
    if (shouldShow) {
        alert = [[FFAlertView alloc] initWithTitle:NSLocalizedString(@"Loading", nil)
                                          messsage:nil
                                      loadingStyle:FFAlertViewLoadingStylePlain];
        [alert showInView:self.navigationController.view];
    }
    
    [self.tableView setPredictionType:self.predictionType
                 rosterPredictionType:self.rosterPredictionType];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    switch (self.predictionType) {
        case FFPredictionsTypeIndividual: {
            [self.individualPredictions fetchWithCompletion:^{
                if (alert)
                    [alert hide];
                if (block)
                    block();
            }];
            [self.typeButton setTitle:NSLocalizedString(@"Individual", nil)
                             forState:UIControlStateNormal];
        }
            break;
            
        case FFPredictionsTypeRoster: {
            if (self.rosterPredictionType == FFRosterPredictionTypeSubmitted) {
                [self.rosterActivePredictions fetchWithCompletion:^{
                    if (alert)
                        [alert hide];
                    if (block)
                        block();
                }];
            } else if (self.rosterPredictionType == FFRosterPredictionTypeFinished) {
                [self.rosterHistoryPredictions fetchWithParameters:@{ @"historical" : @"true" }
                                                        completion:^{
                                                            if (alert)
                                                                [alert hide];
                                                            if (block)
                                                                block();
                                                        }]; // TODO: should be in one of MODELs
                
            }
            
            [self.typeButton setTitle:NSLocalizedString(@"Roster", nil)
                             forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
}

@end
