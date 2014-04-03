//
//  FFRosterPrediction.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/3/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFRosterPrediction.h"
#import <SBData/NSDictionary+Convenience.h>
#import "FFPlayer.h"
#import "FFContestType.h"
#import "FFMarket.h"

@implementation FFRosterPrediction

@dynamic ownerId;
@dynamic ownerName;
@dynamic state;
@dynamic contestId;
@dynamic buyIn;
@dynamic remainingSalary;
@dynamic score;
@dynamic contestRank;
@dynamic contestRankPayout;
@dynamic amountPaid;
@dynamic paidAt;
@dynamic cancelledCause;
@dynamic cancelledAt;
@dynamic positions;
@dynamic startedAt;
@dynamic marketId;
@dynamic nextGameTime;
@dynamic live;
@dynamic bonusPoints;
@dynamic perfectScore;
@dynamic removeBenched;
@dynamic viewCode;
@dynamic abridged;
@dynamic league;
@dynamic contest;

+ (NSString*)tableName
{
    return @"ffroster_prediction";
}

+ (void)load
{
    [self registerModel:self];
}

+ (NSString*)bulkPath
{
    return @"/rosters/mine";
}

+ (NSDictionary*)propertyToNetworkKeyMapping
{
    return [[super propertyToNetworkKeyMapping] dictionaryByMergingWithDictionary:
            @{
              @"ownerId" : @"owner_id",
              @"ownerName" : @"owner_name",
              @"state" : @"state",
              @"contestId" : @"contest_id",
              @"buyIn" : @"buy_in",
              @"remainingSalary" : @"remaining_salary",
              @"score" : @"score",
              @"contestRank" : @"contest_rank",
              @"contestRankPayout" : @"contest_rank_payout",
              @"amountPaid" : @"amount_paid",
              @"paidAt" : @"paid_at",
              @"cancelledCause" : @"cancelled_cause",
              @"cancelledAt" : @"cancelled_at",
              @"positions" : @"positions",
              @"startedAt" : @"started_at",
              @"marketId" : @"market_id",
              @"nextGameTime" : @"next_game_time",
              @"live" : @"live",
              @"bonusPoints" : @"bonus_points",
              @"perfectScore" : @"perfect_score",
              @"removeBenched" : @"remove_benched",
              @"viewCode" : @"view_code",
              @"abridged" : @"abridged",
              @"league" : @"league",
              @"contest" : @"contest"
              }];
}

- (void)setValuesForKeysWithNetworkDictionary:(NSDictionary*)keyedValues
{
    if (![keyedValues isKindOfClass:[NSDictionary class]]) {
        return;
    }
    [super setValuesForKeysWithNetworkDictionary:keyedValues];
    self.contestTypeId = [keyedValues valueForKeyPath:@"contest_type.id"];
    if ([self.contestTypeId isKindOfClass:[NSString class]]) {
        self.contestType = [FFContestType fromNetworkRepresentation:keyedValues[@"contest_type"]
                                                            session:self.session
                                                               save:YES];
    }
    self.marketId = [keyedValues valueForKeyPath:@"market.id"];
    if ([self.marketId isKindOfClass:[NSString class]]) {
        self.market = [FFMarket fromNetworkRepresentation:keyedValues[@"market"]
                                                  session:self.session
                                                     save:YES];
    }

    NSArray* playerDictionaries = keyedValues[@"players"];
    NSMutableArray* players = [NSMutableArray arrayWithCapacity:playerDictionaries.count];
    for (NSDictionary* playerDictionary in playerDictionaries) {
        [players addObject:[FFPlayer fromNetworkRepresentation:playerDictionary
                                                       session:self.session
                                                          save:YES]];
    }
    self.players = [players copy];
}

@end
