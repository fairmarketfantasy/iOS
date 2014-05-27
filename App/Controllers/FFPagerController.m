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
#import <SBData/SBTypes.h>

@interface FFPagerController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, FFControllerProtocol,
FFUserProtocol, FFMenuViewControllerDelegate, FFPlayersProtocol, FFEventsProtocol, FFYourTeamDelegate, FFYourTeamDataSource,
SBDataObjectResultSetDelegate>
{
    __block BOOL _rosterIsCreating;
}

@property(nonatomic) StyledPageControl* pager;
@property(nonatomic) FFYourTeamController* teamController;
@property(nonatomic) FFWideReceiverController* receiverController;
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
        
        self.isFirstLaunch = YES;
        _rosterIsCreating = NO;
        
        self.myTeam = [NSMutableArray array];
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
    
    // get player position names
    if ([[[FFSessionManager shared] currentCategoryName] isEqualToString:FANTASY_SPORTS]) {
        [self fetchPositionsNames];        
    }
    
    if (self.isFirstLaunch) {
        if ([[[FFSessionManager shared] currentCategoryName] isEqualToString:FANTASY_SPORTS]) {
            self.marketsSetRegular = [[FFMarketSet alloc] initWithDataObjectClass:[FFMarket class]
                                                                          session:self.session authorized:YES];
            self.marketsSetSingle = [[FFMarketSet alloc] initWithDataObjectClass:[FFMarket class]
                                                                         session:self.session authorized:YES];
            self.marketsSetRegular.delegate = self;
            self.marketsSetSingle.delegate = self;
            [self updateMarkets];
        } else if ([[[FFSessionManager shared] currentCategoryName] isEqualToString:@"sports"]) {
            [self updateGames];
        }
        
        [self setViewControllers:@[[self getViewControllers].firstObject]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:nil];
        
        [self.view bringSubviewToFront:self.pager];
    }
    
    self.isFirstLaunch = NO;
    
    self.pager.numberOfPages = (int)[self getViewControllers].count;
    self.pager.currentPage = (int)[[self getViewControllers] indexOfObject:self.viewControllers.firstObject];
    
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
                [self fetchPositionsNames];
                [self updateMarkets];
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

#pragma mark - Manage My Team

- (NSMutableDictionary *)emptyPosition
{
    return  [NSMutableDictionary dictionaryWithObjectsAndKeys:@"", @"name", @"", @"player", nil];
}

- (BOOL)isPositionUnique:(NSString *)position
{
    NSUInteger counter = 0;
    for (NSString *pos in [self allPositions]) {
        if ([position isEqualToString:pos])
            counter++;
    }
    
    if (counter == 1)
        return YES;
    else if (counter > 1)
        return NO;
    else
        assert(NO);
}

- (NSMutableArray *)newTeamWithPositions:(NSArray *)positions
{
    NSMutableArray *newTeam = [NSMutableArray array];
    for (NSUInteger i = 0; i < positions.count; ++i) {
        [newTeam addObject:[self emptyPosition]];
        [newTeam[i] setObject:positions[i] forKey:@"name"];
    }
    
    return newTeam;
}

- (void)addPlayerToMyTeam:(FFPlayer *)player
{
    for (NSMutableDictionary *position in self.myTeam) {
        if ([position[@"name"] isEqualToString:player.position]) {
            if ([self isPositionUnique:player.position]) {
                [position setObject:player forKey:@"player"];
                break;
            } else {
                if ([position[@"player"] isKindOfClass:[NSString class]]) {
                    if ([position[@"player"] isEqualToString:@""]) {
                        [position setObject:player forKey:@"player"];
                        break;
                    } else {
                        continue;
                    }
                }
            }
        }
    }
}

- (void)removePlayerFromMyTeam:(FFPlayer *)player
{
    for (NSMutableDictionary *position in self.myTeam) {
        if ([position[@"player"] isKindOfClass:[FFPlayer class]]) {
            FFPlayer *pl = position[@"player"];
            if ([pl.name isEqualToString:player.name]) {
                [position setObject:@"" forKey:@"player"];
            }
        }
    }
}

#pragma mark - private

- (void)updateSelectedGames
{
    for (FFTeam *team in self.selectedTeams) {
        [self setTeam:team selected:YES];
    }
}

