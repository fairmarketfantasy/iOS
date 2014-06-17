//
//  FFIndividualPrediction.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/3/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFIndividualPrediction.h"
#import "FFDate.h"
#import "FFSessionManager.h"
#import <SBData/NSDictionary+Convenience.h>


@implementation FFIndividualPrediction

@dynamic playerId;
@dynamic playerStatId;
@dynamic marketName;
@dynamic eventPredictions;
@dynamic playerName;
@dynamic predictThat;
@dynamic award;
@dynamic state;
@dynamic gameTime;
@dynamic gameDay;
@dynamic gameResult;
@dynamic currentPT;

+ (NSString*)tableName
{
    return @"ffindividual_prediction";
}

+ (void)load
{
    [self registerModel:self];
}

+ (NSString*)bulkPath
{
    return @"/individual_predictions/mine";
}

+ (NSDictionary*)propertyToNetworkKeyMapping
{
    return [[super propertyToNetworkKeyMapping] dictionaryByMergingWithDictionary:
            @{
              @"currentPT" : @"current_pt",
              @"playerId" : @"player_id",
              @"playerStatId" : @"player_stat_id",
              @"marketName" : @"market_name",
              @"eventPredictions" : @"event_predictions",
              @"playerName" : @"player_name",
              @"predictThat" : @"pt",
              @"award" : @"award",
              @"state" : @"state",
              @"gameTime" : @"game_time",
              @"gameDay" : @"game_day",
              @"gameResult" : @"game_result"
              }];
}
// TODO: FFEventPrediction
/*
- (void)setValuesForKeysWithNetworkDictionary:(NSDictionary*)keyedValues
{
    if (![keyedValues isKindOfClass:[NSDictionary class]]) {
        return;
    }
    [super setValuesForKeysWithNetworkDictionary:keyedValues];
    NSArray* eventDictionaries = keyedValues[@"event_predictions"];
    NSMutableArray* events = [NSMutableArray arrayWithCapacity:eventDictionaries.count];
    for (NSDictionary* eventDictionary in eventDictionaries) {
        [events addObject:[FFEventPrediction fromNetworkRepresentation:eventDictionary
                                                               session:self.session
                                                                  save:YES]];
    }
    self.eventPredictions = [events copy];
}
*/

+ (void)submitPredictionForSession:(FFSession *)session
                            params:(NSDictionary *)params
                           success:(SBSuccessBlock)success
                           failure:(SBErrorBlock)failure
{
    [session authorizedJSONRequestWithMethod:@"POST"
                                        path:@"/create_prediction"
                                   paramters:params
                                     success:^(NSURLRequest *request, NSHTTPURLResponse *httpResponse, id JSON) {
                                         success(JSON);
                                     } failure:^(NSURLRequest *request, NSHTTPURLResponse *httpResponse, NSError *error, id JSON) {
                                         failure(error);
                                     }];
}

+ (void)submitPredictionForTeam:(NSString *)teamId
                         inGame:(NSString *)gameId
                        session:(SBSession*)session
                        success:(SBSuccessBlock)success
                        failure:(SBErrorBlock)failure
{
    NSDictionary *params = @{
                             @"game_stats_id" : gameId,
                             @"team_stats_id" : teamId
                             };
    
    [session authorizedJSONRequestWithMethod:@"POST"
                                        path:@"/game_predictions"
                                   paramters:params
                                     success:^(NSURLRequest *request, NSHTTPURLResponse *httpResponse, id JSON) {
                                         if(success)
                                             success(JSON);
                                     } failure:^(NSURLRequest *request, NSHTTPURLResponse *httpResponse, NSError *error, id JSON) {
                                         if (failure)
                                             failure(error);
                                     }];
}

+ (void)tradePredictionForSession:(FFSession *)session
                           params:(NSDictionary *)params
                          success:(SBSuccessBlock)success
                          failure:(SBErrorBlock)failure
{
    [session authorizedJSONRequestWithMethod:@"DELETE"
                                        path:@"/trade_prediction"
                                   paramters:params
                                     success:^(NSURLRequest *request, NSHTTPURLResponse *httpResponse, id JSON) {
                                         success(JSON);
                                     } failure:^(NSURLRequest *request, NSHTTPURLResponse *httpResponse, NSError *error, id JSON) {
                                         failure(error);
                                     }];
}

@end
