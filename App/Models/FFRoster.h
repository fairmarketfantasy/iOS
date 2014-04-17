//
//  FFRoster.h
//  FMF Football
//
//  Created by Samuel Sutch on 9/25/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import "FFDataObject.h"
#import <SBData/SBTypes.h>

@class FFPlayer;
@class FFMarket;
@class FFContestType;
@class FFDate;

typedef NS_ENUM(NSUInteger, FFRosterSubmitType) {
    FFRosterSubmitType100FB,
    FFRosterSubmitTypeHTH27FB
};

@interface FFRoster : FFDataObject

@property(nonatomic) SBInteger* bonusPoints;
@property(nonatomic) FFDate* startedAt;
@property(nonatomic) SBInteger* amountPaid;
@property(nonatomic) SBInteger* buyIn;
@property(nonatomic) FFDate* canceledAt;
@property(nonatomic) NSString* canceledCause;
@property(nonatomic) NSDictionary* contest;
@property(nonatomic) SBInteger* contestId;
@property(nonatomic) SBInteger* contestRank;
@property(nonatomic) SBInteger* contestRankPayout;
@property(nonatomic) SBInteger* live;
@property(nonatomic) FFDate* nextGameTime;
@property(nonatomic) NSString* ownerId;
@property(nonatomic) NSString* ownerName;
@property(nonatomic) FFDate* paidAt;
@property(nonatomic) NSArray* players; // FFPlayer*
@property(nonatomic) NSString* positions;
@property(nonatomic) SBFloat* remainingSalary;
@property(nonatomic) SBInteger* score;
@property(nonatomic) NSString* state; // submitted | finished
@property(nonatomic) SBInteger* removeBenched;
#pragma mark - Contest
@property(nonatomic) FFContestType* contestType;
@property(nonatomic) NSString* contestTypeId;
#pragma mark - Market
@property(nonatomic) FFMarket* market;
@property(nonatomic) NSString* marketId;
#pragma mark -
+ (void)createNewRosterForMarket:(NSString*)marketId
                         session:(FFSession*)sesh
                         success:(SBSuccessBlock)success
                         failure:(SBErrorBlock)failure;
/**
 *  Rosters don't have a contest_type_id,
 *  so we have to post that separately
 *  to /rosters which then returns a roster
 */
+ (void)createRosterWithContestTypeId:(NSInteger)cTyp
                              session:(FFSession*)session
                              success:(SBSuccessBlock)success
                              failure:(SBErrorBlock)failure;
+ (void)createWithContestDef:(NSDictionary*)dict
                     session:(FFSession*)session
                     success:(SBSuccessBlock)success
                     failure:(SBErrorBlock)failure;
/**
 * fetch full names for player's positions
 *
 * @param success retrieve dictionary with acronyms as keys.
 */
+ (void)fetchPositionsForSession:(FFSession*)session
                         success:(SBSuccessBlock)success
                         failure:(SBErrorBlock)failure;
- (void)addPlayer:(FFPlayer*)player
          success:(SBSuccessBlock)success
          failure:(SBErrorBlock)failure;
- (void)removePlayer:(FFPlayer*)player
             success:(SBSuccessBlock)success
             failure:(SBErrorBlock)failure;
- (void)submitContent:(FFRosterSubmitType)type
              success:(SBSuccessBlock)success
              failure:(SBErrorBlock)failure;
- (void)toggleRemoveBenchedSuccess:(SBSuccessBlock)success
                           failure:(SBErrorBlock)failure;
- (void)autofillSuccess:(SBSuccessBlock)success
                failure:(SBErrorBlock)failure;

@end
