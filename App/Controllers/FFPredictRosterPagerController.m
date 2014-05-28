//
//  FFPredictRosterPagerController.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/4/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFPredictRosterPagerController.h"
#import "StyledPageControl.h"
#import "FFPredictRosterTeamController.h"
#import "FFPredictRosterScoreController.h"
#import "FFPTController.h"
#import "FFControllerProtocol.h"
#import "FFLogo.h"
#import "FFAlertView.h"
// model
#import "FFRosterPrediction.h"

@interface FFPredictRosterPagerController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate,
FFControllerProtocol, FFPredictionPlayersProtocol, FFEventsProtocol, FFPredictRosterScoreProtocol>

@property(nonatomic) FFRosterPrediction* roster;
@property(nonatomic) StyledPageControl* pager;
@property(nonatomic) FFPredictRosterTeamController* teamController;
@property(nonatomic) FFPredictRosterScoreController* scoreController;

@end

@implementation FFPredictRosterPagerController

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
                               instantiateViewControllerWithIdentifier:@"PredictRosterTeamController"];
        self.teamController.delegate = self;
        self.scoreController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                          bundle:[NSBundle mainBundle]]
                                instantiateViewControllerWithIdentifier:@"PredictRosterScoreController"];
        self.scoreController.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    if ([self.roster.state isEqualToString:@"finished"]) {
        [self.view addSubview:self.pager];
        [self.view bringSubviewToFront:self.pager];
    }
    // navigation bar
    self.navigationItem.titleView = [[FFLogo alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 44.f)];
    self.navigationItem.leftBarButtonItems = [FFStyle backBarItemsForController:self];
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
    if ([segue.identifier isEqualToString:@"GotoPredictionsPT"]) {
        FFPTController* vc = segue.destinationViewController;
        vc.delegate = self;
        vc.player = (FFPlayer*)sender;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.pager.numberOfPages = (int)[self getViewControllers].count;
    self.teamController.session = self.session;
    self.scoreController.session = self.session;
    [self setViewControllers:@[[self getViewControllers].firstObject]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];
    [self.view bringSubviewToFront:self.pager];
    [self fetchRoster];
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
    // TODO: on will appear
    if (!completed) {
        return;
    }
    self.pager.currentPage = (int)[[self getViewControllers] indexOfObject:
                                   self.viewControllers.firstObject];
}

- (void)pageViewController:(UIPageViewController*)pageViewController
willTransitionToViewControllers:(NSArray*)pendingViewControllers
{
    // TODO: on will dissapear
}

#pragma mark - private

- (void)fetchRoster
{
    if (!self.prediction) {
        self.roster = nil;
        [self.teamController.tableView reloadData];
        return;
    }
    __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:@"Loading Roster"
                                                           messsage:nil
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.navigationController.view];
    @weakify(self)
    [self.prediction loadRosterSuccess:
     ^(id successObj) {
         @strongify(self)
         self.roster = successObj;
         [self.teamController.tableView reloadData];
         [alert hide];
     }
                               failure:
     ^(NSError * error) {
         @strongify(self)
         self.roster = nil;
         [self.teamController.tableView reloadData];
         [alert hide];
     }];
}

- (NSArray*)getViewControllers
{
    if ([self.roster.state isEqualToString:@"finished"]) {
        return @[
                 self.teamController,
                 self.scoreController
                 ];
        
    } else {
        return @[
                 self.teamController
                 ];
    }
}

#pragma  mark - FFPredictionPlayersProtocol

- (NSArray*)players
{
    return self.roster.players;
}

- (NSArray*)teams
{
    return self.roster.teams;
}

- (CGFloat)rosterSalary
{
    return self.roster.remainingSalary.floatValue;
}

- (NSString*)rosterState
{
    return self.roster.state;
}

- (void)removePlayer:(FFPlayer*)player
{
    __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:@"Removing Player"
                                                           messsage:nil
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.navigationController.view];
    @weakify(self)
    [self.roster  removePlayer:player
                       success:
     ^(id successObj) {
         @strongify(self)
         [self.teamController.tableView reloadData];
         [alert hide];
     }
                       failure:
     ^(NSError *error) {
//         @strongify(self)
         [alert hide];
     }];
}

#pragma mark - FFEventsProtocol

- (NSString*)rosterId
{
    return self.roster.objId;
}

- (NSString*)marketId
{
    return self.roster.marketId;
}

@end
