//
//  FFHomeViewController.m
//  FMF Football
//
//  Created by Samuel Sutch on 9/17/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import "FFHomeViewController.h"
#import "FFSessionViewController.h"
#import "FFMarket.h"
#import "FFMarketSelector.h"
#import "FFUserBitView.h"
#import "FFGameButtonView.h"
#import "FFContestType.h"
#import "FFContest2UpTabelViewCell.h"
#import "FFContestViewController.h"
#import "FFCreateGameViewController.h"
#import "FFAlertView.h"
#import "FFWebViewController.h"
#import "FFNavigationBarItemView.h"
#import "FFMarketSet.h"

@interface FFHomeViewController ()
    <SBDataObjectResultSetDelegate, UITableViewDataSource, UITableViewDelegate,
     FFMarketSelectorDelegate, FFGameButtonViewDelegate, FFContest2UpTableViewCellDelegate,
     FFCreateGameViewControllerDelegate>

@property(nonatomic) FFMarketSet* markets;
@property(nonatomic) UITableView* tableView;
@property(nonatomic) FFMarketSelector* marketSelector;
@property(nonatomic) FFUserBitView* userBit;
@property(nonatomic) FFGameButtonView* gameButtonView;
@property(nonatomic) SBDataObjectResultSet* contests;
@property(nonatomic) UIButton* globalMenuButton;
@property(nonatomic) NSArray* filteredContests;

@end

@implementation FFHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // UI customization
    FFNavigationBarItemView* leftItem = [[FFNavigationBarItemView alloc] initWithFrame:[FFStyle leftItemRect]];
    self.globalMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.globalMenuButton setImage:[UIImage imageNamed:@"globalmenu.png"]
                           forState:UIControlStateNormal];
    [self.globalMenuButton addTarget:self
                              action:@selector(globalMenuButton:)
                    forControlEvents:UIControlEventTouchUpInside];

    self.globalMenuButton.contentMode = UIViewContentModeScaleAspectFit;

    self.globalMenuButton.frame = [FFStyle leftItemRect];
    [leftItem addSubview:self.globalMenuButton];

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        UIBarButtonItem* spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                   target:nil
                                                                                   action:NULL];
        spaceItem.width = -16.f;
        self.navigationItem.leftBarButtonItems = @[
            spaceItem,
            [[UIBarButtonItem alloc] initWithCustomView:leftItem]
        ];
    } else {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftItem];
    }

