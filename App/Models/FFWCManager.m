//
//  FFWCManager.m
//  FMF Football
//
//  Created by Anton on 5/31/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFWCManager.h"

#import "FFWCController.h"
#import "FFAlertView.h"

#import "FFSession.h"
#import "FFWCGame.h"
#import "FFWCGroup.h"
#import "FFWCTeam.h"
#import "FFWCPlayer.h"
#import "FFSession.h"

@interface FFWCManager()

@property (nonatomic, strong) FFWCController* dailyWinsController;
@property (nonatomic, strong) FFWCController* mvpController;
@property (nonatomic, strong) FFWCController* cupWinnerController;
@property (nonatomic, strong) FFWCController* groupWinnerController;

@property (nonatomic, strong) FFSession *session;

@end

@implementation FFWCManager


+ (FFWCManager*)shared
{
    static dispatch_once_t onceToken;
    static FFWCManager* shared;
    dispatch_once(&onceToken, ^{
        shared = [self new];
    });
    return shared;
}

- (void)setupWithSession:(FFSession *)session andPagerController:(UIPageViewController *)pager
{
    
}

- (void)getWorldCupData
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
//    __block FFAlertView *alert = [[FFAlertView alloc] initWithTitle:@""
//                                                           messsage:nil
//                                                       loadingStyle:FFAlertViewLoadingStylePlain];
//    [alert showInView:self.navigationController.view];
    
    [self fetchDataForSession:self.session
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
//                               __weak FFPagerController *weakSelf = self;
//                               [self setViewControllers:@[[self.del getViewControllers].firstObject]
//                                              direction:UIPageViewControllerNavigationDirectionForward
//                                               animated:NO
//                                             completion:^(BOOL finished) {
//                                                 if (finished) {
//                                                     weakSelf.pager.numberOfPages = (int)[weakSelf.del getViewControllers].count;
//                                                     weakSelf.pager.currentPage = (int)[[weakSelf.del getViewControllers] indexOfObject:weakSelf.viewControllers.firstObject];
//                                                     
//                                                     [weakSelf.dailyWinsController.tableView reloadData];
//                                                     [weakSelf.cupWinnerController.tableView reloadData];
//                                                     [weakSelf.groupWinnerController.tableView reloadData];
//                                                     [weakSelf.mvpController.tableView reloadData];
//                                                 }
//                                             }];
//                               
//                               [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//                               [alert hide];
                           }];
}

- (void)fetchDataForSession:(FFSession *)session dataWithCompletion:(void(^)(BOOL success))block
{
    NSString *path = @"home";
    [session authorizedJSONRequestWithMethod:@"GET"
                                        path:path
                                   paramters:@{@"sport" : FOOTBALL_WC}
                                     success:^(NSURLRequest *request, NSHTTPURLResponse *httpResponse, id JSON) {
                                         NSLog(@" @{FFWCM} : JSON : %@", JSON);
                                         NSArray *dailyWinsDicts = [JSON objectForKey:@"daily_wins"];
                                         _dailyWins = [NSMutableArray arrayWithCapacity:dailyWinsDicts.count];
                                         for (NSDictionary *gameDict in dailyWinsDicts) {
                                             FFWCGame *game = [[FFWCGame alloc] initWithDictionary:gameDict];
                                             [_dailyWins addObject:game];
                                         }
                                         
                                         NSArray *groupWinnersDicts = [JSON objectForKey:@"win_groups"];
                                         _groupWinners = [NSMutableArray arrayWithCapacity:groupWinnersDicts.count];
                                         for (NSDictionary *groupDict in groupWinnersDicts) {
                                             FFWCGroup *group = [[FFWCGroup alloc] initWithDictionary:groupDict];
                                             [_groupWinners addObject:group];
                                         }
                                         
                                         NSArray *cupWinnersDicts = [JSON objectForKey:@"win_the_cup"];
                                         _cupWinners = [NSMutableArray arrayWithCapacity:cupWinnersDicts.count];
                                         for (NSDictionary *teamDict in cupWinnersDicts) {
                                             FFWCTeam *team = [[FFWCTeam alloc] initWithDictionary:teamDict];
                                             [_cupWinners addObject:team];
                                         }
                                         
                                         NSArray *mvpCandidatesDicts = [JSON objectForKey:@"mvp"];
                                         _mvpCandidates = [NSMutableArray arrayWithCapacity:mvpCandidatesDicts.count];
                                         for (NSDictionary *playerDict in mvpCandidatesDicts) {
                                             FFWCPlayer *player = [[FFWCPlayer alloc] initWithDictionary:playerDict];
                                             [_mvpCandidates addObject:player];
                                         }
                                         
                                         if (block)
                                             block(YES);
                                         
                                     } failure:^(NSURLRequest *request, NSHTTPURLResponse *httpResponse, NSError *error, id JSON) {
                                         NSLog(@" {FFWCM} : error during fetching data : %@", error);
                                         if (block)
                                             block(NO);
                                     }];
}

