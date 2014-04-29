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
#import "FFSubmitView.h"
#import "FFAlertView.h"
#import "FFRosterTableHeader.h"
#import "FFAccountHeader.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "FFPathImageView.h"
#import "FFMarketSelector.h"
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

@interface FFYourTeamController () <UITableViewDataSource, UITableViewDelegate,
FFMarketSelectorDelegate, FFMarketSelectorDataSource, SBDataObjectResultSetDelegate>
// models
@property(nonatomic) FFRoster* roster;
@property(nonatomic, assign) NSUInteger tryCreateRosterTimes;
@property(nonatomic) FFSubmitView* submitView;
@property(nonatomic) FFMarketSet* marketsSetRegular;
@property(nonatomic) FFMarketSet* marketsSetSingle;

@property(nonatomic, assign) NetworkStatus networkStatus;

@end

@implementation FFYourTeamController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // submit view
    self.submitView = [FFSubmitView new];
    [self.submitView.segments addTarget:self
                                 action:@selector(onSubmit:)
                       forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.submitView];
    // table view
    self.tableView = [FFTeamTable.alloc initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.view bringSubviewToFront:self.submitView];
    
    //refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [FFStyle lightGrey];
    [refreshControl addTarget:self action:@selector(pullToRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    //code from didMoveToParentViewController:
    self.marketsSetRegular = [[FFMarketSet alloc] initWithDataObjectClass:[FFMarket class]
                                                                  session:self.session authorized:YES];
    self.marketsSetSingle = [[FFMarketSet alloc] initWithDataObjectClass:[FFMarket class]
                                                               session:self.session authorized:YES];
    self.marketsSetRegular.delegate = self;
    self.marketsSetSingle.delegate = self;
    [self updateMarkets];
    // roster
    self.tryCreateRosterTimes = 3;
    [self createRoster];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    internetReachability = [Reachability reachabilityForInternetConnection];
	BOOL success = [internetReachability startNotifier];
	if ( !success )
		DLog(@"Failed to start notifier");
    self.networkStatus = [internetReachability currentReachabilityStatus];
    
    if (self.networkStatus == NotReachable) {
        self.tableView.userInteractionEnabled = NO;
        [self.tableView reloadData];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
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
//    NSLog(@"Create roster - #1");
//    [self createRoster];
//}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self shorOrHideSubmitIfNeeded];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kReachabilityChangedNotification object:nil];
    [super viewDidDisappear:animated];
}

#pragma mark -

- (void)pullToRefresh:(UIRefreshControl *)refreshControl
{
    [self refreshRosterWithShowingAlert:NO comletion:^{
        [self.tableView reloadData];
        [refreshControl endRefreshing];
    }];
}

#pragma mark -

- (void)checkNetworkStatus:(NSNotification *)notification
{
    NetworkStatus internetStatus = [internetReachability currentReachabilityStatus];
    
    if (internetStatus != self.networkStatus) {
        self.networkStatus = internetStatus;
        [self updateMarkets];
        
        if (internetStatus == NotReachable) {
            [self refreshRosterWithShowingAlert:NO comletion:^{
                [self.tableView reloadData];
//                self.tableView.userInteractionEnabled = NO;
            }];
        } else {
            self.tableView.userInteractionEnabled = YES;
        }
    }
}

#pragma mark - private

- (void)shorOrHideSubmitIfNeeded
{
    BOOL anyPlayer = self.roster.players.count > 0;
    CGFloat submitHeight = 70.f;
    [UIView animateWithDuration:(NSTimeInterval).3f
                     animations:
     ^{
         self.submitView.frame = CGRectMake(0.f,
                                            anyPlayer ? self.view.bounds.size.height - submitHeight
                                            : self.view.bounds.size.height,
                                            self.view.bounds.size.width,
                                            submitHeight);
         self.submitView.alpha = anyPlayer ? 1.f : 0.f;
         self.submitView.userInteractionEnabled = anyPlayer;
         UIEdgeInsets tableInsets = self.tableView.contentInset;
         tableInsets.bottom = anyPlayer ? submitHeight : 0.f;
         self.tableView.contentInset = tableInsets;
     }];
}
- (NSArray*)positions
{
    return [self.roster.positions componentsSeparatedByString:@","];
}

#pragma mark - public

- (NSArray*)uniquePositions
{
    NSArray* positions = [self positions];
    // make unique
    NSMutableArray* unique = [NSMutableArray arrayWithCapacity:positions.count];
    NSMutableSet* processed = [NSMutableSet set];
    for (NSString* position in positions) {
        if ([processed containsObject:position]) {
            continue;
        }
        [unique addObject:position];
        [processed addObject:position];
    }
    return [unique copy];
}

- (void)createRoster
{
    if (!self.selectedMarket) {
        self.roster = nil;
        [self.tableView reloadData];
        [self shorOrHideSubmitIfNeeded];
        return;
    }
    __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:@""
                                                           messsage:nil
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.navigationController.view];
    @weakify(self)
    [FFRoster createNewRosterForMarket:self.selectedMarket.objId
                               session:self.session
                               success:
     ^(id successObj) {
         @strongify(self)
         self.roster = successObj;
         [self.tableView reloadData];
         [self shorOrHideSubmitIfNeeded];
         [alert hide];
     }
                               failure:
     ^(NSError * error) {
         @strongify(self)
         if (self.tryCreateRosterTimes > 0) {
             [alert hide];
             self.tryCreateRosterTimes--;
             [self createRoster];
         } else {
             self.roster = nil;
             [self.tableView reloadData];
             [alert hide];
             [self shorOrHideSubmitIfNeeded];
             /* !!!: disable error alerts NBA-659
             [[[FFAlertView alloc] initWithError:error
                                           title:nil
                               cancelButtonTitle:nil
                                 okayButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                        autoHide:YES]
              showInView:self.navigationController.view];
              */
         }
     }];
}

- (void)refreshRosterWithShowingAlert:(BOOL)shouldShow comletion:(void(^)(void))block
{
    __block FFAlertView* alert = nil;
    if (shouldShow) {
        alert = [[FFAlertView alloc] initWithTitle:@""
                                          messsage:nil
                                      loadingStyle:FFAlertViewLoadingStylePlain];
        [alert showInView:self.navigationController.view];
    }
    
    @weakify(self)
    [self.roster refreshInBackgroundWithBlock:
     ^(id successObj) {
         @strongify(self)
         self.roster = successObj;
         [self.tableView reloadData];
         [self shorOrHideSubmitIfNeeded];
         
         if (alert)
             [alert hide];
         if (block)
             block();
     }
                                      failure:
     ^(NSError *error) {
         @strongify(self)
         [alert hide];
         self.roster = nil;
         [self.tableView reloadData];
         [self shorOrHideSubmitIfNeeded];
         
         if (alert)
             [alert hide];
         if (block)
             block();
         /* !!!: disable error alerts NBA-659
          [[[FFAlertView alloc] initWithError:error
          title:nil
          cancelButtonTitle:nil
          okayButtonTitle:NSLocalizedString(@"Dismiss", nil)
          autoHide:YES]
          showInView:self.navigationController.view];
          */
     }];
}

- (void)marketsUpdated
{
    [self.tableView reloadData];
    if (self.markets.count > 0) {
        [self marketSelected:self.markets.firstObject];
    } else {
        self.selectedMarket = nil;
        [self createRoster];
    }
}

- (void)updateMarkets
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.marketsSetRegular fetchType:FFMarketTypeRegularSeason];
    [self.marketsSetSingle fetchType:FFMarketTypeSingleElimination];
}

