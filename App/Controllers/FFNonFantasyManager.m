//
//  FFNonFantasyManager.m
//  FMF Football
//
//  Created by Anton Chuev on 6/10/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFNonFantasyManager.h"
#import "FFNonFantasyRosterController.h"
#import "FFGamesController.h"
#import "FFNonFantasyRosterDataSource.h"
#import "FFAlertView.h"
#import "FFNonFantasyGame.h"
#import "FFTeam.h"
#import "FFIndividualPrediction.h"
#import "FFRoster.h"
#import "Reachability.h"

@interface FFNonFantasyManager() <FFNonFantasyRosterDataSource, FFNonFantasyRosterDelegate, FFGamesProtocol>
{
    Reachability* internetReachability;
}

@property (nonatomic, strong) FFNonFantasyRosterController *rosterController;
@property (nonatomic, strong) FFGamesController *gamesController;
@property (nonatomic, strong) NSMutableArray *games;
@property (nonatomic, strong) NSMutableArray *selectedTeams;
@property (nonatomic, assign) NetworkStatus networkStatus;

@end

@implementation FFNonFantasyManager

- (id)initWithSession:(FFSession *)session
{
    self = [super initWithSession:session];
    if (self) {
        self.selectedTeams = [NSMutableArray array];
        
        self.rosterController = [FFNonFantasyRosterController new];
        self.rosterController.delegate = self;
        self.rosterController.dataSource = self;
        self.rosterController.errorDelegate = self;
        
        self.gamesController = [FFGamesController new];
        self.gamesController.delegate = self;
        self.gamesController.dataSource = self;
        self.gamesController.errorDelegate = self;
        
        self.rosterController.session = session;
        self.gamesController.session = session;
        
        //reachability
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusHasChanged:) name:kReachabilityChangedNotification object:nil];
        internetReachability = [Reachability reachabilityForInternetConnection];
        BOOL success = [internetReachability startNotifier];
        if (!success)
            DLog(@"Failed to start notifier");
        self.networkStatus = [internetReachability currentReachabilityStatus];
    }
    
    return self;
}

- (void)start
{
    [self updateGames];
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
            [self updateGames];
        }
    }
}

- (NSArray *)getViewControllers
{
    return @[
             self.rosterController,
             self.gamesController
             ];
}

- (void)updateGames
{
    self.games = [NSMutableArray array];
    [self fetchGamesShowAlert:YES withCompletion:nil];
}

#pragma mark - Error handling

- (void)handleError:(NSError *)error
{
    NSLog(@"Error: %@", error);
    NSString *errorDescription = [[error userInfo] objectForKey:@"NSLocalizedDescription"];
    if ([errorDescription isEqualToString:@"Unpaid subscription!"]) {
        self.unpaidSubscription = YES;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"Unpaidsubscription"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        self.errorType = FFErrorTypeUnknownServerError;
    }
    
    [self.rosterController.tableView reloadData];
    [self.rosterController showOrHideSubmitIfNeeded];
    [self.gamesController.tableView reloadData];
}

#pragma mark

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

#pragma mark

- (void)fetchGamesShowAlert:(BOOL)shouldShow withCompletion:(void (^)(void))block
{
    __block FFAlertView *alert = nil;
    if (shouldShow){
        alert = [[FFAlertView alloc] initWithTitle:nil
                                          messsage:@""
                                      loadingStyle:FFAlertViewLoadingStylePlain];
        [alert showInView:self.rosterController.view];
    }
    
    [FFNonFantasyGame fetchGamesSession:self.session
                                success:^(id successObj) {
                                    self.errorType = FFErrorTypeNoError;
                                    self.unpaidSubscription = NO;
                                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"Unpaidsubscription"];
                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                    NSMutableArray *games = [NSMutableArray array];
                                    for (FFNonFantasyGame *game in successObj) {
                                        [game setupTeams];
                                        [games addObject:game];
                                    }
                                    self.games = [NSMutableArray arrayWithArray:games];
                                    [self updateSelectedGames];
                                    [self.rosterController.tableView reloadData];
                                    [self.gamesController.tableView reloadData];
                                    if (alert)
                                        [alert hide];
                                    if (block)
                                        block();
                                } failure:^(NSError *error) {
                                    [self handleError:error];
                                    if (alert)
                                        [alert hide];
                                    if (block)
                                        block();
                                }];
}

- (void)makeIndividualPredictionOnTeam:(FFTeam *)team
{
    FFAlertView* confirmAlert = [FFAlertView.alloc initWithTitle:nil
                                                         message:[NSString stringWithFormat:@"Predict %@ ?", team.name]
                                               cancelButtonTitle:@"Cancel"
                                                 okayButtonTitle:@"Submit"
                                                        autoHide:NO];
    [confirmAlert showInView:self.rosterController.navigationController.view];
    @weakify(confirmAlert)
    @weakify(self)
    confirmAlert.onOkay = ^(id obj) {
        @strongify(confirmAlert)
        @strongify(self)
        __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:@"Individual Predictions"
                                                               messsage:nil
                                                           loadingStyle:FFAlertViewLoadingStylePlain];
        [alert showInView:self.rosterController.navigationController.view];
        
        [FFIndividualPrediction submitPredictionForTeam:team.statsId
                                                 inGame:team.gameStatsId
                                                session:self.session
                                                success:^(id successObj) {
                                                    self.errorType = FFErrorTypeNoError;
                                                    [self disablePTForTeam:team];
                                                    [self.gamesController.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                                                                                  withRowAnimation:UITableViewRowAnimationAutomatic];
                                                    [alert hide];
                                                    
                                                } failure:^(NSError *error) {
                                                    [self handleError:error];
                                                    [alert hide];
                                                }];
        [confirmAlert hide];
    };
    
    confirmAlert.onCancel = ^(id obj) {
        @strongify(confirmAlert)
        [confirmAlert hide];
    };
}

