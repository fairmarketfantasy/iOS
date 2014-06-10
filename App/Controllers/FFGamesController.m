//
//  FFGamesController.m
//  FMF Football
//
//  Created by Anton Chuev on 6/5/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFGamesController.h"
#import "FFWideReceiverController.h"
#import "FFYourTeamDataSource.h"
#import "FFPagerController.h"
#import "FFWideReceiverTable.h"
#import "FFWideReceiverCell.h"
#import "FFTeamAddCell.h"
#import "FFNoConnectionCell.h"
#import "FFCollectionMarketCell.h"
#import "FFNonFantasyGameCell.h"
#import "FFMarketsCell.h"
#import "FFAutoFillCell.h"
#import "FFRosterTableHeader.h"
#import "FFMarketSelector.h"
#import "FFAccountHeader.h"
#import "FFStyle.h"
#import "FFMarket.h"
#import "FFDate.h"
#import "FFMarketSet.h"
#import "FFPathImageView.h"
#import "FFPTController.h"
#import "FFAlertView.h"
#import "Reachability.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import <libextobjc/EXTScope.h>
#import <libextobjc/EXTScope.h>
#import <FlatUIKit.h>
// model
#import "FFUser.h"
#import "FFRoster.h"
#import "FFPlayer.h"
#import "FFTeam.h"
#import "FFNonFantasyGame.h"
#import "FFSessionManager.h"

@interface FFGamesController () <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, FFMarketSelectorDelegate, FFMarketSelectorDataSource>

@property(nonatomic, assign) NSUInteger position;
@property(nonatomic, assign) NetworkStatus networkStatus;
@property(nonatomic, assign) BOOL isServerError;

@property(nonatomic) FFMarketSet* marketsSetRegular;
@property(nonatomic) FFMarketSet* marketsSetSingle;
@property(nonatomic, assign) NSUInteger tryCreateRosterTimes;

@end

@implementation FFGamesController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.position = 0;
    self.tableView = [[FFWideReceiverTable alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    //refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [FFStyle lightGrey];
    [refreshControl addTarget:self action:@selector(pullToRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[FFSessionManager shared].currentCategoryName isEqualToString:FANTASY_SPORTS]) {
        if (self.players.count == 0) {
            [self fetchPlayersWithShowingAlert:NO completion:^{
                [self.tableView reloadData];
            }];
        } else {
            [self.tableView reloadData];
        }
    } else {
        [self.tableView reloadData];
    }
}

#pragma mark

- (void)pullToRefresh:(UIRefreshControl *)refreshControl
{
    if ([[FFSessionManager shared].currentCategoryName isEqualToString:FANTASY_SPORTS]) {
        [self fetchPlayersWithShowingAlert:NO completion:^{
            [self.tableView reloadData];
            [refreshControl endRefreshing];
        }];
    } else {
        [self.delegate fetchGamesShowAlert:NO withCompletion:^{
            [self.tableView reloadData];
            [refreshControl endRefreshing];
        }];
    }
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
                [self.tableView reloadData];
            }
        }
    }
}

#pragma mark - public

- (void)resetPosition
{
    self.position = 0;
}

- (void)reloadWithServerError:(BOOL)isError
{
    self.isServerError = isError;
    [self.tableView reloadData];
}

#pragma mark - private

- (BOOL)isSomethingWrong
{
    return (self.networkStatus == NotReachable ||
            self.isServerError ||
//            self.dataSource.unpaidSubscription == YES ||
            [self.dataSource availableGames].count == 0);
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return [self isSomethingWrong] ? 1 : 2;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if ([self isSomethingWrong]) {
            return 1;
        }
        
        return 1;
    }
    
    return [self.dataSource availableGames].count;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            //navigation bar height + status bar height = 64
            return [self isSomethingWrong] ? [UIScreen mainScreen].bounds.size.height - 64.f : 70.f;
        } else {
            return 76.f;
        }
    }
    
    return 100.f;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0) {
        if ([self isSomethingWrong]) {
            FFNoConnectionCell* cell = [tableView dequeueReusableCellWithIdentifier:kNoConnectionCellIdentifier
                                                                       forIndexPath:indexPath];
            NSString *message = nil;
            if (self.networkStatus == NotReachable) {
                message = @"No Internet Connection";
            } /*else if ([self.dataSource unpaidSubscription]) {
                message = @"Your free trial has ended. We hope you have enjoyed playing. To continue please visit our site: https//:predictthat.com";
            }*/ else if ([self.dataSource availableGames].count == 0) {
                message = @"No Games Scheduled";
            }
            
            cell.message.text = message;
            return cell;
        }
        
        return [self provideAutoFillCellForTable:tableView atIndexPath:indexPath];

    } else if (indexPath.section == 1) {
        FFNonFantasyGame *game = [[self.dataSource availableGames] objectAtIndex:indexPath.row];
        return [self provideGameCellForGame:game table:tableView atIndexPath:indexPath];
    }
    
    return nil;
}

#pragma mark - Cells

- (FFNonFantasyGameCell *)provideGameCellForGame:(FFNonFantasyGame *)game table:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    FFNonFantasyGameCell *cell = [tableView dequeueReusableCellWithIdentifier:kNonFantasyGameCellIdentifier
                                                                 forIndexPath:indexPath];
    [cell setupWithGame:game];
    
    __weak FFGamesController *weakSelf = self;
    [cell.addHomeTeamBtn setAction:kUIButtonBlockTouchUpInside
                         withBlock:^{
                             FFNonFantasyGame *game = [weakSelf.dataSource availableGames][indexPath.row];
                             [weakSelf.delegate addTeam:[game homeTeam]];
                         }];
    
    [cell.addAwayTeamBtn setAction:kUIButtonBlockTouchUpInside
                         withBlock:^{
                             FFNonFantasyGame *game = [weakSelf.dataSource availableGames][indexPath.row];
                             [weakSelf.delegate addTeam:[game awayTeam]];
                         }];
    
    [cell.homePTButton setAction:kUIButtonBlockTouchUpInside
                       withBlock:^{
                           [self.delegate makeIndividualPredictionOnTeam:game.homeTeam];
                       }];
    
    [cell.awayPTButton setAction:kUIButtonBlockTouchUpInside
                       withBlock:^{
                           [self.delegate makeIndividualPredictionOnTeam:game.awayTeam];
                       }];
    
    return cell;
}

- (FFAutoFillCell *)provideAutoFillCellForTable:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    FFAutoFillCell* cell = [tableView dequeueReusableCellWithIdentifier:kAutoFillCellIdentifier
                                                           forIndexPath:indexPath];
    [cell.autoFillButton addTarget:self
                            action:@selector(autoFill:)
                  forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    // TODO: implement
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        FFRosterTableHeader* view = [FFRosterTableHeader new];
        view.titleLabel.text = @"Games for today";
        return view;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 40.f;
    }
    return 0.f;
}

#pragma mark - button actions

- (void)autoFill:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Autofill" object:nil];
}

@end