- (void)submitRoster:(FFRosterSubmitType)rosterType
{
    __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:@"Submitting Roster"
                                                           messsage:nil
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.navigationController.view];
    @weakify(self)
    [self.roster submitContent:rosterType
                       success:
     ^(id successObj) {
         @strongify(self)
         [alert hide];
         [[[FFAlertView alloc] initWithTitle:nil
                                     message:self.roster.messageAfterSubmit
                           cancelButtonTitle:nil
                             okayButtonTitle:NSLocalizedString(@"Ok", nil)
                                    autoHide:YES]
          showInView:self.navigationController.view];
         [self createRoster];
     }
                       failure:
     ^(NSError * error) {
         @strongify(self)
         [self.tableView reloadData];
         [alert hide];
         [self shorOrHideSubmitIfNeeded];
         /* !!!: disable error alerts NBA-659
         [[[FFAlertView alloc] initWithError:error
                                       title:nil
                           cancelButtonTitle:nil
                             okayButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                    autoHide:YES]
          showInView:self.navigationController.view];
          */
     }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView*)tableView
    numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    return [self positions].count;
}

- (CGFloat)tableView:(UITableView*)tableView
    heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 60.f;
        }
        return 50.f;
    }
    return 80.f;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.section) {
    case 0: {
        if (indexPath.row == 0) {
            FFMarketsCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MarketsCell"
                                                                  forIndexPath:indexPath];
            cell.marketSelector.dataSource = self;
            cell.marketSelector.delegate = self;
            [cell.marketSelector reloadData];
            if (self.selectedMarket && self.markets && self.networkStatus != NotReachable) {
                _noGamesAvailable = NO;
                [cell hideStatusLabel];
                NSUInteger selectedMarket = [self.markets indexOfObject:self.selectedMarket];
                if (selectedMarket != NSNotFound) {
                    [cell.marketSelector updateSelectedMarket:selectedMarket
                                                     animated:NO] ;
                }
            } else if (self.markets.count == 0 || self.networkStatus == NotReachable) {
                NSString *message = nil;
                if (self.networkStatus == NotReachable) {
                    message = NSLocalizedString(@"NO INTERNET CONNECTION", nil);
                } else {
                    _noGamesAvailable = YES;
                    message = NSLocalizedString(@"NO GAMES SCHEDULED", nil);
                }
                
                [cell showStatusLabelWithMessage:message];
            }
            return cell;
        }
        FFAutoFillCell* cell = [tableView dequeueReusableCellWithIdentifier:@"AutoFillCell"
                                                               forIndexPath:indexPath];
        cell.autoRemovedBenched.on = self.roster.removeBenched.integerValue == 1;
        if (_noGamesAvailable == NO || self.networkStatus == NotReachable) {
            cell.autoRemovedBenched.enabled = YES;
            [cell.autoRemovedBenched addTarget:self
                                        action:@selector(autoRemovedBenched:)
                              forControlEvents:UIControlEventValueChanged];
            [cell.autoFillButton addTarget:self
                                    action:@selector(autoFill:)
                          forControlEvents:UIControlEventTouchUpInside];
        } else {
            cell.autoRemovedBenched.enabled = NO;
        }
        
        return cell;
    }
    case 1: {
        NSString* position = [self positions][indexPath.row];
        for (FFPlayer* player in self.roster.players) {
            if ([player.position isEqualToString:position]) {
                FFTeamTradeCell* cell = [tableView dequeueReusableCellWithIdentifier:@"TeamTradeCell"
                                                                        forIndexPath:indexPath];
                cell.titleLabel.text = player.team;
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
                cell.PTButton.hidden = benched;
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
            }
        }
        FFTeamCell* cell = [tableView dequeueReusableCellWithIdentifier:@"TeamCell"
                                                           forIndexPath:indexPath];
        cell.titleLabel.text = [NSString stringWithFormat:@"%@ %@", position,
                                NSLocalizedString(@"Not Selected", nil)];
        return cell;
    }
    default:
        return nil;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView
    didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (_noGamesAvailable)
        return;
    
    NSString* position = [self positions][indexPath.row];
    [self.delegate showPosition:position];
}

