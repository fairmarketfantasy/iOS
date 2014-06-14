//
//  FFPagerController.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/13/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFPagerController.h"
#import "FFMenuViewController.h"
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
#import <SBData/SBTypes.h>

#import "FFManager.h"
#import "FFWCManager.h"
#import "FFFantasyManager.h"
#import "FFNonFantasyManager.h"


@interface FFPagerController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, FFControllerProtocol,
FFUserProtocol, FFMenuViewControllerDelegate, FFManagerDelegate>

@property (nonatomic, strong) StyledPageControl* pager;
@property (nonatomic, strong) UIButton* globalMenuButton;
@property (nonatomic, strong) FFManager *manager;
@property (nonatomic, assign) NetworkStatus networkStatus;
@property (nonatomic, assign) BOOL isFirstLaunch;
@property (nonatomic, assign) NSUInteger tryCreateRosterTimes;
@property (nonatomic, assign) BOOL unpaid;

@end

@implementation FFPagerController

@synthesize session;

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.view.backgroundColor = [FFStyle darkGreen];
        self.dataSource = self;
        self.delegate = self;
        
        self.isFirstLaunch = YES;
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
    
    if (self.isFirstLaunch) {
        if ([[[FFSessionManager shared] currentCategoryName] isEqualToString:FANTASY_SPORTS]) {
            self.manager = [[FFFantasyManager alloc] initWithSession:self.session];
        } else if ([[[FFSessionManager shared] currentCategoryName] isEqualToString:@"sports"]) {
            if ([[[FFSessionManager shared] currentSportName] isEqualToString:FOOTBALL_WC]) {
                self.manager = [[FFWCManager alloc] initWithSession:self.session];
            } else {
                self.manager = [[FFNonFantasyManager alloc] initWithSession:self.session];
            }
        }
        
        self.manager.delegate = self;
        
        [self setViewControllers:@[[self.manager getViewControllers].firstObject]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:nil];
    }
    
    self.isFirstLaunch = NO;
    
    self.pager.numberOfPages = (int)[self.manager getViewControllers].count;
    self.pager.currentPage = (int)[[self.manager getViewControllers] indexOfObject:self.viewControllers.firstObject];
    
    internetReachability = [Reachability reachabilityForInternetConnection];
	BOOL success = [internetReachability startNotifier];
	if ( !success )
		DLog(@"Failed to start notifier");
    self.networkStatus = [internetReachability currentReachabilityStatus];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusHasChanged:) name:kReachabilityChangedNotification object:nil];
}

- (void)networkStatusHasChanged:(NSNotification *)notification
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
//                        [self getWorldCupData];
                    } else {
//                        [self updateGames];
                    }
                }
            } else {
//                [self.games removeAllObjects];
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
        vc.delegate = (FFFantasyManager *)self.manager;
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
    NSUInteger index = [[self.manager getViewControllers] indexOfObject:viewController];
    if (index == NSNotFound) {
        WTFLog;
        return nil;
    }
    if (index == 0) {
        return nil;
    }
    return [self.manager getViewControllers][--index];
}

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
      viewControllerAfterViewController:(UIViewController*)viewController
{
    NSUInteger index = [[self.manager getViewControllers] indexOfObject:viewController];
    if (index == NSNotFound) {
        WTFLog;
        return nil;
    }
    if (index == [self.manager getViewControllers].count - 1) {
        return nil;
    }
    return [self.manager getViewControllers][++index];
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
    self.pager.currentPage = (int)[[self.manager getViewControllers] indexOfObject:
                                   self.viewControllers.firstObject];
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
    
    if ([category isEqualToString:FANTASY_SPORTS]) {
        self.manager = [[FFFantasyManager alloc] initWithSession:self.session];
    } else if ([category isEqualToString:@"sports"]) {
        if ([sport isEqual:FOOTBALL_WC]) {
            self.manager = [[FFWCManager alloc] initWithSession:self.session];
        } else {
            self.manager = [[FFNonFantasyManager alloc] initWithSession:self.session];
        }
    }
    
    self.manager.delegate = self;
    [self setViewControllers:@[[self.manager getViewControllers].firstObject]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];
}

- (void)logout
{
    [self.session logout];
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:nil];
}

#pragma mark - FFManagerDelegate

- (UIViewController *)selectedController
{
    return self.viewControllers.firstObject;
}

- (void)shouldSetViewController:(UIViewController *)controller
                      direction:(UIPageViewControllerNavigationDirection)direction
                       animated:(BOOL)animated
                     completion:(void (^)(BOOL finished))block
{
    [self setViewControllers:@[controller]
                   direction:direction
                    animated:animated
                  completion:block];
    self.pager.currentPage = (int)[[self.manager getViewControllers] indexOfObject:self.viewControllers.firstObject];
}

- (void)updatePagerView
{
    self.pager.numberOfPages = (int)[self.manager getViewControllers].count;
    self.pager.currentPage = (int)[[self.manager getViewControllers] indexOfObject:self.viewControllers.firstObject];
}

- (void)openIndividualPredictionsForPlayer:(FFPlayer *)player
{
    [self performSegueWithIdentifier:@"GotoPT" sender:player];
}

@end