- (void)deselectAllTeams
{
    for (FFTeam *team in self.selectedTeams) {
        [self setTeam:team selected:NO];
    }
    
    [self.selectedTeams removeAllObjects];
}

- (void)setTeam:(FFTeam *)team selected:(BOOL)selected
{
    for (FFNonFantasyGame *game in self.games) {
        if ([team.gameStatsId isEqualToString:game.gameStatsId]) {
            if ([game.homeTeam.name isEqualToString:team.name]) {
                game.homeTeam.selected = selected;
            } else if ([game.awayTeam.name isEqualToString:team.name]) {
                game.awayTeam.selected = selected;
            }
        }
    }
}

- (void)disablePTForTeam:(FFTeam *)team
{
    for (FFNonFantasyGame *game in self.games) {
        if ([game.gameStatsId isEqualToString:team.gameStatsId]) {
            if ([game.homeTeam.statsId isEqualToString:team.statsId]) {
                game.homeTeamDisablePt = @(YES);
            } else {
                game.awayTeamDisablePt = @(YES);
            }
        }
    }
}

- (void)createRosterWithCompletion:(void(^)(BOOL success))block
{
    _rosterIsCreating = YES;
    
    if (!self.selectedMarket) {
        self.roster = nil;
        if (block) {
            block(NO);
        }
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
         _rosterIsCreating = NO;
         self.roster = successObj;
         
         self.myTeam = [self newTeamWithPositions:[self allPositions]];
         
         [alert hide];
         if (block) {
             block(YES);
         }
     }
                               failure:
     ^(NSError * error) {
         @strongify(self)
         _rosterIsCreating = NO;
         if (self.tryCreateRosterTimes > 0) {
             [alert hide];
             self.tryCreateRosterTimes--;
             [self createRosterWithCompletion:block];
//             if (block) {
//                 block(NO);
//             }
         } else {
             self.roster = nil;
             [alert hide];
             if (block) {
                 block(NO);
             }
         }
     }];
}

- (NSArray*)getViewControllers
{
    return @[
             self.teamController,
             self.receiverController
             ];
}

- (void)fetchPositionsNames
{
    @weakify(self)
    [FFRoster fetchPositionsForSession:self.session
                               success:
     ^(id successObj) {
         @strongify(self)
         self.positionsNames = successObj;
     }
                               failure:
     ^(NSError *error) {
         @strongify(self)
         self.positionsNames = @{};
         // ???: should we show any Error Alert here?
     }];
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
    [[FFSessionManager shared] saveCurrentCategory:category andSport:sport];
    if ([category isEqualToString:FANTASY_SPORTS]) {
        [self.receiverController resetPosition];
        [self updateMarkets];
    } else if ([category isEqualToString:@"sports"]) {
        [self updateGames];
    }
}

- (void)logout
{
    [self.session logout];
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:nil];
}

#pragma mark - FFPlayersProtocol

- (void)addPlayer:(FFPlayer*)player
{
    __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:NSLocalizedString(@"Buying Player", nil)
                                                           messsage:nil
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.navigationController.view];
    @weakify(self)
    [self.roster addPlayer:player
                   success:
     ^(id successObj) {
         @strongify(self)
         //         [self.teamController.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
         //                                      withRowAnimation:UITableViewRowAnimationAutomatic];
         //         [self.receiverController.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
         //                                          withRowAnimation:UITableViewRowAnimationAutomatic];
         [alert hide];
         [self addPlayerToMyTeam:player];
         [self.teamController refreshRosterWithShowingAlert:YES completion:nil];
         [self setViewControllers:@[self.teamController]
                        direction:UIPageViewControllerNavigationDirectionReverse
                         animated:YES
                       completion:nil];
                           
         self.pager.currentPage = (int)[[self getViewControllers] indexOfObject:
                                        self.viewControllers.firstObject];
         
     }
                   failure:
     ^(NSError *error) {
         @strongify(self)
         [alert hide];
         
          //show this alert cause unclear situation:
         //1)user has choosen player on some position
         //2)this position is already occupied buy another player
         //3)nothing happens after it
         NSString *localizedDescription = [error.userInfo objectForKey:@"NSLocalizedDescription"];
         NSString *errorBody = @"There is no room for another";
         if ([localizedDescription rangeOfString:errorBody].location != NSNotFound) {
             FFAlertView *alert = [[FFAlertView alloc] initWithTitle:nil
                                                             message:localizedDescription
                                                   cancelButtonTitle:nil
                                                     okayButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                            autoHide:YES];
             
             [alert showInView:self.navigationController.view];
         }
     }];
}

