//
//  FFRosterPrediction.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/3/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "SBDataObject.h"

@class FFMarket;
@class FFContestType;

@interface FFRosterPrediction : SBDataObject // TODO: check, is it same with FFRoster ???

@property(nonatomic) NSString* ownerId;
@property(nonatomic) NSString* ownerName;
@property(nonatomic) NSString* state;
@property(nonatomic) SBInteger* contestId;
@property(nonatomic) NSString* buyIn;
@property(nonatomic) NSString* remainingSalary;
@property(nonatomic) SBInteger* score;
@property(nonatomic) SBInteger* contestRank;
@property(nonatomic) SBInteger* contestRankPayout;
@property(nonatomic) SBInteger* amountPaid;
@property(nonatomic) SBDate* paidAt;
@property(nonatomic) NSString* cancelledCause;
@property(nonatomic) SBDate* cancelledAt;
@property(nonatomic) NSString* positions;
@property(nonatomic) SBDate* startedAt;
@property(nonatomic) SBDate* nextGameTime;
@property(nonatomic) SBInteger* live;
@property(nonatomic) SBInteger* bonusPoints;
@property(nonatomic) NSString* perfectScore;
@property(nonatomic) NSString* removeBenched;
@property(nonatomic) NSString* viewCode;
@property(nonatomic) NSString* abridged;
@property(nonatomic) NSString* league;
@property(nonatomic) NSDictionary* contest;
@property(nonatomic) NSArray* players;
#pragma mark - Contest
@property(nonatomic) FFContestType* contestType;
@property(nonatomic) NSString* contestTypeId;
#pragma mark - Market
@property(nonatomic) FFMarket* market;
@property(nonatomic) NSString* marketId;

@end
