//
//  FFPagerController.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/13/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFPagerController.h"
#import "FFMenuViewController.h"
#import "FFYourTeamController.h"
#import "FFWideReceiverController.h"
#import "FFPTController.h"
#import "FFWCController.h"
#import "FFStyle.h"
#import "StyledPageControl.h"
#import "FFNavigationBarItemView.h"
#import "FFLogo.h"
#import "FFWebViewController.h"
#import "FFAlertView.h"

#import "Reachability.h"
// model
#import "FFControllerProtocol.h"
#import "FFYourTeamDataSource.h"
#import "FFMarketSet.h"
#import "FFMarket.h"
#import "FFEvent.h"
#import "FFSessionViewController.h"
#import "FFMarketSelector.h"
#import "FFContestType.h"
#import "FFRoster.h"
#import "FFPlayer.h"
#import "FFTeam.h"
#import "FFNonFantasyGame.h"
#import "FFSessionManager.h"
#import "FFWCManager.h"
#import <SBData/SBTypes.h>

#import "FFFantasyManager.h"
#import "FFNonFantasyManager.h"

@interface FFPagerController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, FFControllerProtocol,
FFUserProtocol, FFMenuViewControllerDelegate, FFEventsProtocol>
{
    __block BOOL _rosterIsCreating;
}

@property(nonatomic) StyledPageControl* pager;
@property(nonatomic) FFYourTeamController* teamController;
@property(nonatomic) FFWideReceiverController* receiverController;

@property(nonatomic) FFWCController* dailyWinsController;
@property(nonatomic) FFWCController* mvpController;
@property(nonatomic) FFWCController* cupWinnerController;
@property(nonatomic) FFWCController* groupWinnerController;

@property(nonatomic) UIButton* globalMenuButton;
@property(nonatomic) NSDictionary* positionsNames;

@property(nonatomic, assign) NetworkStatus networkStatus;
@property(nonatomic, assign) BOOL isFirstLaunch;

@property(nonatomic) FFMarketSet* marketsSetRegular;
@property(nonatomic) FFMarketSet* marketsSetSingle;

@property(nonatomic, strong) NSArray* markets;
@property(nonatomic) FFMarket* selectedMarket;

@property(nonatomic, strong) NSMutableArray *myTeam;
@property(nonatomic, strong) FFRoster* roster;
@property(nonatomic, assign) NSUInteger tryCreateRosterTimes;

@property(nonatomic, strong) NSMutableArray *games;
@property(nonatomic, strong) NSMutableArray *selectedTeams;

@property(nonatomic, assign) BOOL unpaid;

@end

@implementation FFPagerController

