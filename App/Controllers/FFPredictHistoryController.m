//
//  FFPredictHistoryController.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/28/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFPredictHistoryController.h"
#import "FFNavigationBarItemView.h"
#import <LBActionSheet.h>
#import "FFLogo.h"
#import "FFPredictHistoryTable.h"
#import "FFPredictHistoryCell.h"
#import "FFPredictIndividualCell.h"
#import "FFPredictHeader.h"
#import "FFRosterTableHeader.h"
#import "FFPredictionsSelector.h"

@interface FFPredictHistoryController () <LBActionSheetDelegate,
UITableViewDataSource, UITableViewDelegate, FFPredictionsProtocol>

@property(nonatomic, assign) FFPredictionsType predictionType;
@property(nonatomic) UIButton* typeButton;
@property(nonatomic) FFPredictHistoryTable* tableView;
@property(nonatomic) FFPredictionsSelector* typeSelector;
@end

@implementation FFPredictHistoryController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.predictionType = FFPredictionsTypeRoster;
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
                        action:@selector(shorOrHideTypeSelectorIfNeeded)
              forControlEvents:UIControlEventTouchUpInside];
    self.typeButton.contentMode = UIViewContentModeScaleAspectFit;
    // table view
    self.tableView = [[FFPredictHistoryTable alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.view bringSubviewToFront:self.typeSelector];
    // title
    self.navigationItem.titleView = self.typeButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self predictionsTypeSelected:FFPredictionsTypeRoster];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - FFPredictionsProtocol

- (void)predictionsTypeSelected:(FFPredictionsType)type
{
    self.predictionType = type;
    [self.tableView setPredictionType:type];
    [self.tableView reloadData];
    switch (type) {
        case FFPredictionsTypeIndividual:
            [self.typeButton setTitle:NSLocalizedString(@"Individual", nil)
                             forState:UIControlStateNormal];
            break;
        case FFPredictionsTypeRoster:
            [self.typeButton setTitle:NSLocalizedString(@"Roster", nil)
                             forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    [self shorOrHideTypeSelectorIfNeeded];
}

#pragma mark - button actions

- (void)shorOrHideTypeSelectorIfNeeded
{
    BOOL shouldShow = !self.typeSelector.userInteractionEnabled;
    CGFloat typeSelectorHeight = 100.f;
    [UIView animateWithDuration:(NSTimeInterval).3f
                     animations:
     ^{
         self.typeSelector.frame = CGRectMake(0.f,
                                              shouldShow ? 0.f : -typeSelectorHeight,
                                              self.view.bounds.size.width,
                                              typeSelectorHeight);
         self.typeSelector.alpha = shouldShow ? 1.f : 0.f;
         self.typeSelector.userInteractionEnabled = shouldShow;
         [self.typeButton setImage:[UIImage imageNamed: shouldShow ? @"show" : @"hide"]
                          forState:UIControlStateNormal];
     }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (self.predictionType) {
        case FFPredictionsTypeIndividual:
        {
            FFPredictIndividualCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PredictIndividualCell"
                                                                            forIndexPath:indexPath];
            return cell;
        }
            break;
        case FFPredictionsTypeRoster:
        {
            FFPredictHistoryCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PredictCell"
                                                                         forIndexPath:indexPath];
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

@end
