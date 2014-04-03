//
//  FFRosterPrediction.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/3/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "SBDataObject.h"

@interface FFRosterPrediction : SBDataObject

@property(nonatomic) NSString* ownerId;
@property(nonatomic) NSString* ownerName;
@property(nonatomic) NSString* state;
@property(nonatomic) NSString* contestId;
@property(nonatomic) NSString* buyIn;
@property(nonatomic) NSString* remainingSalary;
@property(nonatomic) NSString* score;
@property(nonatomic) NSString* contestRank;
@property(nonatomic) NSString* contestRankPayout;
@property(nonatomic) NSString* amountPaid;
@property(nonatomic) NSString* paidAt;
@property(nonatomic) NSString* cancelledCause;
@property(nonatomic) NSString* cancelledAt;
@property(nonatomic) NSString* positions;
@property(nonatomic) NSString* startedAt;
@property(nonatomic) NSString* marketId;
@property(nonatomic) NSString* nextGameTime;
@property(nonatomic) NSString* live;
@property(nonatomic) NSString* bonusPoints;
@property(nonatomic) NSString* perfectScore;
@property(nonatomic) NSString* removeBenched;
@property(nonatomic) NSString* viewCode;
@property(nonatomic) NSString* abridged;
@property(nonatomic) NSString* league;
@property(nonatomic) NSString* contest;
@property(nonatomic) NSString* contestType;
@property(nonatomic) NSString* players;
@property(nonatomic) NSString* market;

@end