- (void)addTeam:(FFTeam *)newTeam
{
    if (self.selectedTeams.count == 5) {
        FFAlertView *alert = [[FFAlertView alloc] initWithTitle:nil
                                                        message:@"Roster is full"
                                              cancelButtonTitle:nil
                                                okayButtonTitle:@"OK"
                                                       autoHide:YES];
        [alert showInView:self.view];
        return;
    }
    
    BOOL alreadySelected = NO;
    for (FFTeam *team in self.selectedTeams) {
        if ([team.name isEqualToString:newTeam.name]) {
            alreadySelected = YES;
        }
    }
    
    if (alreadySelected) {
        FFAlertView *alert = [[FFAlertView alloc] initWithTitle:nil
                                                        message:@"This team is already selected"
                                              cancelButtonTitle:nil
                                                okayButtonTitle:@"OK"
                                                       autoHide:YES];
        [alert showInView:self.view];
        return;
    }
    
    [self setTeam:newTeam selected:YES];
    [self.selectedTeams addObject:newTeam];
    
    [self setViewControllers:@[self.teamController]
                   direction:UIPageViewControllerNavigationDirectionReverse
                    animated:YES
                  completion:nil];
    
    [self.teamController reloadWithServerError:NO];
}

- (void)fetchGamesShowAlert:(BOOL)shouldShow withCompletion:(void (^)(void))block
{
    __block FFAlertView *alert = nil;
    if (shouldShow){
        alert = [[FFAlertView alloc] initWithTitle:nil
                                          messsage:@""
                                      loadingStyle:FFAlertViewLoadingStylePlain];
        [alert showInView:self.navigationController.view];
    }
   
    [FFNonFantasyGame fetchGamesSession:self.session
                                success:^(id successObj) {
                                    NSLog(@"Success object: %@", successObj);
                                    NSMutableArray *games = [NSMutableArray array];
                                    for (FFNonFantasyGame *game in successObj) {
                                        [game setupTeams];
                                        [games addObject:game];
                                    }
                                    self.games = [NSMutableArray arrayWithArray:games];
                                    [self updateSelectedGames];
                                    [self.teamController reloadWithServerError:NO];
                                    if (alert)
                                        [alert hide];
                                    if (block)
                                        block();
                                } failure:^(NSError *error) {
                                    NSLog(@"Error: %@", error);
                                    [self.teamController reloadWithServerError:YES];
                                    if (alert)
                                        [alert hide];
                                    if (block)
                                        block();
                                }];
}

- (void)makeIndividualPredictionOnTeam:(FFTeam *)team
{
    __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:@""
                                                           messsage:nil
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.navigationController.view];
    
    [FFEvent fetchEventsForTeam:team.statsId
                         inGame:team.gameStatsId
                        session:self.session
                        success:^(id successObj) {
                            [self disablePTForTeam:team];
                            [self.receiverController.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                                                             withRowAnimation:UITableViewRowAnimationAutomatic];
                            [alert hide];
                        } failure:^(NSError *error) {
                            [alert hide];
                        }];
}

#pragma mark - FFEventsProtocol

- (NSString*)marketId
{
    return self.selectedMarket.objId;
}

#pragma mark -

- (void)updateGames
{
    self.games = [NSMutableArray array];
    [self fetchGamesShowAlert:YES withCompletion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.receiverController.tableView reloadData];
        });
    }];
}

- (void)updateMarkets
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    __block FFAlertView *alert = nil;
    
    if (self.isFirstLaunch) {
        alert = [[FFAlertView alloc] initWithTitle:@""
                                          messsage:nil
                                      loadingStyle:FFAlertViewLoadingStylePlain];
        [alert showInView:self.navigationController.view];
    }
    
    if (!self.marketsSetSingle) {
        self.marketsSetSingle = [[FFMarketSet alloc] initWithDataObjectClass:[FFMarket class]
                                                                     session:self.session authorized:YES];
        
        self.marketsSetSingle.delegate = self;
    }
    if (!self.marketsSetRegular) {
        self.marketsSetRegular = [[FFMarketSet alloc] initWithDataObjectClass:[FFMarket class]
                                                                      session:self.session authorized:YES];
        self.marketsSetRegular.delegate = self;        
    }
    
    [self.marketsSetRegular fetchType:FFMarketTypeRegularSeason completion:^{
        [self.marketsSetSingle fetchType:FFMarketTypeSingleElimination completion:^{
            if (alert)
                [alert hide];
        }];
    }];
}