//    UIButton* balanceView = [FFBalanceButton buttonWithDataSource:self.sessionController];
//    [balanceView addTarget:self
//                    action:@selector(showBalance:)
//          forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:balanceView];
    // table view
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_tableView];
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        [_tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
        id topGuide = self.topLayoutGuide;
        NSDictionary* viewsDictionary = NSDictionaryOfVariableBindings(_tableView, topGuide);
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide][_tableView]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:viewsDictionary]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:viewsDictionary]];
    } else {
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerClass:[UITableViewCell class]
        forCellReuseIdentifier:@"MarketSelectorCell"];
    [_tableView registerClass:[UITableViewCell class]
        forCellReuseIdentifier:@"UserBitCell"];
    [_tableView registerClass:[FFContest2UpTabelViewCell class]
        forCellReuseIdentifier:@"ContestCell"];
    // market selector
    _marketSelector = [[FFMarketSelector alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    _marketSelector.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _marketSelector.delegate = self;

    _gameButtonView = [[FFGameButtonView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    _gameButtonView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self showInDrawerMaximizedController:self.maximizedTicker
              withMinimizedViewController:self.minimizedTicker
                          resizeTableView:self.tableView
                                 animated:YES];

    [self.tickerDataSource refresh];

    _markets = [FFMarket getBulkWithSession:self.session
                                 authorized:YES];
    _markets.delegate = self;

    [self updateMarkets];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdateUser:)
                                                 name:FFSessionDidUpdateUserNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (IS_SMALL_DEVICE && !self.drawerIsMinimized) {
        [self minimizeDrawerAnimated:YES];
    }
}

#pragma mark -

- (void)showBalance:(UIButton*)seder
{
    [self performSegueWithIdentifier:@"GotoTokenPurchase"
                              sender:nil];
}

- (void)updateMarkets
{
    _markets.clearsCollectionBeforeSaving = YES;
    [_markets fetchType:FFMarketTypeRegularSeason];
    _markets.clearsCollectionBeforeSaving = NO;
    [_markets fetchType:FFMarketTypeSingleElimination];
    _marketSelector.markets = [FFMarket filteredMarkets:_markets.allObjects];
    [_tableView reloadData];
}

- (void)didUpdateUser:(NSNotification*)note
{
    [self performSelectorOnMainThread:@selector(updateUserCell)
                           withObject:nil
                        waitUntilDone:NO];
}

- (void)updateUserCell
{
    [self.tableView reloadRowsAtIndexPaths:@[
                                               [NSIndexPath indexPathForRow:0
                                                                  inSection:0]
                                           ]
                          withRowAnimation:UITableViewRowAnimationNone];
}

- (void)finishInProgressRoster:(id)sender
{
    FFRoster* rost = [(FFUser*)self.session.user getInProgressRoster];
    if (rost) {
        FFAlertView* loading = [[FFAlertView alloc] initWithTitle:NSLocalizedString(@"Loading", nil)
                                                         messsage:nil
                                                     loadingStyle:FFAlertViewLoadingStylePlain];
        [loading showInView:self.navigationController.view];
        [rost refreshInBackgroundWithBlock:^(id successObj)
        {
            [loading hide];
            [self performSegueWithIdentifier:@"GotoRoster"
                                      sender:nil
                                     context:successObj];
        }
    failure:
        ^(NSError * error)
        {
            [loading hide];
            FFAlertView* ealert = [[FFAlertView alloc] initWithError:error
                                                               title:nil
                                                   cancelButtonTitle:nil
                                                     okayButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                            autoHide:YES];
            [ealert showInView:self.navigationController.view];
        }];
    }
}

- (void)globalMenuButton:(UIButton*)button
{
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    NSString* baseUrl = [[NSBundle mainBundle] objectForInfoDictionaryKey:SBApiBaseURLKey];
    if ([segue.identifier isEqualToString:@"GotoContest"]) {
        ((FFContestViewController*)segue.destinationViewController).contest = segue.context[0];
        ((FFContestViewController*)segue.destinationViewController).market = segue.context[1];
    } else if ([segue.identifier isEqualToString:@"GotoCreateGame"]) {
        ((FFCreateGameViewController*)[segue.destinationViewController viewControllers][0]).delegate = self;
    } else if ([segue.identifier isEqualToString:@"GotoRoster"]) {
        FFRoster* roster = segue.context;
        ((FFContestViewController*)segue.destinationViewController).roster = roster;
    } else if ([segue.identifier isEqualToString:@"GotoRules"]) {
        FFWebViewController* vc = [segue.destinationViewController viewControllers][0];
        vc.URL = [NSURL URLWithString:[baseUrl stringByAppendingString:@"/pages/mobile/rules"]];
    } else if ([segue.identifier isEqualToString:@"GotoTerms"]) {
        FFWebViewController* vc = [segue.destinationViewController viewControllers][0];
        vc.URL = [NSURL URLWithString:[baseUrl stringByAppendingString:@"/pages/mobile/terms"]];
    } else if ([segue.identifier isEqualToString:@"GotoSupport"]) {
        FFWebViewController* vc = [segue.destinationViewController viewControllers][0];
        vc.URL = [NSURL URLWithString:[baseUrl stringByAppendingString:@"/pages/mobile/support"]];
    }
}

- (void)performSegueWithIdentifier:(NSString*)identifier sender:(id)sender context:(id)context
{
    if ([identifier isEqualToString:@"GotoRoster"]) {
        FFRoster* roster = context;
        if (!roster.market) {
            FFAlertView* alert = [[FFAlertView alloc] initWithTitle:NSLocalizedString(@"Loading...", nil)
                                                           messsage:nil
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
            [alert showInView:self.navigationController.view];
            [FFMarket get:roster.marketId session:self.session success:^(id successObj)
            {
                roster.market = successObj;
                [roster save];
                [alert hide];
                [super performSegueWithIdentifier:identifier
                                           sender:sender
                                          context:context];
            }
        failure:
            ^(NSError * error)
            {
                [alert hide];
                FFAlertView* ealert = [[FFAlertView alloc] initWithError:error
                                                                   title:nil
                                                       cancelButtonTitle:nil
                                                         okayButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                                autoHide:YES];
                [ealert showInView:self.navigationController.view];
            }];
        } else {
            [super performSegueWithIdentifier:identifier
                                       sender:sender
                                      context:context];
        }
    } else {
        [super performSegueWithIdentifier:identifier
                                   sender:sender
                                  context:context];
    }
}

- (void)hideMenuController
{
}

#pragma mark - ffcreategame controller delegate

- (void)createGameControllerDidCreateGame:(FFRoster*)roster
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
    [self performSegueWithIdentifier:@"GotoRoster"
                              sender:self
                             context:roster];
}

#pragma mark - ffcontest cell delegate

- (void)didChooseContest:(FFContestType*)contest
{
    [self performSegueWithIdentifier:@"GotoContest"
                              sender:self
                             context:@[
                                         contest,
                                         _marketSelector.selectedMarket
                                     ]];
}

#pragma mark - GameButtonViewDelegate

- (void)gameButtonViewCreateGame
{
    if (self.markets.count > 0) {
        [self performSegueWithIdentifier:@"GotoCreateGame"
                                  sender:self];
        return;
    }
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry", nil)
                                message:NSLocalizedString(@"There no games available now", nil)
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                      otherButtonTitles:nil] show];
}

