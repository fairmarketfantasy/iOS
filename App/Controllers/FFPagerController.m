//
//  FFPagerController.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/13/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFPagerController.h"
#import "FFStyle.h"
#import "FFYourTeamController.h"
#import "FFWideReceiverController.h"
#import "StyledPageControl.h"
#import "FFNavigationBarItemView.h"
#import "FFLogo.h"
// model
#import "FFControllerProtocol.h"
#import "FFMarketSet.h"
#import "FFSessionViewController.h"
#import "FFMarketSelector.h"
#import "FFContestType.h"

@interface FFPagerController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate,
SBDataObjectResultSetDelegate, FFControllerProtocol>

@property(nonatomic) StyledPageControl* pager;
@property(nonatomic) FFYourTeamController* teamController;
@property(nonatomic) FFWideReceiverController* receiverController;
@property(nonatomic) UIButton* globalMenuButton;
@property(nonatomic) UIButton* personalInfoButton;
@property(nonatomic, assign) BOOL isPersonalInfoOpened;
// models
@property(nonatomic) FFMarketSet* markets;
@property(nonatomic) FFMarketSelector* marketSelector;
@property(nonatomic) SBDataObjectResultSet* contests;
@property(nonatomic) NSArray* filteredContests;

@end

@implementation FFPagerController