- (void)marketsUpdated
{
    [self.teamController.tableView reloadData];
    NSArray *markets = [self availableMarkets];
    if (markets.count > 0) {
        
        if ([self.teamController respondsToSelector:@selector(marketSelected:)]) {
            [self.teamController performSelector:@selector(marketSelected:) withObject:markets.firstObject];
        }
        if ([self.receiverController respondsToSelector:@selector(marketSelected:)]) {
            [self.receiverController performSelector:@selector(marketSelected:) withObject:markets.firstObject];
        }
    } else {
        self.selectedMarket = nil;
    }
}

#pragma mark - FFYourTeamDataSource

- (NSString*)rosterId
{
    return self.roster.objId;
}

- (NSArray *)team
{
    return self.myTeam;
}

- (NSArray*)allPositions
{
    return [self.roster.positions componentsSeparatedByString:@","];
}

- (NSArray*)uniquePositions
{
    NSArray* positions = [self allPositions];
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

- (void)setCurrentMarket:(FFMarket *)market
{
    self.selectedMarket = market;
    if (_rosterIsCreating == NO) {
        
        __weak FFPagerController *weakSelf = self;
        [self createRosterWithCompletion:^(BOOL success) {
            if (success) {
                [weakSelf.teamController reloadWithServerError:NO];
                [weakSelf.receiverController fetchPlayersWithShowingAlert:NO completion:^{
                    [weakSelf.receiverController reloadWithServerError:NO ];
                }];
            } else {
                [weakSelf.teamController reloadWithServerError:YES];
                [weakSelf.receiverController reloadWithServerError:YES];
            }
        }];
    }
}

- (FFMarket *)currentMarket
{
    return self.selectedMarket;
}

- (NSArray *)availableMarkets
{
    NSMutableArray* markets = [NSMutableArray arrayWithCapacity:self.marketsSetRegular.allObjects.count +
                               self.marketsSetSingle.allObjects.count];
    [markets addObjectsFromArray:self.marketsSetRegular.allObjects];
    [markets addObjectsFromArray:self.marketsSetSingle.allObjects];
    return [markets copy];
}

- (FFRoster *)currentRoster
{
    return self.roster;
}

- (NSArray *)availableGames
{
    return self.games;
}

- (NSArray *)teams
{
    return self.selectedTeams;
}

#pragma mark - FFYourTeamDelegate

- (void)showPosition:(NSString*)position
{
    @weakify(self)
    [self setViewControllers:@[self.receiverController]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES
                  completion:
     ^(BOOL finished) {
         @strongify(self)
         self.pager.currentPage = (int)[[self getViewControllers] indexOfObject:
                                        self.viewControllers.firstObject];
         
         [self.receiverController showPosition:position];
     }];
}

- (void)removePlayer:(FFPlayer*)player completion:(void(^)(BOOL success))block
{
    @weakify(self)
    [self.roster removePlayer:player
                      success:
     ^(id successObj) {
         @strongify(self)
         [self removePlayerFromMyTeam:player];
         if (block)
             block(YES);
     }
                      failure:
     ^(NSError *error) {
         if (block)
             block(NO);
     }];
}

- (void)submitRoster:(FFRosterSubmitType)rosterType completion:(void (^)(BOOL))block
{
    if ([[FFSessionManager shared].currentCategoryName isEqualToString:FANTASY_SPORTS]) {
        @weakify(self)
        [self.roster submitContent:rosterType
                           success:
         ^(id successObj) {
             @strongify(self)
             if (block)
                 block(YES);
             
             [self createRosterWithCompletion:^(BOOL success) {
                 [self.teamController reloadWithServerError:!success];
                 [self.receiverController reloadWithServerError:!success];
             }];
         }
                           failure:
         ^(NSError * error) {
             @strongify(self)
             if (block)
                 block(NO);
             [self.teamController.tableView reloadData];
         }];
    } else {
        NSMutableArray *teamsDicts = [NSMutableArray arrayWithCapacity:self.selectedTeams.count];
        for (FFTeam *team in self.selectedTeams) {
            NSDictionary * dict = @{
                                    @"game_stats_id" : team.gameStatsId,
                                    @"team_stats_id" : team.statsId,
                                    @"position_index": [NSNumber numberWithInteger:[self.selectedTeams indexOfObject:team]]
                                    };
            [teamsDicts addObject:dict];
        }
        
        [FFRoster submitNonFantasyRosterWithTeams:teamsDicts
                                          session:self.session
                                          success:^(id successObj) {
                                              [self deselectAllTeams];
                                              if (block)
                                                  block(YES);
                                          } failure:^(NSError *error) {
                                              NSLog(@"Error: %@", error);
                                              if (block)
                                                  block(NO);
                                          }];
    }
}

- (void)autoFillWithCompletion:(void(^)(BOOL success))block
{
    if ([[FFSessionManager shared].currentCategoryName isEqualToString:FANTASY_SPORTS]) {
        @weakify(self)
        [self.roster autofillSuccess:
         ^(id successObj) {
             @strongify(self)
             self.roster = successObj;
             self.myTeam = [self newTeamWithPositions:[self allPositions]];
             for (FFPlayer *player in self.roster.players) {
                 [self addPlayerToMyTeam:player];
             }
             
             if (block)
                 block(YES);
         }
                             failure:
         ^(NSError *error) {
             @strongify(self)
             self.roster = nil;
             if (block)
                 block(NO);
         }];
    } else {
        [self deselectAllTeams];
        
        if (self.pager.currentPage == 1) {
            [self setViewControllers:@[self.teamController]
                           direction:UIPageViewControllerNavigationDirectionReverse
                            animated:YES
                          completion:nil];
        }
        
        [FFRoster autofillForSession:self.session
                             success:^(id successObj) {
                                 self.selectedTeams = [NSMutableArray arrayWithArray:successObj];
                                 [self updateSelectedGames];
                                 if (block)
                                     block(YES);
                             } failure:^(NSError *error) {
                                 if (block)
                                     block(NO);
                             }];
    }
}

- (void)toggleRemoveBenchWithCompletion:(void(^)(BOOL success))block
{
    @weakify(self)
    [self.roster toggleRemoveBenchedSuccess:
     ^(id successObj) {
         @strongify(self)
         self.roster = successObj;
         if (block)
             block(YES);
     }
                                    failure:
     ^(NSError *error) {
         @strongify(self)
         self.roster = nil;
         if (block)
             block(NO);
     }];
}

- (void)refreshRosterWithCompletion:(void(^)(BOOL success))block
{
    @weakify(self)
    [self.roster refreshInBackgroundWithBlock:
     ^(id successObj) {
         @strongify(self)
         self.roster = successObj;

         if (block)
             block(YES);
     }
                                      failure:
     ^(NSError *error) {
         @strongify(self)
         self.roster = nil;
         
         if (block)
             block(NO);
      }];
}

- (void)showAvailableGames
{
    [self setViewControllers:@[self.receiverController]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES
                  completion:nil];
}

- (void)removeTeam:(FFTeam *)removedTeam
{
    [self setTeam:removedTeam selected:NO];
    for (FFTeam *team in self.selectedTeams) {
        if ([team.name isEqualToString:removedTeam.name]){
            [self.selectedTeams removeObject:team];
            break;
        }
    }
    
    [self.receiverController.tableView reloadData];
    
    __weak FFPagerController *weakSelf = self;
    [self setViewControllers:@[self.receiverController]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES
                  completion:^(BOOL finished) {
                      if (finished)
                          [weakSelf.teamController.tableView reloadData];
                  }];
}

#pragma mark - SBDataObjectResultSetDelegate

- (void)resultSetDidReload:(SBDataObjectResultSet*)resultSet
{
    if (resultSet.count > 0) {
        [self marketsUpdated];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } else {
        [self.teamController reloadWithServerError:NO];
        [self.receiverController reloadWithServerError:NO];
    }
}

@end
