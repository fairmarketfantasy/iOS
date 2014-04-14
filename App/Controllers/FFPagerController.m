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
#import "FFPTController.h"
#import "StyledPageControl.h"
#import "FFNavigationBarItemView.h"
#import "FFLogo.h"
#import "FFWebViewController.h"
#import "FFAlertView.h"
#import "FFMenuViewController.h"
// model
#import "FFControllerProtocol.h"
#import "FFMarketSet.h"
#import "FFMarket.h"
#import "FFSessionViewController.h"
#import "FFMarketSelector.h"
#import "FFContestType.h"
#import "FFRoster.h"
#import "FFPlayer.h"
#import <SBData/SBTypes.h>

@interface FFPagerController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, FFControllerProtocol,
FFUserProtocol, FFMenuViewControllerDelegate, FFPlayersProtocol, FFEventsProtocol, FFYourTeamProtocol>

@property(nonatomic) StyledPageControl* pager;
@property(nonatomic) FFYourTeamController* teamController;
@property(nonatomic) FFWideReceiverController* receiverController;
@property(nonatomic) UIButton* globalMenuButton;

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
        self.teamController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                         bundle:[NSBundle mainBundle]]
                               instantiateViewControllerWithIdentifier:@"TeamController"];
        self.receiverController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                             bundle:[NSBundle mainBundle]]
                                   instantiateViewControllerWithIdentifier:@"ReceiverController"];
        self.teamController.delegate = self;
        self.receiverController.delegate = self;
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
    self.pager.numberOfPages = (int)[self getViewControllers].count;
    // session
    self.teamController.session = self.session;
    self.receiverController.session = self.session;
    [self setViewControllers:@[[self getViewControllers].firstObject]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];
    [self.view bringSubviewToFront:self.pager];
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
            NSString* sport = [FFSport stringFromSport:self.teamController.marketsSet.sport];
            vc.URL = [NSURL URLWithString:[baseUrl stringByAppendingFormat:@"/pages/mobile/rules?sport=%@", sport]];
        } else if ([segue.identifier isEqualToString:@"GotoSupport"]) {
            FFWebViewController* vc = [segue.destinationViewController viewControllers].firstObject;
            vc.URL = [NSURL URLWithString:[baseUrl stringByAppendingString:@"/pages/mobile/terms"]];
        }
    }
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
    // TODO: on appear
    if (!completed) {
        return;
    }
    self.pager.currentPage = (int)[[self getViewControllers] indexOfObject:
                                   self.viewControllers.firstObject];
}

- (void)pageViewController:(UIPageViewController*)pageViewController
willTransitionToViewControllers:(NSArray*)pendingViewControllers
{
    // TODO: on desappear
}

#pragma mark - private

- (NSArray*)getViewControllers
{
    return @[
             self.teamController,
             self.receiverController
             ];
}

#pragma mark - button actions

- (void)globalMenuButton:(UIButton*)button
{
    [self performSegueWithIdentifier:@"GotoMenu"
                              sender:nil];
}

#pragma mark - FFMenuViewControllerDelegate

- (void)performMenuSegue:(NSString*)ident
{
    [self performSegueWithIdentifier:ident
                              sender:nil];
}

- (void)didUpdateToNewSport:(FFMarketSport)sport
{
    self.teamController.marketsSet.sport = sport;
    [self.teamController updateMarkets];
}

- (FFMarketSport)currentMarketSport
{
    return self.teamController.marketsSet.sport;
}

- (void)logout
{
    [self.session logout];
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:nil];
}

#pragma mark - FFPlayersProtocol

- (NSString*)rosterId
{
    return self.teamController.roster.objId;
}

- (CGFloat)rosterSalary
{
    return self.teamController.roster.remainingSalary.floatValue;
}

- (NSArray*)positions
{
    return [self.teamController uniquePositions];
}

- (BOOL)autoRemovedBenched
{
    return self.teamController.roster.removeBenched.integerValue == 1;
}

- (void)addPlayer:(FFPlayer*)player
{
    __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:NSLocalizedString(@"Buying Player", nil)
                                                   messsage:nil
                                               loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.navigationController.view];
    @weakify(self)
    [self.teamController.roster addPlayer:player
                                  success:
     ^(id successObj) {
         @strongify(self)
         NSDictionary* priceDictionary = (NSDictionary*)successObj;
         NSString* price = priceDictionary[@"price"]; // TODO: use the Model, Luke...
         self.teamController.roster.remainingSalary = [SBFloat.alloc initWithFloat:[price floatValue]];
         [self.teamController.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
         [self.receiverController.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                                          withRowAnimation:UITableViewRowAnimationAutomatic];
         [alert hide];
         [self setViewControllers:@[self.teamController]
                        direction:UIPageViewControllerNavigationDirectionReverse
                         animated:YES
                       completion:nil];
     }
                                  failure:
     ^(NSError *error) {
         @strongify(self)
         [alert hide];
         [[[FFAlertView alloc] initWithError:error
                                       title:nil
                           cancelButtonTitle:nil
                             okayButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                    autoHide:YES]
          showInView:self.navigationController.view];
     }];
}

#pragma mark - FFEventsProtocol

- (NSString*)marketId
{
    return self.teamController.selectedMarket.objId;
}

#pragma mark - FFYourTeamProtocol

- (void)showPosition:(NSString*)position
{
    @weakify(self)
    [self setViewControllers:@[self.receiverController]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES
                  completion:
     ^(BOOL finished) {
         @strongify(self)
         [self.receiverController showPosition:position];
     }];
}

@end
