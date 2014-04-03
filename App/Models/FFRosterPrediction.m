//
//  FFRosterPrediction.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/3/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFRosterPrediction.h"
#import <SBData/NSDictionary+Convenience.h>

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
@dynamic contestType;
@dynamic players;
@dynamic market;

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
              @"contest" : @"contest",
              @"contestType" : @"contest_type",
              @"players" : @"players",
              @"market" : @"market"
              }];
}

@end
