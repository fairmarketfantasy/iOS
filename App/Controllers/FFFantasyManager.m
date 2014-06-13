//
//  FFFantasyManager.m
//  FMF Football
//
//  Created by Anton Chuev on 6/10/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFFantasyManager.h"
#import "FFManager.h"
#import "FFFantasyRosterController.h"
#import "FFPlayersController.h"
#import "FFPagerController.h"
#import "FFPTController.h"
#import "FFFantasyRosterDataSource.h"
#import "FFAlertView.h"
#import "FFMarketSet.h"
#import "FFMarket.h"
#import "FFPlayer.h"
#import "FFRoster.h"
#import "Reachability.h"

@interface FFFantasyManager() <SBDataObjectResultSetDelegate, FFFantasyRosterDataSource,
FFFantasyRosterDelegate, FFPlayersProtocol, FFEventsProtocol>
{
    Reachability* internetReachability;
}

@property (nonatomic, strong) FFFantasyRosterController *rosterController;
@property (nonatomic, strong) FFPlayersController *playersController;

@property (nonatomic, strong) FFMarketSet* marketsSetRegular;
@property (nonatomic, strong) FFMarketSet* marketsSetSingle;

@property (nonatomic, strong) NSMutableArray *myTeam;
@property (nonatomic, strong) NSDictionary* positionsNames;
@property (nonatomic, strong) FFRoster *roster;
@property (nonatomic, strong) FFMarket* selectedMarket;

@property (nonatomic, assign) BOOL rosterIsCreating;
@property (nonatomic, assign) BOOL unpaid;

@property (nonatomic, assign) NetworkStatus networkStatus;

@end

@implementation FFFantasyManager

- (id)initWithSession:(FFSession *)session
{
    self = [super initWithSession:session];
    if (self) {
        self.rosterController = [FFFantasyRosterController new];
        self.rosterController.delegate = self;
        self.rosterController.dataSource = self;
        self.rosterController.errorDelegate = self;
        
        self.playersController = [FFPlayersController new];
        self.playersController.delegate = self;
        self.playersController.dataSource = self;
        self.playersController.errorDelegate = self;
        
        self.rosterController.session = session;
        self.playersController.session = session;
        
        self.marketsSetRegular = [[FFMarketSet alloc] initWithDataObjectClass:[FFMarket class]
                                                                      session:self.session authorized:YES];
        self.marketsSetSingle = [[FFMarketSet alloc] initWithDataObjectClass:[FFMarket class]
                                                                     session:self.session authorized:YES];
        self.marketsSetRegular.delegate = self;
        self.marketsSetSingle.delegate = self;
        
        //reachability
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusHasChanged:) name:kReachabilityChangedNotification object:nil];
        internetReachability = [Reachability reachabilityForInternetConnection];
        BOOL success = [internetReachability startNotifier];
        if (!success)
            DLog(@"Failed to start notifier");
        self.networkStatus = [internetReachability currentReachabilityStatus];

        
        [self fetchPositionsNames];
        [self updateMarkets];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void)networkStatusHasChanged:(NSNotification *)notification
{
    NetworkStatus internetStatus = [internetReachability currentReachabilityStatus];
    NetworkStatus previousStatus = self.networkStatus;
    
    if (internetStatus != self.networkStatus) {
        self.networkStatus = internetStatus;
        
        if (internetStatus != NotReachable && previousStatus == NotReachable) {
            [self fetchPositionsNames];
            [self updateMarkets];
        }
    }
}

- (NSArray *)getViewControllers
{
    return @[
             self.rosterController,
             self.playersController
             ];
}