- (void)gameButtonViewJoinGame
{
    [self performSegueWithIdentifier:@"GotoMyGames"
                              sender:self];
}

#pragma mark - FFMarketSelectorDelegate

- (void)didUpdateToNewMarket:(FFMarket*)market
{
    if (!self.session) {
        return;
    }
    if (_contests) {
        _contests.delegate = nil;
        _contests = nil;
    }

    NSString* path = [NSString stringWithFormat:@"/contests/for_market/%@", market.objId];

    SBModelQuery* query = [[[[self.session queryBuilderForClass:[FFContestType class]]
                                 property:@"marketId"
                                isEqualTo:market.objId]
                                property:@"takesTokens"
                               isEqualTo:@"1"] query];

    _contests = [FFContestType getBulkPath:path
                                cacheQuery:query
                               withSession:self.session
                                authorized:YES];
    _contests.delegate = self;
    [_contests refresh];

    _filteredContests = [_contests allObjects];
}

#pragma mark - SBDataobjectResultSetDelegate

- (void)resultSetDidReload:(SBDataObjectResultSet*)resultSet
{
    if (resultSet == _markets) {
        _marketSelector.markets = [FFMarket filteredMarkets:[resultSet allObjects]];
    } else if (resultSet == _contests) {
        // the server does not filter, and the result set by defaults shows what the server shows, hence we must
        // do our own pass of filtering to show only takesTokens==True contest types
        NSMutableArray* filtered = [NSMutableArray array];
        for (FFContestType* contest in [_contests allObjects]) {
            if ([contest.takesTokens integerValue]) {
                [filtered addObject:contest];
            }
        }
        _filteredContests = filtered;

        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - FFMenuViewControllerDelegate

- (void)didUpdateToNewSport:(FFMarketSport)sport
{
    [self hideMenuController];
    _markets.sport = sport;
    [self updateMarkets];
}

- (FFMarketSport)currentMarketSport
{
    return _markets.sport;
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
        return 3;
    }
    if (_filteredContests && [_filteredContests count]) {
        return [_filteredContests count] / 2 + [_filteredContests count] % 2;
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"UserBitCell"
                                                   forIndexPath:indexPath];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MarketSelectorCell"
                                                   forIndexPath:indexPath];
        }
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

        UIView* sep = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(cell.contentView.frame) - 1, 300, 1)];
        sep.backgroundColor = [FFStyle tableViewSeparatorColor];
        sep.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;

        if (indexPath.row == 0) {
            FFUser* user = (FFUser*)self.session.user;
            CGFloat height = 122;
            if (user.inProgressRoster != nil) {
                height = 162;
            }
            FFUserBitView* userBit = [[FFUserBitView alloc] initWithFrame:CGRectMake(0, 0, 320, height)];
            userBit.user = (FFUser*)self.session.user;
            [userBit.inProgressRosterButton addTarget:self
                                               action:@selector(finishInProgressRoster:)
                                     forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:userBit];
        } else if (indexPath.row == 1) {
            [cell.contentView addSubview:_marketSelector];
        } else if (indexPath.row == 2) {
            [cell.contentView addSubview:_gameButtonView];
        }
        [cell.contentView addSubview:sep];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ContestCell"
                                               forIndexPath:indexPath];
        FFContest2UpTabelViewCell* c_cell = (FFContest2UpTabelViewCell*)cell;
        c_cell.delegate = self;
        NSMutableArray* contests = [NSMutableArray arrayWithObject:[_filteredContests objectAtIndex:indexPath.row * 2]];
        if ((indexPath.row * 2 + 1) != _filteredContests.count) {
            [contests addObject:[_filteredContests objectAtIndex:indexPath.row * 2 + 1]];
        }
        c_cell.contests = contests;
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView
    heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section != 0) {
        return 145;
    }
    switch (indexPath.row) {
    case 0: {
        FFUser* user = (FFUser*)self.session.user;
        if (user.inProgressRoster != nil) {
            return 162;
        }
        return 122;
    } break;
    case 2:
        return 58.f;
    default:
        return 60.f;
    }
}

- (BOOL)tableView:(UITableView*)tableView
    shouldHighlightRowAtIndexPath:(NSIndexPath*)indexPath
{
    return indexPath.row >= 3;
}

@end
