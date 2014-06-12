//
//  FFFantasyManager.m
//  FMF Football
//
//  Created by Anton Chuev on 6/10/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFFantasyManager.h"
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

@interface FFFantasyManager() <SBDataObjectResultSetDelegate, FFFantasyRosterDataSource,
FFFantasyRosterDelegate, FFPlayersProtocol, FFEventsProtocol>

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

@end

@implementation FFFantasyManager

- (id)initWithSession:(FFSession *)session
{
    self = [super initWithSession:session];
    if (self) {
        self.rosterController = [FFFantasyRosterController new];
        self.rosterController.delegate = self;
        self.rosterController.dataSource = self;
        
        self.playersController = [FFPlayersController new];
        self.playersController.delegate = self;
        self.playersController.dataSource = self;
        
        self.rosterController.session = session;
        self.playersController.session = session;
        
        self.marketsSetRegular = [[FFMarketSet alloc] initWithDataObjectClass:[FFMarket class]
                                                                      session:self.session authorized:YES];
        self.marketsSetSingle = [[FFMarketSet alloc] initWithDataObjectClass:[FFMarket class]
                                                                     session:self.session authorized:YES];
        self.marketsSetRegular.delegate = self;
        self.marketsSetSingle.delegate = self;
        
        [self fetchPositionsNames];
        [self updateMarkets];
    }
    return self;
}

- (NSArray *)getViewControllers
{
    return @[
             self.rosterController,
             self.playersController
             ];
}

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
        [self.marketsSetSingle fetchType:FFMarketTypeSingleElimination completion:^{
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
        [self createRosterWithCompletion:^(BOOL success) {
            if (success) {
                [weakSelf.rosterController reloadWithServerError:NO];
                [weakSelf.playersController fetchPlayersWithShowingAlert:NO completion:^{
                    [weakSelf.playersController reloadWithServerError:NO ];
                }];
            } else {
                [weakSelf.rosterController.tableView reloadData];
                [weakSelf.playersController.tableView reloadData];
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
         
         [alert hide];
         if (block) {
             block(YES);
         }
     }
                               failure:
     ^(NSError * error) {
         @strongify(self)
         _rosterIsCreating = NO;
         [alert hide];
         if ([[[error userInfo] objectForKey:@"NSLocalizedDescription"] isEqualToString:@"Unpaid subscription!"]) {
             self.unpaid = YES;
             self.roster = nil;
             [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"Unpaidsubscription"];
             if (block) {
                 block(NO);
             }
             return;
         } else {
             self.roster = nil;
             if (block) {
                 block(NO);
             }
         }
         //         if (self.tryCreateRosterTimes > 0) {
         //             self.tryCreateRosterTimes--;
         //             [self createRosterWithCompletion:block];
         //         } else {
         //             self.roster = nil;
         //             if (block) {
         //                 block(NO);
         //             }
         //         }
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
                                                     okayButtonTitle:@"Dismiss"
                                                            autoHide:YES];
             
             [alert showInView:self.playersController.view];
         }
     }];
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
         if (block)
             block(NO);
     }];
}

- (void)submitRoster:(FFRosterSubmitType)rosterType completion:(void (^)(BOOL))block
{
    @weakify(self)
    [self.roster submitContent:rosterType
                       success:
     ^(id successObj) {
         @strongify(self)
         if (block)
             block(YES);
         
         [self createRosterWithCompletion:^(BOOL success) {
             [self.rosterController reloadWithServerError:!success];
             [self.playersController reloadWithServerError:!success];
         }];
     }
                       failure:
     ^(NSError * error) {
         @strongify(self)
         if (block)
             block(NO);
         [self.rosterController.tableView reloadData];
     }];
}

- (void)autoFillWithCompletion:(void(^)(BOOL success))block
{
    @weakify(self)
    [self.roster autofillSuccess:
     ^(id successObj) {
         @strongify(self)
         self.roster = successObj;
         self.myTeam = [self newTeamWithPositions:[self allPositions]];
         for (FFPlayer *player in self.roster.players) {
             [self addPlayerToMyTeam:player];
         }
         SBInteger *autoRemove = [[SBInteger alloc] initWithInteger:self.rosterController.removeBenched ? 1 : 0];
         self.roster.removeBenched = autoRemove;
         
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

- (void)toggleRemoveBenchWithCompletion:(void(^)(BOOL success))block
{
    @weakify(self)
    [self.roster toggleRemoveBenchedSuccess:
     ^(id successObj) {
         @strongify(self)
         self.roster = successObj;
         if ([self.roster.removeBenched integerValue] == 1) {
             [self removeBenchedPlayersFromTeam];
             for (FFPlayer *player in self.roster.players) {
                 [self addPlayerToMyTeam:player];
             }
         }
         SBInteger *autoRemove = [[SBInteger alloc] initWithInteger:self.rosterController.removeBenched ? 1 : 0];
         self.roster.removeBenched = autoRemove;
         
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
    if (self.roster) {
        @weakify(self)
        [self.roster refreshInBackgroundWithBlock:
         ^(id successObj) {
             @strongify(self)
             self.roster = successObj;
             SBInteger *autoRemove = [[SBInteger alloc] initWithInteger:self.rosterController.removeBenched ? 1 : 0];
             self.roster.removeBenched = autoRemove;
             
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
        [self createRosterWithCompletion:^(BOOL success) {
            if (block)
                block(success);
        }];
    }
}

@end