@synthesize session;

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.positionsNames = @{};
        self.selectedTeams = [NSMutableArray array];
        self.view.backgroundColor = [FFStyle darkGreen];
        self.dataSource = self;
        self.delegate = self;
        self.teamController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                         bundle:[NSBundle mainBundle]]
                               instantiateViewControllerWithIdentifier:@"TeamController"];
        self.receiverController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                             bundle:[NSBundle mainBundle]]
                                   instantiateViewControllerWithIdentifier:@"ReceiverController"];

        self.teamController.delegate = self;
        self.teamController.dataSource = self;
        self.receiverController.delegate = self;
        self.receiverController.dataSource = self;
        
        self.dailyWinsController = [[FFWCController alloc] init];
        self.cupWinnerController = [[FFWCController alloc] init];
        self.groupWinnerController = [[FFWCController alloc] init];
        self.mvpController = [[FFWCController alloc] init];
        
        self.dailyWinsController.dataSource = self;
        self.cupWinnerController.dataSource = self;
        self.groupWinnerController.dataSource = self;
        self.mvpController.dataSource = self;
        
        self.isFirstLaunch = YES;
        _rosterIsCreating = NO;
        
        self.myTeam = [NSMutableArray array];
        self.games = [NSMutableArray array];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // navigation bar style
    self.navigationController.navigationBar.translucent = NO;
    // iOS 7 fix
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.f) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    // pager
    self.pager = StyledPageControl.new;
    self.pager.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.pager.frame = CGRectMake(0.f,
                                  self.view.bounds.size.height - 39.f,
                                  self.view.bounds.size.width,
                                  44.f);
    self.pager.gapWidth = 2;
    self.pager.pageControlStyle = PageControlStyleThumb;
    self.pager.thumbImage = [UIImage imageNamed:@"passive"];
    self.pager.selectedThumbImage = [UIImage imageNamed:@"active"];
    self.pager.userInteractionEnabled = NO;
    [self.view addSubview:self.pager];
    [self.view bringSubviewToFront:self.pager];
    // left bar item
    FFNavigationBarItemView* leftItem = [[FFNavigationBarItemView alloc] initWithFrame:[FFStyle itemRect]];
    self.globalMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.globalMenuButton setImage:[UIImage imageNamed:@"globalmenu"]
                           forState:UIControlStateNormal];
    [self.globalMenuButton setImage:[UIImage imageNamed:@"globalmenu-highlighted"]
                             forState:UIControlStateHighlighted];
    [self.globalMenuButton addTarget:self
                              action:@selector(globalMenuButton:)
                    forControlEvents:UIControlEventTouchUpInside];
    self.globalMenuButton.contentMode = UIViewContentModeScaleAspectFit;
    self.globalMenuButton.frame = [FFStyle itemRect];
    [leftItem addSubview:self.globalMenuButton];
    // iOS 7 fix
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
    // title
    self.navigationItem.titleView = [[FFLogo alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 44.f)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // session
    self.teamController.session = self.session;
    self.receiverController.session = self.session;
    self.cupWinnerController.session = self.session;
    self.groupWinnerController.session = self.session;
    self.dailyWinsController.session = self.session;
    self.mvpController.session = self.session;
    
    // get player position names
//    if ([[[FFSessionManager shared] currentCategoryName] isEqualToString:FANTASY_SPORTS]) {
//        [self fetchPositionsNames];        
//    }
    
    if (self.isFirstLaunch) {
        if ([[[FFSessionManager shared] currentCategoryName] isEqualToString:FANTASY_SPORTS]) {
//            self.marketsSetRegular = [[FFMarketSet alloc] initWithDataObjectClass:[FFMarket class]
//                                                                          session:self.session authorized:YES];
//            self.marketsSetSingle = [[FFMarketSet alloc] initWithDataObjectClass:[FFMarket class]
//                                                                         session:self.session authorized:YES];
//            self.marketsSetRegular.delegate = self;
//            self.marketsSetSingle.delegate = self;
//            [self updateMarkets];
            self.del = [FFFantasyManager shared];
            [[FFFantasyManager shared] setupWithSession:self.session andPagerController:self];
            
        } else if ([[[FFSessionManager shared] currentCategoryName] isEqualToString:@"sports"]) {
            if ([[[FFSessionManager shared] currentSportName] isEqualToString:FOOTBALL_WC]) {
                [self getWorldCupData];
            } else {
//                [self updateGames];
                self.del = [FFNonFantasyManager shared];
                [[FFNonFantasyManager shared] setupWithSession:self.session andPagerController:self];
            }
        }
        
        if ([[[FFSessionManager shared] currentSportName] isEqualToString:FOOTBALL_WC] == NO) {
            [self setViewControllers:@[[self.del getViewControllers].firstObject]
                           direction:UIPageViewControllerNavigationDirectionForward
                            animated:NO
                          completion:nil];            
        }
        
        [self.view bringSubviewToFront:self.pager];
    }
    
    self.isFirstLaunch = NO;
    
//    self.pager.numberOfPages = (int)[self.del getViewControllers].count;
//    self.pager.currentPage = (int)[[self.del getViewControllers] indexOfObject:self.viewControllers.firstObject];
    
    internetReachability = [Reachability reachabilityForInternetConnection];
	BOOL success = [internetReachability startNotifier];
	if ( !success )
		DLog(@"Failed to start notifier");
    self.networkStatus = [internetReachability currentReachabilityStatus];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
}