- (void)handleError:(NSError *)error
{
    NSString *errorBody = @"There is no room for another";
    NSString *errorDescription = [[error userInfo] objectForKey:@"NSLocalizedDescription"];
    if ([errorDescription isEqualToString:@"Unpaid subscription!"]) {
        self.errorType = FFErrorTypeUnpaid;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"Unpaidsubscription"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else if ([errorDescription rangeOfString:errorBody].location != NSNotFound) {
        //show this alert cause unclear situation:
        //1)user has choosen player on some position
        //2)this position is already occupied buy another player
        //3)nothing happens after it
        FFAlertView *alert = [[FFAlertView alloc] initWithTitle:nil
                                                        message:errorDescription
                                              cancelButtonTitle:nil
                                                okayButtonTitle:@"Dismiss"
                                                       autoHide:YES];
        
        [alert showInView:self.playersController.view];
    } else {
        self.errorType = FFErrorTypeUnknownServerError;
        
    }
}

#pragma mark

- (void)updateMarkets
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
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
    
    __block FFAlertView *alert = [[FFAlertView alloc] initWithTitle:@""
                                                           messsage:nil
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.rosterController.view];
 
    [self.marketsSetRegular fetchType:FFMarketTypeRegularSeason completion:^{
        self.errorType = FFErrorTypeNoError;
        [self.marketsSetSingle fetchType:FFMarketTypeSingleElimination completion:^{
            self.errorType = FFErrorTypeNoError;
            [alert hide];
        }];
    }];
}

- (void)marketsUpdated
{
    [self.rosterController.tableView reloadData];
    NSArray *markets = [self availableMarkets];
    if (markets.count > 0) {
        
        if ([self.rosterController respondsToSelector:@selector(marketSelected:)]) {
            [self.rosterController performSelector:@selector(marketSelected:) withObject:markets.firstObject];
        }
        if ([self.playersController respondsToSelector:@selector(marketSelected:)]) {
            [self.playersController performSelector:@selector(marketSelected:) withObject:markets.firstObject];
        }
    } else {
        self.selectedMarket = nil;
    }
}

#pragma mark - SBDataObjectResultSetDelegate

- (void)resultSetDidReload:(SBDataObjectResultSet*)resultSet
{
    self.errorType = FFErrorTypeNoError;
    if (resultSet.count > 0) {
        [self marketsUpdated];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } else {
        if (self.availableMarkets.count == 0) {
            self.roster = nil;
            [self.rosterController showOrHideSubmitIfNeeded];
            [self.rosterController.tableView reloadData];
            [self.playersController.tableView reloadData];
        }
    }
}

#pragma mark - Manage My Team

- (NSMutableDictionary *)emptyPosition
{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:@"", @"name", @"", @"player", nil];
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

