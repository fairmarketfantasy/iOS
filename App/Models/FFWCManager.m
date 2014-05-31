//
//  FFWCManager.m
//  FMF Football
//
//  Created by Anton on 5/31/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFWCManager.h"
#import "FFSession.h"
#import "FFWCGame.h"
#import "FFWCGroup.h"
#import "FFWCTeam.h"
#import "FFWCPlayer.h"

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

- (void)fetchDataForSession:(FFSession *)session dataWithCompletion:(void(^)(BOOL success))block
{
    NSString *path = @"home";
    [session authorizedJSONRequestWithMethod:@"GET"
                                        path:path
                                   paramters:@{@"sport" : @"FWC"}
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

@end
