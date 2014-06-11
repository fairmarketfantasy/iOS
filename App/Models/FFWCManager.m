//
//  FFWCManager.m
//  FMF Football
//
//  Created by Anton on 5/31/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFWCManager.h"

#import "FFPagerController.h"
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

@property (nonatomic, weak) FFPagerController *pageController;

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
    self.dailyWinsController = [[FFWCController alloc] init];
    self.cupWinnerController = [[FFWCController alloc] init];
    self.groupWinnerController = [[FFWCController alloc] init];
    self.mvpController = [[FFWCController alloc] init];

    self.session = session;
    self.pageController = pager;
    
    [self getWorldCupData];
}

- (void)getWorldCupData
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    __block FFAlertView *alert = [[FFAlertView alloc] initWithTitle:nil
                                                           messsage:@""
                                                       loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.dailyWinsController.view];
    
    [self fetchDataForSession:self.session
           dataWithCompletion:^(BOOL success) {
               [alert hide];
               [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
               if (success) {
                   self.cupWinnerController.category = FFWCCupWinner;
                   self.cupWinnerController.candidates = [NSArray arrayWithArray:self.cupWinners];
                   
                   self.groupWinnerController.category = FFWCGroupWinners;
                   self.groupWinnerController.candidates = [NSArray arrayWithArray:self.groupWinners];
                   self.groupWinnerController.selectedCroupIndex = 0;
                   
                   self.dailyWinsController.category = FFWCDailyWins;
                   self.dailyWinsController.candidates = [NSArray arrayWithArray:self.dailyWins];
                   
                   self.mvpController.category = FFWCMvp;
                   self.mvpController.candidates = [NSArray arrayWithArray:self.mvpCandidates];
                   
                   [self.pageController setViewControllers:@[[self getViewControllers].firstObject]
                                                 direction:UIPageViewControllerNavigationDirectionForward
                                                  animated:NO
                                                completion:nil];
                   
                   [self.pageController updatePager];
                   
                   [self.dailyWinsController.tableView reloadData];
                   [self.cupWinnerController.tableView reloadData];
                   [self.groupWinnerController.tableView reloadData];
                   [self.mvpController.tableView reloadData];
               }
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

#pragma mark - FFPagerDelegate

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
    
    if (controllers.count == 0) {
        [controllers addObject:self.dailyWinsController];
    }
    
    return [NSArray arrayWithArray:controllers];
}

#pragma mark

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
