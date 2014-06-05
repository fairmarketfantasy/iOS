//
//  FFNonFantasyRosterController.m
//  FMF Football
//
//  Created by Anton Chuev on 6/5/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFNonFantasyRosterController.h"
#import "FFYourTeamController.h"
#import "FFSessionViewController.h"
#import "FFTeamTable.h"
#import "FFAutoFillCell.h"
#import "FFMarketsCell.h"
#import "FFTeamCell.h"
#import "FFTeamTradeCell.h"
#import "FFNoConnectionCell.h"
#import "FFNonFantasyTeamCell.h"
#import "FFNonFantasyTeamTradeCell.h"
#import "FFSubmitView.h"
#import "FFAlertView.h"
#import "FFRosterTableHeader.h"
#import "FFAccountHeader.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "FFPathImageView.h"
#import "FFMarketSelector.h"
#import "FFSessionManager.h"
#import "FFCollectionMarketCell.h"
#import <libextobjc/EXTScope.h>
#import <FlatUIKit.h>

#import "Reachability.h"

// models
#import "FFRoster.h"
#import "FFMarket.h"
#import "FFMarketSet.h"
#import "FFUser.h"
#import "FFPlayer.h"
#import "FFDate.h"

@interface FFNonFantasyRosterController () <UITableViewDataSource, UITableViewDelegate, FFMarketSelectorDelegate, FFMarketSelectorDataSource>

// models
@property(nonatomic, assign) NSUInteger tryCreateRosterTimes;
@property(nonatomic) FFSubmitView* submitView;
@property(nonatomic) FFMarketSet* marketsSetRegular;
@property(nonatomic) FFMarketSet* marketsSetSingle;

@property(nonatomic, assign) NetworkStatus networkStatus;
@property(nonatomic, assign) BOOL isServerError;

@end

@implementation FFNonFantasyRosterController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.removeBenched = YES;
    
    // submit view
    self.submitView = [FFSubmitView new];
    [self.submitView.segments addTarget:self
                                 action:@selector(onSubmit:)
                       forControlEvents:UIControlEventValueChanged];
    [self.submitView.submitButton addTarget:self
                                     action:@selector(onSubmit:)
                           forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.submitView];
    
    // table view
    self.tableView = [[FFTeamTable alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.view bringSubviewToFront:self.submitView];
    
    //refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [FFStyle lightGrey];
    [refreshControl addTarget:self action:@selector(pullToRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoFill:) name:@"Autofill" object:nil];
    
    //reachability
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Autofill" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.submitView setupWithType:FFSubmitViewTypeNonFantasy];
    
    if (self.networkStatus == NotReachable) {
        [self.tableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showOrHideSubmitIfNeeded];
}

#pragma mark -

- (void)pullToRefresh:(UIRefreshControl *)refreshControl
{
    [refreshControl endRefreshing];
}

#pragma mark

- (void)reloadWithServerError:(BOOL)isError
{
    self.isServerError = isError;
    [self.tableView reloadData];
    [self showOrHideSubmitIfNeeded];
}

#pragma mark -

- (void)checkNetworkStatus:(NSNotification *)notification
{
    NetworkStatus internetStatus = [internetReachability currentReachabilityStatus];
    NetworkStatus previousStatus = self.networkStatus;
    
    if (internetStatus != self.networkStatus) {
        self.networkStatus = internetStatus;
        
        if ((internetStatus != NotReachable && previousStatus == NotReachable) ||
            (internetStatus == NotReachable && previousStatus != NotReachable)) {
            
            if (internetStatus == NotReachable) {
                [self showOrHideSubmitIfNeeded];
                [self.tableView reloadData];
                
            }
        }
    }
}

#pragma mark - private

- (BOOL)isSomethingWrong
{
    return (self.networkStatus == NotReachable ||
            self.isServerError ||
            self.dataSource.unpaidSubscription == YES ||
            [self.dataSource availableGames].count == 0);
}

#pragma mark

- (void)showOrHideSubmitIfNeeded
{
    BOOL anyObject = [self.dataSource teams].count > 0 && self.networkStatus != NotReachable;
    CGFloat submitHeight = 70.f;
    [UIView animateWithDuration:(NSTimeInterval).3f
                     animations:
     ^{
         self.submitView.frame = CGRectMake(0.f,
                                            anyObject ? self.view.bounds.size.height - submitHeight
                                            : self.view.bounds.size.height,
                                            self.view.bounds.size.width,
                                            submitHeight);
         self.submitView.alpha = (anyObject && self.networkStatus != NotReachable) ? 1.f : 0.f;
         self.submitView.userInteractionEnabled = anyObject;
         UIEdgeInsets tableInsets = self.tableView.contentInset;
         tableInsets.bottom = anyObject ? submitHeight : 0.f;
         self.tableView.contentInset = tableInsets;
     }];
}

#pragma mark

- (void)refreshRosterWithShowingAlert:(BOOL)shouldShow completion:(void(^)(void))block
{
    if (self.networkStatus == NotReachable) {
        if (shouldShow) {
            [[FFAlertView noInternetConnectionAlert] showInView:self.view];
        }
        
        block();
        return;
    }
    
    __block FFAlertView* alert = nil;
    if (shouldShow) {
        alert = [[FFAlertView alloc] initWithTitle:@""
                                          messsage:nil
                                      loadingStyle:FFAlertViewLoadingStylePlain];
        [alert showInView:self.view];
    }
    
    @weakify(self)
    [self.delegate refreshRosterWithCompletion:^(BOOL success) {
        @strongify(self)
        [self reloadWithServerError:!success];
        if (alert)
            [alert hide];
        if (block)
            block();
    }];
}

#pragma mark - Cells

- (FFAutoFillCell *)provideAutoFillCellForTable:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    FFAutoFillCell* cell = [tableView dequeueReusableCellWithIdentifier:kAutoFillCellIdentifier
                                                           forIndexPath:indexPath];
    [cell.autoFillButton addTarget:self
                            action:@selector(autoFill:)
                  forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (FFNonFantasyTeamCell *)provideNonFantasyTeamCellForTable:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    FFNonFantasyTeamCell *cell = [tableView dequeueReusableCellWithIdentifier:kNonFantasyTeamCellIdentifier
                                                                 forIndexPath:indexPath];
    
    cell.titleLabel.text = [NSString stringWithFormat:@"%@", @"Team Not Selected"];
    return cell;
}

- (FFNonFantasyTeamTradeCell *)provideNonFantasyTeamTradeCellForTable:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    FFNonFantasyTeamTradeCell *cell = [tableView dequeueReusableCellWithIdentifier:kNonFantasyTeamTradeCellIdentifier
                                                                      forIndexPath:indexPath];
    
    FFTeam *team = [self.dataSource teams][indexPath.row];
    [cell setupWithGame:team];
    [cell.deleteBtn setAction:kUIButtonBlockTouchUpInside
                    withBlock:^{
                        [self.delegate removeTeam:team];
                    }];
    return cell;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return [self isSomethingWrong] ? 1 : 2;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    
    return 5;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            //navigation bar height + status bar height = 64
            return [self isSomethingWrong] ? [UIScreen mainScreen].bounds.size.height - 64.f : 70.f;
        }
        return 50.f;
    }
    
    return 80.f;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.section) {
        case 0: {
            if (indexPath.row == 0) {
                if ([self isSomethingWrong]) {
                    FFNoConnectionCell* cell = [tableView dequeueReusableCellWithIdentifier:kNoConnectionCellIdentifier
                                                                               forIndexPath:indexPath];
                    
                    NSString *message = nil;
                    if (self.networkStatus == NotReachable) {
                        message = @"No Internet Connection";
                    } else if ([self.dataSource unpaidSubscription]) {
                        message = @"Your free trial has ended. We hope you have enjoyed playing. To continue please visit our site: https//:predictthat.com";
                    } else if ([self.dataSource availableGames].count == 0) {
                        message = @"No Games Scheduled";
                    }
                    
                    cell.message.text = message;
                    return cell;
                }
                
                return [self provideAutoFillCellForTable:tableView atIndexPath:indexPath];
            }
            
            return [self provideAutoFillCellForTable:tableView atIndexPath:indexPath];
        }
            
        case 1: {
            if ([self.dataSource teams].count > 0 && [self.dataSource teams].count >= indexPath.row + 1) {
                return [self provideNonFantasyTeamTradeCellForTable:tableView atIndexPath:indexPath];
            }
            
            return [self provideNonFantasyTeamCellForTable:tableView atIndexPath:indexPath];
        }
            
        default:
            return nil;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([self isSomethingWrong])
        return;
    
    if (indexPath.section == 1) {
        [self.delegate showAvailableGames];
    }
}

