//
//  FFFantasyGame.m
//  FMF Football
//
//  Created by Anton Chuev on 5/21/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFFantasyGame.h"
#import "FFDate.h"
#import <SBData/NSDictionary+Convenience.h>

@implementation FFFantasyGame

@dynamic awayTeam;
@dynamic gameDay;
@dynamic homeTeam;
@dynamic network;
@dynamic seasonType;
@dynamic seasonWeek;
@dynamic seasonYear;
@dynamic statsId;
@dynamic scheduled;

+ (NSString *)tableName
{
    return @"fffantasygame";
}

+ (NSString *)bulkPath
{
    return @"/games";
}

+ (NSDictionary *)propertyToNetworkKeyMapping
{
    return [[super propertyToNetworkKeyMapping] dictionaryByMergingWithDictionary:@{
                                                                                    @"awayTeam":    @"away_team",
                                                                                    @"gameDay":     @"game_day",
                                                                                    @"homeTeam":    @"home_team",
                                                                                    @"network":     @"network",
                                                                                    @"seasonType":  @"season_type",
                                                                                    @"seasonWeek":  @"season_week",
                                                                                    @"seasonYear":  @"season_year",
                                                                                    @"statsId":     @"stats_id",
                                                                                    @"status":      @"status"
                                                                                    }];
}

@end