- (NSArray*)getViewControllers
{
    NSMutableArray *controllers = [NSMutableArray array];
    if (self.dailyWinsController.candidates.count > 0 /*|| self.networkStatus == NotReachable*/) {
        [controllers addObject:self.dailyWinsController];
    }
    if (self.cupWinnerController.candidates.count > 0 /*|| self.networkStatus == NotReachable*/) {
        [controllers addObject:self.cupWinnerController];
    }
    if (self.groupWinnerController.candidates.count > 0 /*|| self.networkStatus == NotReachable*/) {
        [controllers addObject:self.groupWinnerController];
    }
    if (self.mvpController.candidates.count > 0/*|| self.networkStatus == NotReachable*/) {
        [controllers addObject:self.mvpController];
    }
    
    return [NSArray arrayWithArray:controllers];
}

- (NSString *)stringForWCCategory:(FFWCPredictionCategory)category
{
    switch (category) {
        case FFWCCupWinner:
            return @"win_the_cup";
        case FFWCGroupWinners:
            return @"win_groups";
        case FFWCDailyWins:
            return @"daily_wins";
        case FFWCMvp:
            return @"mvp";
            
        default:
            return nil;
    }
}

- (void)disablePTInCupWinnersForTeam:(FFWCTeam *)team
{
    for (FFWCTeam *t in self.cupWinners) {
        if ([t.statsId isEqualToString:team.statsId])
            t.disablePT = YES;
    }
}

- (void)disablePTInGroupWinnersTeam:(FFWCTeam *)team
{
    for (FFWCGroup *group in self.groupWinners) {
        for (FFWCTeam *t in group.teams)
            if ([t.statsId isEqualToString:team.statsId])
                t.disablePT = YES;
    }
}

- (void)disablePTInDailyWinsForTeam:(FFWCTeam *)team inGame:(FFWCGame *)game
{
    for (FFWCGame *g in self.dailyWins) {
        if ([game.statsId isEqualToString:g.statsId]) {
            if ([game.homeTeam.statsId isEqualToString:team.statsId])
                game.homeTeam.disablePT = YES;
            else if ([game.guestTeam.statsId isEqualToString:team.statsId])
                game.guestTeam.disablePT = YES;
            else
                assert(NO);
        }
    }
}

- (void)disablePTForPlayer:(FFWCPlayer *)player
{
    for (FFWCPlayer *candidate in self.mvpCandidates) {
        if ([candidate.statsId isEqualToString:player.statsId])
            candidate.disablePT = YES;
    }
}

- (void)disablePTForTeam:(FFWCTeam *)team inGame:(FFWCGame *)game inCategory:(FFWCPredictionCategory)category
{
    switch (category) {
        case FFWCCupWinner:
            [self disablePTInCupWinnersForTeam:team];
            break;
        case FFWCGroupWinners:
            [self disablePTInGroupWinnersTeam:team];
            break;
        case FFWCDailyWins:
            [self disablePTInDailyWinsForTeam:team inGame:game];
            break;
            
        default:
            break;
    }
}

@end
