//
//  FFIndividualPrediction.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/3/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFDataObject.h"

@class FFDate;

@interface FFIndividualPrediction : FFDataObject

@property(nonatomic) NSString* playerId;
@property(nonatomic) NSString* playerStatId;
@property(nonatomic) NSString* marketName;
@property(nonatomic) NSArray* eventPredictions;
@property(nonatomic) NSString* playerName;
@property(nonatomic) NSString* predictThat;
@property(nonatomic) NSString* award;
@property(nonatomic) NSString* state;
@property(nonatomic) NSString* tradeMessage;
@property(nonatomic) FFDate* gameTime;
@property(nonatomic) FFDate* gameDay;
@property(nonatomic) NSNumber* gameResult;
@property(nonatomic) NSNumber* shouldShowTrade;

+ (void)submitPredictionForSession:(FFSession *)session
                            params:(NSDictionary *)params
                           success:(SBSuccessBlock)success
                           failure:(SBErrorBlock)failure;

+ (void)submitPredictionForTeam:(NSString *)teamId
                         inGame:(NSString *)gameId
                        session:(SBSession*)session
                        success:(SBSuccessBlock)success
                        failure:(SBErrorBlock)failure;

+ (void)tradePredictionForSession:(FFSession *)session
                           params:(NSDictionary *)params
                          success:(SBSuccessBlock)success
                          failure:(SBErrorBlock)failure;

@end