- (BOOL)playerAlreadyInTeam:(FFPlayer *)player
{
    for (NSMutableDictionary *position in self.myTeam) {
        if ([position[@"player"] isKindOfClass:[FFPlayer class]]) {
            FFPlayer *pl = position[@"player"];
            if ([pl.name isEqualToString:player.name]) {
                return YES;
            }
        }
    }
    return NO;
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
                    if ([position[@"player"] isEqualToString:@""] && [self playerAlreadyInTeam:player] == NO) {
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

- (void)removeBenchedPlayersFromTeam
{
    for (NSMutableDictionary *position in self.myTeam) {
        if ([position[@"player"] isKindOfClass:[NSString class]] == NO) {
            FFPlayer *player = position[@"player"];
            if (player) {
                if ([player.benched integerValue] == 1) {
                    [self removePlayerFromMyTeam:player];
                }
            }
        }
    }
}

#pragma mark - FFEventsProtocol

- (NSString*)marketId
{
    return self.selectedMarket.objId;
}

#pragma mark - DataSource

- (void)showIndividualPredictionsForPlayer:(FFPlayer *)player
{
    [self.delegate openIndividualPredictionsForPlayer:player];
}

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

- (void)setCurrentMarket:(FFMarket *)market
{
    self.selectedMarket = market;
    [self.rosterController.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0
                                                                                 inSection:0]]
                                           withRowAnimation:UITableViewRowAnimationAutomatic];
    if (_rosterIsCreating == NO) {
        __weak FFFantasyManager *weakSelf = self;
        [self createRosterWithCompletion:^(NSError *error) {
            if (error) {
//                [self handleError:error];
//                [weakSelf.rosterController.tableView reloadData];
//                [weakSelf.playersController.tableView reloadData];
            } else {
//                [weakSelf.rosterController reloadWithServerError:NO];
                [weakSelf.playersController fetchPlayersWithShowingAlert:NO completion:^{
                    [weakSelf.playersController reloadWithServerError:NO ];
                }];
            }
        }];
    }
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

#pragma mark

- (void)createRosterWithCompletion:(void(^)(NSError* error))block
{
    _rosterIsCreating = YES;
    
//    if (!self.selectedMarket) {
//        self.roster = nil;
//        if (block) {
//            block(NO);
//        }
//        return;
//    }
    __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:@""
                                                           messsage:nil
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.rosterController.view];
    
    @weakify(self)
    [FFRoster createNewRosterForMarket:self.selectedMarket.objId
                               session:self.session
                               success:
     ^(id successObj) {
         @strongify(self)
         _rosterIsCreating = NO;
         self.unpaid = NO;
         [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"Unpaidsubscription"];
         self.roster = successObj;
         SBInteger *autoRemove = [[SBInteger alloc] initWithInteger:self.rosterController.removeBenched ? 1 : 0];
         self.roster.removeBenched = autoRemove;
         self.myTeam = [self newTeamWithPositions:[self allPositions]];
         
         [self.rosterController.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
         
         [alert hide];
         if (block) {
             block(nil);
         }
     }
                               failure:
     ^(NSError * error) {
         @strongify(self)
         _rosterIsCreating = NO;
         [self handleError:error];
         [alert hide];
         self.roster = nil;
         if (block)
             block(error);
     }];
}

- (void)addPlayer:(FFPlayer*)player
{
    __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:@"Buying Player"
                                                           messsage:nil
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.playersController.view];
    @weakify(self)
    [self.roster addPlayer:player
                   success:
     ^(id successObj) {
         @strongify(self)
         [alert hide];
         [self addPlayerToMyTeam:player];
         [self.rosterController refreshRosterWithShowingAlert:YES completion:nil];
         [self.delegate shouldSetViewController:self.rosterController
                                      direction:UIPageViewControllerNavigationDirectionReverse
                                       animated:YES
                                     completion:nil];
     }
                   failure:
     ^(NSError *error) {
         @strongify(self)
         [alert hide];
         [self handleError:error];
     }];
}

- (void)fetchPositionsNames
{
    @weakify(self)
    [FFRoster fetchPositionsForSession:self.session
                               success:
     ^(id successObj) {
         @strongify(self)
         self.errorType = FFErrorTypeNoError;
         self.positionsNames = successObj;
     }
                               failure:
     ^(NSError *error) {
         @strongify(self)
         self.positionsNames = @{};
         [self handleError:error];
         // ???: should we show any Error Alert here?
     }];
}

- (void)showPosition:(NSString*)position
{
    @weakify(self)
    [self.delegate shouldSetViewController:self.playersController
                                 direction:UIPageViewControllerNavigationDirectionForward
                                  animated:YES
                                completion:^(BOOL finished) {
                                    @strongify(self)
                                    [self.playersController showPosition:position];
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
         [self handleError:error];
         if (block)
             block(NO);
     }];
}

- (void)submitRoster:(FFRosterSubmitType)rosterType completion:(void (^)(BOOL))block
{
    __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:@"Submitting Roster"
                                                           messsage:nil
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.rosterController.view];
    
    @weakify(self)
    [self.roster submitContent:rosterType
                       success:
     ^(id successObj) {
         @strongify(self)
         [alert hide];
         if (block)
             block(YES);

         [self createRosterWithCompletion:^(NSError *error) {
             [self.rosterController showOrHideSubmitIfNeeded];
         }];
     }
                       failure:
     ^(NSError * error) {
         @strongify(self)
         [alert hide];
         [self handleError:error];
         if (block)
             block(NO);
     }];
}

