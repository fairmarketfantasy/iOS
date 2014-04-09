//
//  FFMarket.m
//  FMF Football
//
//  Created by Samuel Sutch on 9/23/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import "FFMarket.h"
#import <SBData/NSDictionary+Convenience.h>
#import "NSDate+ISO8601.h"
#import "FFMarketSet.h"
#import "FFGame.h"

@implementation FFMarket

@dynamic closedAt;
@dynamic marketDuration;
@dynamic name;
@dynamic openedAt;
@dynamic shadowBetRate;
@dynamic shadowBets;
@dynamic sportId;
@dynamic startedAt;
@dynamic state;
@dynamic totalBets;

+ (NSString*)tableName
{
    return @"ffmarket";
}

+ (void)load
{
    [self registerModel:self];
}

+ (NSString*)bulkPath
{
    return @"/markets";
}

+ (NSDictionary*)propertyToNetworkKeyMapping
{
    return [[super propertyToNetworkKeyMapping] dictionaryByMergingWithDictionary:@{
                @"closedAt":        @"closed_at",
                @"marketDuration":  @"market_duration",
                @"name":            @"name",
                @"openedAt":        @"opened_at",
                @"shadowBetRate":   @"shadow_bet_rate",
                @"shadowBets":      @"shadow_bets",
                @"sportId":         @"sport_id",
                @"startedAt":       @"started_at",
                @"state":           @"state",
                @"totalBets":       @"total_bets"
            }];
}

+ (FFMarketSet*)getBulkWithSession:(SBSession*)session
                        authorized:(BOOL)isAuthorizedRequest
{
    return [[FFMarketSet alloc] initWithDataObjectClass:self
                                                session:session
                                             authorized:isAuthorizedRequest];
}

- (void)setValuesForKeysWithNetworkDictionary:(NSDictionary*)keyedValues
{
    if (![keyedValues isKindOfClass:[NSDictionary class]]) {
        return;
    }
    [super setValuesForKeysWithNetworkDictionary:keyedValues];
    NSArray* gamesDictionaries = keyedValues[@"games"];
    NSMutableArray* games = [NSMutableArray arrayWithCapacity:gamesDictionaries.count];
    for (NSDictionary* gameDictionary in gamesDictionaries) {
        [games addObject:[FFGame fromNetworkRepresentation:gameDictionary
                                                   session:self.session
                                                      save:YES]];
    }
    self.games = [games copy];
}

@end
