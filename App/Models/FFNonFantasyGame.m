//
//  FFNonFantasyGame.m
//  FMF Football
//
//  Created by Anton Chuev on 5/21/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFNonFantasyGame.h"
#import "FFSessionManager.h"
#import <SBData/NSDictionary+Convenience.h>

@implementation FFNonFantasyGame

@dynamic homeTeamStatsId;
@dynamic awayTeamStatsId;
@dynamic homeTeamName;
@dynamic awayTeamName;
@dynamic homeTeamLogoURL;
@dynamic awayTeamLogoURL;
@dynamic homeTeamPT;
@dynamic awayTeamPT;
@dynamic gameStatsId;

+ (NSString *)tableName
{
    return @"ffnonfantasygame";
}

+ (NSString *)bulkPath
{
    return @"game_predictions/day_games";
}

+ (NSDictionary *)propertyToNetworkKeyMapping
{
    return [[super propertyToNetworkKeyMapping] dictionaryByMergingWithDictionary:@{
                                                                                    @"homeTeamStatsId":     @"home_team_stats_id",
                                                                                    @"awayTeamStatsId":     @"away_team_stats_id",
                                                                                    @"homeTeamName":        @"home_team_name",
                                                                                    @"awayTeamName":        @"away_team_name",
                                                                                    @"homeTeamLogoURL":     @"home_team_logo_url",
                                                                                    @"awayTeamLogoURL":     @"away_team_logo_url",
                                                                                    @"homeTeamPT":          @"home_team_pt",
                                                                                    @"awayTeamPT":          @"away_team_pt",
                                                                                    @"gameStatsId":         @"game_stats_id"
                                                                                    }];
}

+ (void)fetchGamesSession:(SBSession*)session
                  success:(SBSuccessBlock)success
                  failure:(SBErrorBlock)failure
{
    NSDictionary *params = @{
                             @"sport" : [FFSessionManager shared].currentSportName
                             };
    
    [session authorizedJSONRequestWithMethod:@"GET"
                                        path:[self bulkPath]
                                   paramters:params
                                     success:^(NSURLRequest *request, NSHTTPURLResponse *httpResponse, id JSON) {
                                         if ([[JSON objectForKey:@"games"] isKindOfClass:[NSArray class]] == NO) {
                                             if (failure) {
                                                 failure(nil);
                                             }
                                         }
                                         
                                         NSArray *gamesDictionaries = [JSON objectForKey:@"games"];
                                         NSMutableArray *gamesObjects = [NSMutableArray arrayWithCapacity:gamesDictionaries.count];
                                         for (NSDictionary *dict in gamesDictionaries) {
                                             FFNonFantasyGame *game = [self fromNetworkRepresentation:dict
                                                                                              session:session
                                                                                                 save:NO];
                                             [gamesObjects addObject:game];
                                         }
                                         
                                         if (success) {
                                             success(gamesObjects);
                                         }
                                     } failure:^(NSURLRequest *request, NSHTTPURLResponse *httpResponse, NSError *error, id JSON) {
                                         if (failure) {
                                             failure(error);
                                         }
                                     }];
}

@end