- (UIView *)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        FFRosterTableHeader* view = [FFRosterTableHeader new];
        view.titleLabel.text = @"Your choices";
        return view;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 40.f;
    }
    return 0.f;
}

#pragma mark - button actions

- (void)autoRemovedBenched:(FUISwitch*)sender
{
    [self toggleRemoveBench:sender];
    self.removeBenched = sender.on;
}

- (void)toggleRemoveBench:(FUISwitch*)sender
{
    if (self.networkStatus == NotReachable) {
        [[FFAlertView noInternetConnectionAlert] showInView:self.view];
        return;
    }
    
    __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:@"Toggle Auto-Remove Benched Players"
                                                           messsage:nil
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.navigationController.view];
    
    @weakify(self)
    [self.delegate toggleRemoveBenchWithCompletion:^(BOOL success) {
        @strongify(self)
        [self reloadWithServerError:!success];
        [alert hide];
    }];
}

- (void)autoFill:(UIButton*)button
{
    if (self.networkStatus == NotReachable) {
        [[FFAlertView noInternetConnectionAlert] showInView:self.view];
        return;
    }
    
    __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:@"Auto Fill Roster"
                                                           messsage:nil
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.navigationController.view];
    
    @weakify(self)
    [self.delegate autoFillWithCompletion:^(BOOL success) {
        @strongify(self)
        [self reloadWithServerError:!success];
        [alert hide];
    }];
}

- (void)removePlayer:(FFPlayer*)player
{
    __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:@"Removing Player"
                                                           messsage:nil
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.navigationController.view];
    
    @weakify(self)
    [self.delegate removePlayer:player completion:^(BOOL success) {
        @strongify(self)
        [alert hide];
        [self showOrHideSubmitIfNeeded];
        
        if (success) {
            [self refreshRosterWithShowingAlert:YES completion:^{
                [self.tableView reloadData];
            }];
            
            [self.delegate showPosition:player.position];
        }
    }];
}

- (void)onSubmit:(FUISegmentedControl*)segments
{
    [self submitRoster:0];
}

- (void)submitRoster:(FFRosterSubmitType)rosterType
{
    __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:@"Submitting Roster"
                                                           messsage:nil
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.navigationController.view];
    [self.delegate submitRoster:rosterType completion:^(BOOL success) {
        [alert hide];
        if (success) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }];
}

@end