- (void)addTeam:(FFTeam *)newTeam
{
    if (self.selectedTeams.count == 5) {
        FFAlertView *alert = [[FFAlertView alloc] initWithTitle:nil
                                                        message:@"Roster is full"
                                              cancelButtonTitle:nil
                                                okayButtonTitle:@"OK"
                                                       autoHide:YES];
        [alert showInView:self.gamesController.view];
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
        [alert showInView:self.gamesController.view];
        return;
    }
    
    [self setTeam:newTeam selected:YES];
    [self.selectedTeams addObject:newTeam];
    
    [self.delegate shouldSetViewController:self.rosterController
                                 direction:UIPageViewControllerNavigationDirectionReverse
                                  animated:YES
                                completion:nil];
    
    [self.rosterController.tableView reloadData];
    [self.rosterController showOrHideSubmitIfNeeded];
}

#pragma mark - FFNonFantasyRosterDataSource

- (NSArray *)availableGames
{
    return self.games;
}

- (NSArray *)teams
{
    return self.selectedTeams;
}

#pragma mark - FFNonFantasyRosterDelegate

- (void)removeTeam:(FFTeam *)removedTeam
{
    [self setTeam:removedTeam selected:NO];
    for (FFTeam *team in self.selectedTeams) {
        if ([team.name isEqualToString:removedTeam.name]){
            [self.selectedTeams removeObject:team];
            break;
        }
    }
    
    [self.rosterController.tableView reloadData];
    
    [self.delegate shouldSetViewController:self.gamesController
                                 direction:UIPageViewControllerNavigationDirectionForward
                                  animated:YES
                                completion:nil];
}

- (void)showAvailableGames
{
    [self.delegate shouldSetViewController:self.gamesController
                                 direction:UIPageViewControllerNavigationDirectionForward
                                  animated:YES
                                completion:nil];
}

- (void)autoFillWithCompletion:(void(^)(BOOL success))block
{
    __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:@"Auto Fill Roster"
                                                           messsage:nil
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.rosterController.view];

    
    [self deselectAllTeams];
    
    [self.delegate shouldSetViewController:self.rosterController
                                 direction:UIPageViewControllerNavigationDirectionReverse
                                  animated:YES
                                completion:nil];
    
    [FFRoster autofillForSession:self.session
                         success:^(id successObj) {
                             self.errorType = FFErrorTypeNoError;
                             self.selectedTeams = [NSMutableArray arrayWithArray:successObj];
                             [self updateSelectedGames];
                             [self.rosterController.tableView reloadData];
                             [self.rosterController showOrHideSubmitIfNeeded];
                             [alert hide];
                             if (block)
                                 block(YES);
                         } failure:^(NSError *error) {
                             [alert hide];
                             [self handleError:error];
                             if (block)
                                 block(NO);
                         }];
}

- (void)submitRosterWithType:(FFRosterSubmitType)type completion:(void (^)(BOOL))block
{
    if (type == FFRosterSubmitTypePick5 && self.selectedTeams.count != 5) {
        FFAlertView *alert = [[FFAlertView alloc] initWithTitle:nil
                                                        message:@"You should have 5 teams in your roster to submit as pick5"
                                              cancelButtonTitle:nil
                                                okayButtonTitle:@"Dismiss"
                                                       autoHide:YES];
        [self.delegate showAlert:alert];
        return;
    }
    
    __block FFAlertView* alert = [[FFAlertView alloc] initWithTitle:@"Submitting Roster"
                                                           messsage:nil
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.rosterController.view];
    [self.rosterController showOrHideSubmitIfNeeded];
    
    NSMutableArray *teamsDicts = [NSMutableArray arrayWithCapacity:self.selectedTeams.count];
    for (FFTeam *team in self.selectedTeams) {
        NSDictionary * dict = @{
                                @"game_stats_id" : team.gameStatsId,
                                @"team_stats_id" : team.statsId,
                                @"position_index": [NSNumber numberWithInteger:[self.selectedTeams indexOfObject:team]]
                                };
        [teamsDicts addObject:dict];
    }
    
    [FFRoster submitNonFantasyRosterWithType:type
                                       teams:teamsDicts
                                     session:self.session
                                     success:^(id successObj) {
                                         self.errorType = FFErrorTypeNoError;
                                         [self deselectAllTeams];
                                         [self.rosterController.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                                                                        withRowAnimation:UITableViewRowAnimationAutomatic];
                                         [self.rosterController showOrHideSubmitIfNeeded];
                                         [alert hide];
                                         
                                         FFAlertView* successAlert = [[FFAlertView alloc] initWithTitle:nil
                                                                                                message:[successObj objectForKey:@"msg"]
                                                                                      cancelButtonTitle:nil
                                                                                        okayButtonTitle:@"OK"
                                                                                               autoHide:YES];
                                         [successAlert showInView:self.rosterController.navigationController.view];
                                         
                                         if (block)
                                             block(YES);
                                     } failure:^(NSError *error) {
                                         [self handleError:error];
                                         [alert hide];
                                         if (block)
                                             block(NO);
                                     }];
}

@end