- (void)autoFillWithCompletion:(void(^)(BOOL success))block
{
    __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:@"Auto Fill Roster"
                                                           messsage:nil
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.rosterController.view];
    
    @weakify(self)
    [self.roster autofillSuccess:
     ^(id successObj) {
         @strongify(self)
         [alert hide];
         self.roster = successObj;
         self.myTeam = [self newTeamWithPositions:[self allPositions]];
         for (FFPlayer *player in self.roster.players) {
             [self addPlayerToMyTeam:player];
         }
         SBInteger *autoRemove = [[SBInteger alloc] initWithInteger:self.rosterController.removeBenched ? 1 : 0];
         self.roster.removeBenched = autoRemove;
         
         [self.rosterController.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
         [self.rosterController showOrHideSubmitIfNeeded];
         
         if (block)
             block(YES);
     }
                         failure:
     ^(NSError *error) {
         @strongify(self)
         [alert hide];
         [self handleError:error];
         self.roster = nil;
         if (block)
             block(NO);
     }];
}

- (void)toggleRemoveBenchWithCompletion:(void(^)(BOOL success))block
{
    __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:@"Toggle Auto-Remove Benched Players"
                                                           messsage:nil
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.rosterController.view];
    
    @weakify(self)
    [self.roster toggleRemoveBenchedSuccess:
     ^(id successObj) {
         @strongify(self)
         [alert hide];
         self.roster = successObj;
         if ([self.roster.removeBenched integerValue] == 1) {
             [self removeBenchedPlayersFromTeam];
             for (FFPlayer *player in self.roster.players) {
                 [self addPlayerToMyTeam:player];
             }
         }
         SBInteger *autoRemove = [[SBInteger alloc] initWithInteger:self.rosterController.removeBenched ? 1 : 0];
         self.roster.removeBenched = autoRemove;
         [self.rosterController.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
         
         if (block)
             block(YES);
     }
                                    failure:
     ^(NSError *error) {
         @strongify(self)
         [alert hide];
         [self handleError:error];
         self.roster = nil;
         if (block)
             block(NO);
     }];
}

- (void)refreshRosterWithCompletion:(void(^)(BOOL success))block
{
    __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:@""
                                                           messsage:nil
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.rosterController.view];
    
    if (self.roster) {
        @weakify(self)
        [self.roster refreshInBackgroundWithBlock:
         ^(id successObj) {
             @strongify(self)
             [alert hide];
             self.roster = successObj;
             SBInteger *autoRemove = [[SBInteger alloc] initWithInteger:self.rosterController.removeBenched ? 1 : 0];
             self.roster.removeBenched = autoRemove;
             [self.rosterController.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
             
             if (block)
                 block(YES);
         }
                                          failure:
         ^(NSError *error) {
             @strongify(self)
             [alert hide];
             [self handleError:error];
             self.roster = nil;
             
             if (block)
                 block(NO);
         }];
    } else {
        [self createRosterWithCompletion:nil];
    }
}

- (void)fetchPlayersForPosition:(NSInteger)position WithShowingAlert:(BOOL)shouldShow completion:(void(^)(void))block
{
    if (![self.currentRoster objId]) {
        self.playersController.players = @[];
        [self.playersController.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                                        withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }
    
    __block FFAlertView* alert = nil;
    if (shouldShow) {
        alert = [[FFAlertView alloc] initWithTitle:@"Loading Players"
                                          messsage:nil
                                      loadingStyle:FFAlertViewLoadingStylePlain];
        [alert showInView:self.playersController.view];
    }
    
    __block BOOL shouldRemoveBenched = [[self currentRoster] removeBenched].integerValue == 1;
    
    @weakify(self)
    [FFPlayer fetchPlayersForRoster:[self rosterId]
                           position:[self uniquePositions][position]
                     removedBenched:shouldRemoveBenched
                            session:self.session
                            success:
     ^(id successObj) {
         @strongify(self)
         self.playersController.players = successObj;
         
         if(alert)
             [alert hide];
         if (block)
             block();
     }
                            failure:
     ^(NSError *error) {
         @strongify(self)
         self.playersController.players = @[];
         [self handleError:error];
         if(alert)
             [alert hide];
         if (block)
             block();
     }];
}

@end
