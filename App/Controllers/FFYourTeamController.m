//
//  FFYourTeamController.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/14/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

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

@interface FFYourTeamController () <UITableViewDataSource, UITableViewDelegate, FFMarketSelectorDelegate, FFMarketSelectorDataSource>

// models
@property(nonatomic, assign) NSUInteger tryCreateRosterTimes;
@property(nonatomic) FFSubmitView* submitView;
@property(nonatomic) FFMarketSet* marketsSetRegular;
@property(nonatomic) FFMarketSet* marketsSetSingle;

@property(nonatomic, assign) NetworkStatus networkStatus;
@property(nonatomic, assign) BOOL isServerError;

@end

@implementation FFYourTeamController

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

//- (void)didMoveToParentViewController:(UIViewController *)parent
//{
//    self.marketsSetRegular = [FFMarketSet.alloc initWithDataObjectClass:[FFMarket class]
//                                                                session:self.session authorized:YES];
//    self.marketsSetSingle = [FFMarketSet.alloc initWithDataObjectClass:[FFMarket class]
//                                                               session:self.session authorized:YES];
//    self.marketsSetRegular.delegate = self;
//    self.marketsSetSingle.delegate = self;
//    [self updateMarkets];
//    // roster
//    self.tryCreateRosterTimes = 3;
//    [self createRoster];
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    [self updateSubmitViewType];
    
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
    if ([[FFSessionManager shared].currentCategoryName isEqualToString:FANTASY_SPORTS]) {
        [self refreshRosterWithShowingAlert:NO completion:^{
            [self.tableView reloadData];
            [refreshControl endRefreshing];
        }];
    } else {
        [refreshControl endRefreshing];
    }
}

#pragma mark

- (void)reloadWithServerError:(BOOL)isError
{
    self.isServerError = isError;
    if ([[FFSessionManager shared].currentCategoryName isEqualToString:FANTASY_SPORTS]) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self.tableView reloadData];
    }
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

            } /*else {
                [self refreshRosterWithShowingAlert:NO completion:^{
                    [self hideErrorView];
                    [self.tableView reloadData];
                }];
            }*/
        }
    }
}

#pragma mark - private

- (BOOL)isSomethingWrong
{
    if ([[FFSessionManager shared].currentCategoryName isEqualToString:FANTASY_SPORTS]) {
        return (self.networkStatus == NotReachable ||
                self.isServerError ||
                self.dataSource.unpaidSubscription == YES ||
                self.markets.count == 0);
    } else {
        return (self.networkStatus == NotReachable ||
                self.isServerError ||
                self.dataSource.unpaidSubscription == YES ||
                [self.dataSource availableGames].count == 0);
    }
}

#pragma mark

- (void)updateSubmitViewType
{
    FFSubmitViewType type = [[FFSessionManager shared].currentCategoryName isEqualToString:FANTASY_SPORTS] ? FFSubmitViewTypeFantasy : FFSubmitViewTypeNonFantasy;
    [self.submitView setupWithType:type];
}

- (void)showOrHideSubmitIfNeeded
{
    BOOL anyObject = NO;
    if ([[FFSessionManager shared].currentCategoryName isEqualToString:FANTASY_SPORTS]) {
        anyObject = self.dataSource.currentRoster.players.count > 0 && self.networkStatus != NotReachable;
    } else {
        anyObject = [self.dataSource teams].count > 0 && self.networkStatus != NotReachable;
    }

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

- (FFMarketsCell *)provideMarketsCellForTable:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    FFMarketsCell* cell = [tableView dequeueReusableCellWithIdentifier:kMarketsCellIdentifier
                                                          forIndexPath:indexPath];
    cell.marketSelector.dataSource = self;
    cell.marketSelector.delegate = self;
    [cell.marketSelector reloadData];
    if (self.dataSource.currentMarket && self.markets) {
        cell.contentView.userInteractionEnabled = YES;
        [cell setNoGamesLabelHidden:YES];
        NSUInteger selectedMarket = [self.markets indexOfObject:self.dataSource.currentMarket];
        if (selectedMarket != NSNotFound) {
            [cell.marketSelector updateSelectedMarket:selectedMarket
                                             animated:NO] ;
        }
    } else if (self.markets.count == 0) {
        if (self.networkStatus == NotReachable) {
            [cell setNoGamesLabelHidden:NO];
            cell.contentView.userInteractionEnabled = NO;
        }
    }
    
    return cell;
}