- (void)checkNetworkStatus:(NSNotification *)notification
{
    NetworkStatus internetStatus = [internetReachability currentReachabilityStatus];
    NetworkStatus previousStatus = self.networkStatus;
    
    if (internetStatus != self.networkStatus) {
        self.networkStatus = internetStatus;
        
        if ((internetStatus != NotReachable && previousStatus == NotReachable) ||
            (internetStatus == NotReachable && previousStatus != NotReachable)) {
            if (internetStatus != NotReachable) {
                if ([[FFSessionManager shared].currentCategoryName isEqualToString:FANTASY_SPORTS]) {
//                    [self fetchPositionsNames];
//                    [self updateMarkets];
                } else {
                    if ([[FFSessionManager shared].currentSportName isEqualToString:FOOTBALL_WC]) {
                        [self getWorldCupData];
                    } else {
//                        [self updateGames];
                    }
                }
            } else {
                [self.games removeAllObjects];
            }
        }
    }    
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue
                 sender:(id)sender
{
    id <FFControllerProtocol> vc = segue.destinationViewController;
    if ([vc conformsToProtocol:@protocol(FFControllerProtocol)]) {
        vc.session = self.session;
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        vc = [(UINavigationController*)vc viewControllers].firstObject;
        if ([vc conformsToProtocol:@protocol(FFControllerProtocol)]) {
            vc.session = self.session;
        }
    } // TODO: maybe move session handling to Base controller too?
    if ([segue.identifier isEqualToString:@"GotoMenu"]) {
        FFMenuViewController* vc = segue.destinationViewController;
        vc.delegate = self;
    } else if ([segue.identifier isEqualToString:@"GotoPT"]) {
        FFPTController* vc = segue.destinationViewController;
        vc.delegate = self;
        vc.player = (FFPlayer*)sender;
    } else if ([segue.identifier isEqualToString:@"GotoPredictions"]) {
        // TODO: implement
    } else {
        NSString* baseUrl = [[NSBundle mainBundle] objectForInfoDictionaryKey:SBApiBaseURLKey];
        if ([segue.identifier isEqualToString:@"GotoRules"]) {
            FFWebViewController* vc = [segue.destinationViewController viewControllers].firstObject;
            NSString* sport = [FFSessionManager shared].currentSportName;
            vc.URL = [NSURL URLWithString:[baseUrl stringByAppendingFormat:@"/pages/mobile/rules?sport=%@", sport]];
        } else if ([segue.identifier isEqualToString:@"GotoSupport"]) {
            FFWebViewController* vc = [segue.destinationViewController viewControllers].firstObject;
            vc.URL = [NSURL URLWithString:[baseUrl stringByAppendingString:@"/pages/mobile/terms"]];
        }
    }
}

- (NSArray*)getViewControllers
{
//    if ([[FFSessionManager shared].currentSportName isEqualToString:FOOTBALL_WC]) {
//        NSMutableArray *controllers = [NSMutableArray array];
//        if (self.dailyWinsController.candidates.count > 0 || self.networkStatus == NotReachable) {
//            [controllers addObject:self.dailyWinsController];
//        }
//        if (self.cupWinnerController.candidates.count > 0 || self.networkStatus == NotReachable) {
//            [controllers addObject:self.cupWinnerController];
//        }
//        if (self.groupWinnerController.candidates.count > 0 || self.networkStatus == NotReachable) {
//            [controllers addObject:self.groupWinnerController];
//        }
//        if (self.mvpController.candidates.count > 0 || self.networkStatus == NotReachable) {
//            [controllers addObject:self.mvpController];
//        }
//        
//        return [NSArray arrayWithArray:controllers];
//    } else {
//        return @[
//                 self.teamController,
//                 self.receiverController
//                 ];
//    }
    return [self.del getViewControllers];
}

#pragma mark - button actions

- (void)globalMenuButton:(UIButton*)button
{
    [self performSegueWithIdentifier:@"GotoMenu"
                              sender:nil];
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
     viewControllerBeforeViewController:(UIViewController*)viewController
{
    NSUInteger index = [[self.del getViewControllers] indexOfObject:viewController];
    if (index == NSNotFound) {
        WTFLog;
        return nil;
    }
    if (index == 0) {
        return nil;
    }
    return [self.del getViewControllers][--index];
}

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
      viewControllerAfterViewController:(UIViewController*)viewController
{
    NSUInteger index = [[self.del getViewControllers] indexOfObject:viewController];
    if (index == NSNotFound) {
        WTFLog;
        return nil;
    }
    if (index == [self.del getViewControllers].count - 1) {
        return nil;
    }
    return [self.del getViewControllers][++index];
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed
{
    // TODO: on appear
    if (!completed) {
        return;
    }
    self.pager.currentPage = (int)[[self.del getViewControllers] indexOfObject:
                                   self.viewControllers.firstObject];
    
    if ([[FFSessionManager shared].currentCategoryName isEqualToString:FANTASY_SPORTS]) {
        //should update players list after swipe as in bug MLB-156
        if (self.pager.currentPage == 1) {
            [self.receiverController fetchPlayersWithShowingAlert:YES completion:^{
                [self.receiverController reloadWithServerError:NO];
            }];
        }
    }
}

- (void)pageViewController:(UIPageViewController*)pageViewController
willTransitionToViewControllers:(NSArray*)pendingViewControllers
{
    // TODO: on desappear
}

#pragma mark - FFMenuViewControllerDelegate

- (void)performMenuSegue:(NSString*)ident
{
    [self performSegueWithIdentifier:ident
                              sender:nil];
}

- (void)didUpdateToCategory:(NSString *)category sport:(NSString *)sport
{
    BOOL shouldSetController = NO;
    if ([[FFSessionManager shared].currentSportName isEqualToString:FOOTBALL_WC] == YES && [sport isEqualToString:FOOTBALL_WC] == NO) {
        shouldSetController = YES;
    }
    
    [[FFSessionManager shared] saveCurrentCategory:category andSport:sport];
    
//    if (shouldSetController) {
//        [self setViewControllers:@[[self.del getViewControllers].firstObject]
//                       direction:UIPageViewControllerNavigationDirectionForward
//                        animated:NO
//                      completion:nil];
//    }
    
    if ([category isEqualToString:FANTASY_SPORTS]) {
//        [self.teamController updateSubmitViewType];
//        [self.receiverController resetPosition];
//        [self updateMarkets];
        self.del = [FFFantasyManager shared];
        [[FFFantasyManager shared] setupWithSession:self.session andPagerController:self];
    } else if ([category isEqualToString:@"sports"]) {
        if ([sport isEqual:FOOTBALL_WC]) {
            [self getWorldCupData];
        } else {
            self.del = [FFNonFantasyManager shared];
            [[FFNonFantasyManager shared] setupWithSession:self.session andPagerController:self];
//            [self.teamController updateSubmitViewType];
//            [self.selectedTeams removeAllObjects];
//            [self updateGames];
        }
    }
    
//    [self setViewControllers:@[[self.del getViewControllers].firstObject]
//                   direction:UIPageViewControllerNavigationDirectionForward
//                    animated:NO
//                  completion:nil];
    
}

- (void)logout
{
    [self.session logout];
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:nil];
}


#pragma mark - FFEventsProtocol

- (NSString*)marketId
{
    return self.selectedMarket.objId;
}

#pragma mark -

- (void)getWorldCupData
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    __block FFAlertView *alert = [[FFAlertView alloc] initWithTitle:@""
                                                           messsage:nil
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.navigationController.view];
    
    [[FFWCManager shared] fetchDataForSession:self.session
                           dataWithCompletion:^(BOOL success) {
                               if (success) {
                                   self.cupWinnerController.category = FFWCCupWinner;
                                   self.cupWinnerController.candidates = [NSArray arrayWithArray:[FFWCManager shared].cupWinners];
                                   
                                   self.groupWinnerController.category = FFWCGroupWinners;
                                   self.groupWinnerController.candidates = [NSArray arrayWithArray:[FFWCManager shared].groupWinners];
                                   self.groupWinnerController.selectedCroupIndex = 0;
                                   
                                   self.dailyWinsController.category = FFWCDailyWins;
                                   self.dailyWinsController.candidates = [NSArray arrayWithArray:[FFWCManager shared].dailyWins];
                                   
                                   self.mvpController.category = FFWCMvp;
                                   self.mvpController.candidates = [NSArray arrayWithArray:[FFWCManager shared].mvpCandidates];       
                               }
                               __weak FFPagerController *weakSelf = self;
                               [self setViewControllers:@[[self.del getViewControllers].firstObject]
                                              direction:UIPageViewControllerNavigationDirectionForward
                                               animated:NO
                                             completion:^(BOOL finished) {
                                                 if (finished) {
                                                     weakSelf.pager.numberOfPages = (int)[weakSelf.del getViewControllers].count;
                                                     weakSelf.pager.currentPage = (int)[[weakSelf.del getViewControllers] indexOfObject:weakSelf.viewControllers.firstObject];
                                                     
                                                     [weakSelf.dailyWinsController.tableView reloadData];
                                                     [weakSelf.cupWinnerController.tableView reloadData];
                                                     [weakSelf.groupWinnerController.tableView reloadData];
                                                     [weakSelf.mvpController.tableView reloadData];
                                                 }
                                             }];
                               
                               [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                               [alert hide];
                           }];
}

@end
