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
#import "FFEvent.h"
#import "FFRoster.h"

@interface FFNonFantasyManager() <FFNonFantasyRosterDataSource, FFNonFantasyRosterDelegate, FFGamesProtocol>

@property (nonatomic, strong) FFNonFantasyRosterController *rosterController;
@property (nonatomic, strong) FFGamesController *gamesController;

@property (nonatomic, strong) FFSession *session;

@property (nonatomic, weak) UIPageViewController *pageController;

@property(nonatomic, strong) NSMutableArray *games;
@property(nonatomic, strong) NSMutableArray *selectedTeams;

@end

@implementation FFNonFantasyManager

+ (FFNonFantasyManager*)shared
{
    static dispatch_once_t onceToken;
    static FFNonFantasyManager* shared;
    dispatch_once(&onceToken, ^{
        shared = [self new];
    });
    return shared;
}

- (void)setupWithSession:(FFSession *)session andPagerController:(UIPageViewController *)pager
{
    self.selectedTeams = [NSMutableArray array];
    
    self.rosterController = [FFNonFantasyRosterController new];
    self.rosterController.delegate = self;
    self.rosterController.dataSource = self;
    
    self.gamesController = [FFGamesController new];
    self.gamesController.delegate = self;
    self.gamesController.dataSource = self;
    
    self.pageController = pager;
    
    self.session = session;
    self.rosterController.session = session;
    self.gamesController.session = session;
    
    [self.selectedTeams removeAllObjects];
    [self updateGames];
    
//    [self.pageController setViewControllers:@[self.rosterController]
//                                  direction:UIPageViewControllerNavigationDirectionReverse
//                                   animated:NO
//                                 completion:nil];
}

- (void)updateGames
{
    self.games = [NSMutableArray array];
    [self fetchGamesShowAlert:YES withCompletion:nil];
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

- (NSArray *)availableGames
{
    return self.games;
}

- (NSArray *)teams
{
    return self.selectedTeams;
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
                                    NSLog(@"Success object: %@", successObj);
//                                    self.unpaid = NO;
                                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"Unpaidsubscription"];
                                    NSMutableArray *games = [NSMutableArray array];
                                    for (FFNonFantasyGame *game in successObj) {
                                        [game setupTeams];
                                        [games addObject:game];
                                    }
                                    self.games = [NSMutableArray arrayWithArray:games];
                                    [self updateSelectedGames];
                                    [self.rosterController reloadWithServerError:NO];
                                    [self.gamesController reloadWithServerError:NO];
                                    if (alert)
                                        [alert hide];
                                    if (block)
                                        block();
                                } failure:^(NSError *error) {
                                    NSLog(@"Error: %@", error);
                                    if (alert)
                                        [alert hide];
                                    if ([[[error userInfo] objectForKey:@"NSLocalizedDescription"] isEqualToString:@"Unpaid subscription!"]) {
//                                        self.unpaid = YES;
                                        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"Unpaidsubscription"];
                                    }
                                    
                                    [self.rosterController reloadWithServerError:YES];
                                    [self.gamesController reloadWithServerError:YES];
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
        
        [FFEvent fetchEventsForTeam:team.statsId
                             inGame:team.gameStatsId
                            session:self.session
                            success:^(id successObj) {
                                [self disablePTForTeam:team];
                                [self.rosterController.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                                                                 withRowAnimation:UITableViewRowAnimationAutomatic];
                                [alert hide];
                            } failure:^(NSError *error) {
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
    
    [self.pageController setViewControllers:@[self.rosterController]
                                  direction:UIPageViewControllerNavigationDirectionReverse
                                   animated:YES
                                 completion:nil];
    
//    self.pager.currentPage = (int)[[self.del getViewControllers] indexOfObject:
//                                   self.viewControllers.firstObject];
    
    [self.rosterController reloadWithServerError:NO];
}

#pragma mark 

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
    
    __weak FFNonFantasyManager *weakSelf = self;
    [self.pageController setViewControllers:@[self.gamesController]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:YES
                                 completion:^(BOOL finished) {
                                     if (finished)
//                                         weakSelf.pager.currentPage = (int)[[weakSelf getViewControllers] indexOfObject:
//                                                                            weakSelf.viewControllers.firstObject];
                                     [weakSelf.rosterController.tableView reloadData];
                                 }];
}

- (void)showAvailableGames
{
    [self.pageController setViewControllers:@[self.gamesController]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:YES
                                 completion:nil];
    
//    self.pager.currentPage = (int)[[self.del getViewControllers] indexOfObject:
//                                   self.viewControllers.firstObject];
}

- (void)autoFillWithCompletion:(void(^)(BOOL success))block
{
    [self deselectAllTeams];
    
//    if (self.pager.currentPage == 1) {
//        [self setViewControllers:@[self.teamController]
//                       direction:UIPageViewControllerNavigationDirectionReverse
//                        animated:YES
//                      completion:nil];
//        self.pager.currentPage = (int)[[self.del getViewControllers] indexOfObject:
//                                       self.viewControllers.firstObject];
//    }
    
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

- (void)submitRosterCompletion:(void (^)(BOOL))block
{
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
                                          [self.rosterController showOrHideSubmitIfNeeded];
                                          
                                          FFAlertView* alert = [[FFAlertView alloc] initWithTitle:nil
                                                                                          message:[successObj objectForKey:@"msg"]
                                                                                cancelButtonTitle:nil
                                                                                  okayButtonTitle:@"OK"
                                                                                         autoHide:YES];
                                          [alert showInView:self.rosterController.navigationController.view];
                                          
                                          if (block)
                                              block(YES);
                                      } failure:^(NSError *error) {
                                          NSLog(@"Error: %@", error);
                                          if (block)
                                              block(NO);
                                      }];
}

#pragma mark - FFPagerDelegate

- (NSArray *)getViewControllers
{
    return @[
             self.rosterController,
             self.gamesController
             ];
}

@end