- (FFAutoFillCell *)provideAutoFillCellForTable:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    FFAutoFillCell* cell = [tableView dequeueReusableCellWithIdentifier:kAutoFillCellIdentifier
                                                           forIndexPath:indexPath];
    if ([[FFSessionManager shared].currentCategoryName isEqualToString:FANTASY_SPORTS]) {
        cell.autoRemovedBenched.on = self.removeBenched;
        [cell.autoRemovedBenched addTarget:self
                                    action:@selector(autoRemovedBenched:)
                          forControlEvents:UIControlEventValueChanged];
    }
    [cell.autoFillButton addTarget:self
                            action:@selector(autoFill:)
                  forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (FFTeamTradeCell *)provideTeamTradeCellWithPlayer:(FFPlayer *)player forTable:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    FFTeamTradeCell* cell = [tableView dequeueReusableCellWithIdentifier:kTeamTradeCellIdentifier
                                                            forIndexPath:indexPath];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@ PPG %li", player.team, (long)[player.ppg integerValue]];
    cell.nameLabel.text = player.name;
    cell.costLabel.text = [FFStyle.priceFormatter
                           stringFromNumber:@([player.purchasePrice floatValue])];
    cell.centLabel.text = @"";
    BOOL benched = player.benched.integerValue == 1;
    UIColor* avatarColor = benched ? [FFStyle brightOrange] : [FFStyle brightGreen];
    cell.avatar.borderColor = avatarColor;
    cell.avatar.pathColor = avatarColor;
    [cell.avatar setImageWithURL: [NSURL URLWithString:player.headshotURL]
                placeholderImage: [UIImage imageNamed:@"rosterslotempty"]
     usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [cell.avatar draw];
    cell.benched.hidden = !benched;
    cell.PTButton.hidden = (benched || [player.ppg integerValue] == 0) ? YES : NO;
    __block FFPlayer* blockPlayer = player;
    @weakify(self)
    [cell.PTButton setAction:kUIButtonBlockTouchUpInside
                   withBlock:^{
                       @strongify(self)
                       [self.parentViewController performSegueWithIdentifier:@"GotoPT"
                                                                      sender:blockPlayer]; // TODO: refactode it (?)
                   }];
    [cell.tradeButton setAction:kUIButtonBlockTouchUpInside
                      withBlock:^{
                          @strongify(self)
                          [self removePlayer:blockPlayer];
                      }];
    return cell;
    //        for (FFPlayer* player in self.roster.players) {
    //            if ([player.position isEqualToString:position]) {
    //                FFTeamTradeCell* cell = [tableView dequeueReusableCellWithIdentifier:kTeamTradeCellIdentifier
    //                                                                        forIndexPath:indexPath];
    //                cell.titleLabel.text = player.team;
    //                cell.nameLabel.text = player.name;
    //                cell.costLabel.text = [FFStyle.priceFormatter
    //                                       stringFromNumber:@([player.purchasePrice floatValue])];
    //                cell.centLabel.text = @"";
    //                BOOL benched = player.benched.integerValue == 1;
    //                UIColor* avatarColor = benched ? [FFStyle brightOrange] : [FFStyle brightGreen];
    //                cell.avatar.borderColor = avatarColor;
    //                cell.avatar.pathColor = avatarColor;
    //                [cell.avatar setImageWithURL: [NSURL URLWithString:player.headshotURL]
    //                            placeholderImage: [UIImage imageNamed:@"rosterslotempty"]
    //                 usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    //                [cell.avatar draw];
    //                cell.benched.hidden = !benched;
    //                cell.PTButton.hidden = benched;
    //                __block FFPlayer* blockPlayer = player;
    //                @weakify(self)
    //                [cell.PTButton setAction:kUIButtonBlockTouchUpInside
    //                               withBlock:^{
    //                                   @strongify(self)
    //                                   [self.parentViewController performSegueWithIdentifier:@"GotoPT"
    //                                                                                  sender:blockPlayer];
    //                               }];
    //                [cell.tradeButton setAction:kUIButtonBlockTouchUpInside
    //                                  withBlock:^{
    //                                      @strongify(self)
    //                                      [self removePlayer:blockPlayer];
    //                                  }];
    //                return cell;
    //            }
    //        }
}

- (FFTeamCell *)provideTeamCellWithPosition:(NSString *)position forTable:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    FFTeamCell* cell = [tableView dequeueReusableCellWithIdentifier:kTeamCellIdentifier
                                                       forIndexPath:indexPath];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@ %@", position,
                            @"Not Selected"];
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
        if ([[FFSessionManager shared].currentCategoryName isEqualToString:FANTASY_SPORTS]) {
            return [self isSomethingWrong] ? 1 : 2;
        } else {
            return 1;
        }
    }
    
    if ([[FFSessionManager shared].currentCategoryName isEqualToString:FANTASY_SPORTS]) {
        return [self.dataSource allPositions].count;
    } else {
        return 5;
    }
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            if ([[FFSessionManager shared].currentCategoryName isEqualToString:FANTASY_SPORTS]) {
                //navigation bar height + status bar height = 64
                return [self isSomethingWrong] ? [UIScreen mainScreen].bounds.size.height - 64.f : 60.f;
            } else {
                return [self isSomethingWrong] ? [UIScreen mainScreen].bounds.size.height - 64.f : 70.f;
            }
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
                    } else if (([[FFSessionManager shared].currentCategoryName isEqualToString:FANTASY_SPORTS] && self.markets.count == 0) ||
                        ([[FFSessionManager shared].currentCategoryName isEqualToString:FANTASY_SPORTS] == NO && [self.dataSource availableGames].count == 0)) {
                        message = @"No Games Scheduled";
                    }
                      
                    cell.message.text = message;
                    return cell;
                }
                
                if ([[FFSessionManager shared].currentCategoryName isEqualToString:FANTASY_SPORTS]) {
                    return [self provideMarketsCellForTable:tableView atIndexPath:indexPath];
                } else {
                    return [self provideAutoFillCellForTable:tableView atIndexPath:indexPath];
                }
            }
            
            return [self provideAutoFillCellForTable:tableView atIndexPath:indexPath];
        }
            
        case 1: {
            if ([[FFSessionManager shared].currentCategoryName isEqualToString:FANTASY_SPORTS]) {
                NSString* positionName = [self.dataSource allPositions][indexPath.row];
                NSMutableDictionary *position = [[self.dataSource team] objectAtIndex:indexPath.row];
                
                if ([position[@"player"] isKindOfClass:[FFPlayer class]]) {
                    FFPlayer *player = [self.dataSource.currentRoster playerByName:[(FFPlayer *)position[@"player"] name]];
                    
                    if (!player) {
                        return [self provideTeamCellWithPosition:positionName forTable:tableView atIndexPath:indexPath];
                    }
                    
                    return [self provideTeamTradeCellWithPlayer:player forTable:tableView atIndexPath:indexPath];
                } else {
                    return [self provideTeamCellWithPosition:positionName forTable:tableView atIndexPath:indexPath];
                }
            } else {
                if ([self.dataSource teams].count > 0 && [self.dataSource teams].count >= indexPath.row + 1) {
                    return [self provideNonFantasyTeamTradeCellForTable:tableView atIndexPath:indexPath];
                }
                
                return [self provideNonFantasyTeamCellForTable:tableView atIndexPath:indexPath];
            }
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
        if ([[FFSessionManager shared].currentCategoryName isEqualToString:FANTASY_SPORTS]) {
            NSString* position = [self.dataSource allPositions][indexPath.row];
            [self.delegate showPosition:position];
        } else {
            [self.delegate showAvailableGames];
        }
    }
}