@synthesize session;

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.isPersonalInfoOpened = NO;
        self.view.backgroundColor = [FFStyle darkGreen];
        self.dataSource = self;
        self.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    self.pager = [StyledPageControl new];
    self.pager.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.pager.frame = CGRectMake(0.f,
                                  self.view.bounds.size.height - 39.f,
                                  self.view.bounds.size.width,
                                  44.f);
    [self.pager setGapWidth:2];
    [self.pager setPageControlStyle:PageControlStyleThumb];
    [self.pager setThumbImage:[UIImage imageNamed:@"passive"]];
    [self.pager setSelectedThumbImage:[UIImage imageNamed:@"active"]];
    [self.view addSubview:self.pager];
    [self.view bringSubviewToFront:self.pager];
    // left bar item
    FFNavigationBarItemView* leftItem = [[FFNavigationBarItemView alloc] initWithFrame:[FFStyle leftItemRect]];
    self.globalMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.globalMenuButton setImage:[UIImage imageNamed:@"globalmenu"]
                           forState:UIControlStateNormal];
    [self.globalMenuButton setImage:[UIImage imageNamed:@"globalmenu-highlighted"]
                             forState:UIControlStateHighlighted];
    [self.globalMenuButton addTarget:self
                              action:@selector(globalMenuButton:)
                    forControlEvents:UIControlEventTouchUpInside];
    self.globalMenuButton.contentMode = UIViewContentModeScaleAspectFit;
    self.globalMenuButton.frame = [FFStyle leftItemRect];
    [leftItem addSubview:self.globalMenuButton];
    // right bar item
    FFNavigationBarItemView* rightItem = [[FFNavigationBarItemView alloc] initWithFrame:[FFStyle leftItemRect]];
    self.personalInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.personalInfoButton setImage:[UIImage imageNamed:@"open"]
                             forState:UIControlStateNormal];
    [self.personalInfoButton addTarget:self
                                action:@selector(personalInfoButton:)
                      forControlEvents:UIControlEventTouchUpInside];
    self.personalInfoButton.contentMode = UIViewContentModeScaleAspectFit;
    self.personalInfoButton.frame = [FFStyle leftItemRect];
    [rightItem addSubview:self.personalInfoButton];
    self.personalInfoButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        UIBarButtonItem* spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                   target:nil
                                                                                   action:NULL];
        spaceItem.width = -16.f;
        self.navigationItem.leftBarButtonItems = @[
                                                   spaceItem,
                                                   [[UIBarButtonItem alloc] initWithCustomView:leftItem]
                                                   ];
        self.navigationItem.rightBarButtonItems = @[
                                                    [[UIBarButtonItem alloc] initWithCustomView:rightItem]
                                                    ];
    } else {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftItem];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightItem];
    }
    // title
    self.navigationItem.titleView = [[FFLogo alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 44.f)];
    // markets
    _markets = [FFMarket getBulkWithSession:self.session
                                 authorized:YES];
    self.markets.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.teamController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                     bundle:[NSBundle mainBundle]]
        instantiateViewControllerWithIdentifier:@"TeamController"];
    self.receiverController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                         bundle:[NSBundle mainBundle]]
                               instantiateViewControllerWithIdentifier:@"ReceiverController"];

    [self setViewControllers:@[[self getViewControllers].firstObject]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];
    self.pager.numberOfPages = (int)[self getViewControllers].count;
    [self.view bringSubviewToFront:self.pager];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdateUser:)
                                                 name:FFSessionDidUpdateUserNotification
                                               object:nil];
    [self hidePersonalInfo];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
     viewControllerBeforeViewController:(UIViewController*)viewController
{
    NSUInteger index = [[self getViewControllers] indexOfObject:viewController];
    if (index == NSNotFound) {
        WTFLog;
        return nil;
    }
    if (index == 0) {
        return nil;
    }
    return [self getViewControllers][--index];
}

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
      viewControllerAfterViewController:(UIViewController*)viewController
{
    NSUInteger index = [[self getViewControllers] indexOfObject:viewController];
    if (index == NSNotFound) {
        WTFLog;
        return nil;
    }
    if (index == [self getViewControllers].count - 1) {
        return nil;
    }
    return [self getViewControllers][++index];
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed
{
    [self hidePersonalInfo];
    if (!completed) {
        return;
    }
    self.pager.currentPage = (int)[[self getViewControllers] indexOfObject:
                                   self.viewControllers.firstObject];
}

- (void)pageViewController:(UIPageViewController*)pageViewController
willTransitionToViewControllers:(NSArray*)pendingViewControllers
{
    [self hidePersonalInfo];
}

#pragma mark - private

- (NSArray*)getViewControllers
{
    return @[
             self.teamController,
             self.receiverController
             ];
}

- (void)hidePersonalInfo
{
    [self hidePersonalInfoAnimated:NO];
}

- (void)hidePersonalInfoAnimated:(BOOL)animated
{
    [UIView animateWithDuration:(NSTimeInterval)(animated ? .3f : 0.f)
                     animations:^{
                         [self.personalInfoButton setImage:[UIImage imageNamed:@"open"]
                                                  forState:UIControlStateNormal];
                         self.teamController.tableView.contentInset =
                         UIEdgeInsetsMake(-self.teamController.tableView.tableHeaderView.bounds.size.height, 0.f, 0.f, 0.f);
                         self.teamController.tableView.contentOffset =
                         CGPointMake(0.f, self.teamController.tableView.tableHeaderView.bounds.size.height);
                         self.receiverController.tableView.contentInset =
                         UIEdgeInsetsMake(-self.receiverController.tableView.tableHeaderView.bounds.size.height, 0.f, 0.f, 0.f);
                         self.receiverController.tableView.contentOffset =
                         CGPointMake(0.f, self.receiverController.tableView.tableHeaderView.bounds.size.height);
                         self.isPersonalInfoOpened = NO;
                     }];
}

- (void)showPersonalInfo
{
    [self showPersonalInfoAnimated:NO];
}

- (void)showPersonalInfoAnimated:(BOOL)animated
{
    [UIView animateWithDuration:(NSTimeInterval)(animated ? .3f : 0.f)
                     animations:^{
                         [self.personalInfoButton setImage:[UIImage imageNamed:@"close"]
                                                  forState:UIControlStateNormal];
                         self.teamController.tableView.contentInset = UIEdgeInsetsZero;
                         self.teamController.tableView.contentOffset = CGPointZero;
                         self.receiverController.tableView.contentInset = UIEdgeInsetsZero;
                         self.receiverController.tableView.contentOffset = CGPointZero;
                         self.isPersonalInfoOpened = YES;
                     }];
}

- (void)updateMarkets
{
    _markets.clearsCollectionBeforeSaving = YES;
    [_markets fetchType:FFMarketTypeRegularSeason];
    _markets.clearsCollectionBeforeSaving = NO;
    [_markets fetchType:FFMarketTypeSingleElimination];
    _marketSelector.markets = [FFMarket filteredMarkets:_markets.allObjects];
}

#pragma mark - notification callback

- (void)didUpdateUser:(NSNotification*)note
{
    [self performSelectorOnMainThread:@selector(updateUserCell)
                           withObject:nil
                        waitUntilDone:NO];
}

- (void)updateUserCell
{
    // TODO: update header
}

#pragma mark - SBDataObjectResultSetDelegate

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

        // TODO: refresh table view
    }
}

#pragma mark - button actions

- (void)globalMenuButton:(UIButton*)button
{
    [self performSegueWithIdentifier:@"GotoMenu"
                              sender:nil];
}

- (void)personalInfoButton:(UIButton*)button
{
    if (self.isPersonalInfoOpened) {
        [self hidePersonalInfoAnimated:YES];
    } else {
        [self showPersonalInfoAnimated:YES];
    }
}

@end