- (UIView *)tableView:(UITableView*)tableView
viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        FFRosterTableHeader* view = FFRosterTableHeader.new;
        view.titleLabel.text = NSLocalizedString(@"Your Team", nil);
        view.priceLabel.text = [[FFStyle priceFormatter] stringFromNumber:@(self.roster.remainingSalary.floatValue)];
        view.priceLabel.textColor = self.roster.remainingSalary.floatValue > 0.f
        ? [FFStyle brightGreen] : [FFStyle brightRed];
        return view;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView*)tableView
heightForHeaderInSection:(NSInteger)section
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
}

- (void)toggleRemoveBench:(FUISwitch*)sender
{
    __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:@"Toggle Auto-Remove Benched Players"
                                                           messsage:nil
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.navigationController.view];
    @weakify(self)
    [self.roster toggleRemoveBenchedSuccess:
     ^(id successObj) {
         @strongify(self)
         self.roster = successObj;
         [self.tableView reloadData];
         [self shorOrHideSubmitIfNeeded];
         [alert hide];
     }
                         failure:
     ^(NSError *error) {
         @strongify(self)
         [alert hide];
         self.roster = nil;
         [self.tableView reloadData];
         [self shorOrHideSubmitIfNeeded];
         /* !!!: disable error alerts NBA-659
         [[[FFAlertView alloc] initWithError:error
                                       title:nil
                           cancelButtonTitle:nil
                             okayButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                    autoHide:YES]
          showInView:self.navigationController.view];
          */
     }];
}