- (UIView *)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        FFRosterTableHeader* view = [FFRosterTableHeader new];
        NSString *title = nil;
        if ([[FFSessionManager shared].currentCategoryName isEqualToString:FANTASY_SPORTS]) {
            title = @"Your Team";
        } else {
            title = @"Your choices";
        }
        view.titleLabel.text = title;
        if ([[FFSessionManager shared].currentCategoryName isEqualToString:FANTASY_SPORTS]) {
            view.priceLabel.text = [[FFStyle priceFormatter] stringFromNumber:@(self.dataSource.currentRoster.remainingSalary.floatValue)];
            view.priceLabel.textColor = self.dataSource.currentRoster.remainingSalary.floatValue > 0.f
            ? [FFStyle brightGreen] : [FFStyle brightRed];            
        }
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
    if ([[FFSessionManager shared].currentCategoryName isEqualToString:FANTASY_SPORTS]) {
        FFRosterSubmitType rosterType = (FFRosterSubmitType)segments.selectedSegmentIndex;
        [self submitRoster:rosterType];
        self.submitView.segments.selectedSegmentIndex = UISegmentedControlNoSegment;
    } else {
        [self submitRoster:0];
    }
    
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
            if ([[FFSessionManager shared].currentCategoryName isEqualToString:FANTASY_SPORTS]) {
                [[[FFAlertView alloc] initWithTitle:nil
                                            message:self.dataSource.currentRoster.messageAfterSubmit
                                  cancelButtonTitle:nil
                                    okayButtonTitle:@"Ok"
                                           autoHide:YES]
                 showInView:self.navigationController.view];
            } else {
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];                
            }
        }
    }];
}

#pragma mark - FFMarketSelectorDataSource

- (NSArray*)markets
{
    return [self.dataSource availableMarkets];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.markets.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
                 cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    FFCollectionMarketCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MarketCell"
                                                                             forIndexPath:indexPath];
    if (self.markets.count > indexPath.item && self.networkStatus != NotReachable) {
        FFMarket* market = self.markets[indexPath.item];
        cell.marketLabel.text = market.name && market.name.length > 0 ? market.name : @"Market";
        cell.timeLabel.text = [[FFStyle marketDateFormatter] stringFromDate:market.startedAt];
    }
    
    return cell;
}

#pragma mark - FFMarketSelectorDelegate

- (void)marketSelected:(FFMarket*)selectedMarket
{
    [self.dataSource setCurrentMarket:selectedMarket];
    self.tryCreateRosterTimes = 3;
}

@end