- (void)autoFill:(UIButton*)button
{
    if (_noGamesAvailable)
        return;
    
    __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:@"Auto Fill Roster"
                                                           messsage:nil
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.navigationController.view];
    @weakify(self)
    [self.roster autofillSuccess:
     ^(id successObj) {
         @strongify(self)
         self.roster = successObj;
         [self.tableView reloadData];
         [self shorOrHideSubmitIfNeeded];
         [alert hide];
     }
                         failure:
     ^(NSError *error) {
         @strongify(self)
         [alert hide];
         self.roster = nil;
         [self.tableView reloadData];
         [self shorOrHideSubmitIfNeeded];
         /* !!!: disable error alerts NBA-659
         [[[FFAlertView alloc] initWithError:error
                                       title:nil
                           cancelButtonTitle:nil
                             okayButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                    autoHide:YES]
          showInView:self.navigationController.view];
          */
     }];
}

- (void)removePlayer:(FFPlayer*)player
{
    __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:NSLocalizedString(@"Removing Player", nil)
                                                           messsage:nil
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.navigationController.view];
    @weakify(self)
    [self.roster removePlayer:player
                      success:
     ^(id successObj) {
         @strongify(self)
         [self shorOrHideSubmitIfNeeded];
         [alert hide];
         [self refreshRosterWithShowingAlert:YES comletion:^{
             [self.tableView reloadData];
         }];
         [self.delegate showPosition:player.position];
     }
                      failure:
     ^(NSError *error) {
         @strongify(self)
         [alert hide];
         [self shorOrHideSubmitIfNeeded];
         /* !!!: disable error alerts NBA-659
          [[[FFAlertView alloc] initWithError:error
          title:nil
          cancelButtonTitle:nil
          okayButtonTitle:NSLocalizedString(@"Dismiss", nil)
          autoHide:YES]
          showInView:self.navigationController.view];
          */
     }];
}

- (void)onSubmit:(FUISegmentedControl*)segments
{
    FFRosterSubmitType rosterType = (FFRosterSubmitType)segments.selectedSegmentIndex;
    [self submitRoster:rosterType];
    self.submitView.segments.selectedSegmentIndex = UISegmentedControlNoSegment;
}

#pragma mark - FFMarketSelectorDataSource

- (NSArray*)markets
{
    NSMutableArray* markets = [NSMutableArray arrayWithCapacity:self.marketsSetRegular.allObjects.count +
                               self.marketsSetSingle.allObjects.count];
    [markets addObjectsFromArray:self.marketsSetRegular.allObjects];
    [markets addObjectsFromArray:self.marketsSetSingle.allObjects];
    return [markets copy];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView
     numberOfItemsInSection:(NSInteger)section
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
        [cell showLabels];
        cell.marketLabel.text = market.name && market.name.length > 0 ? market.name : NSLocalizedString(@"Market", nil);
        cell.timeLabel.text = [[FFStyle marketDateFormatter] stringFromDate:market.startedAt];
    } else if (self.markets.count == 0 || self.networkStatus == NotReachable) {
        [cell hideLabels];
    }
    
    return cell;
}

#pragma mark - FFMarketSelectorDelegate

- (void)marketSelected:(FFMarket*)selectedMarket
{
    self.selectedMarket = selectedMarket;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0
                                                                inSection:0]]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    self.tryCreateRosterTimes = 3;
    [self createRoster];
}

#pragma mark - SBDataObjectResultSetDelegate

- (void)resultSetDidReload:(SBDataObjectResultSet*)resultSet
{
    [self marketsUpdated];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
