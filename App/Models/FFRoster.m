//
//  FFRoster.m
//  FMF Football
//
//  Created by Samuel Sutch on 9/25/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import "FFRoster.h"
#import <SBData/NSDictionary+Convenience.h>
#import "FFContestType.h"
#import <objc/runtime.h>
#import <dispatch/dispatch.h>
#import "FFPlayer.h"

@implementation FFRoster

@dynamic amountPaid;
@dynamic buyIn;
@dynamic canceledAt;
@dynamic canceledCause;
@dynamic contest;
@dynamic contestId;
@dynamic contestRank;
@dynamic contestRankPayout;
@dynamic live;
@dynamic nextGameTime;
@dynamic ownerId;
@dynamic ownerName;
@dynamic paidAt;
@dynamic positions;
@dynamic remainingSalary;
@dynamic score;
@dynamic state;
@dynamic contestTypeId;
@dynamic marketId;

+ (NSString*)tableName
{
    return @"ffroster";
}

+ (void)load
{
    [self registerModel:self];
}

+ (NSString*)bulkPath
{
    return @"/rosters";
}

+ (NSDictionary*)propertyToNetworkKeyMapping
{
    return [[super propertyToNetworkKeyMapping] dictionaryByMergingWithDictionary:@{
            @"amountPaid":          @"amount_paid",
            @"buyIn":               @"buy_in",
            @"canceledAt":          @"canceled_at",
            @"canceledCause":       @"canceled_cause",
            @"contest":             @"contest",
            @"contestId":           @"contest_id",
            @"contestRank":         @"contest_rank",
            @"contestRankPayout":   @"contest_rank_payout",
            @"live":                @"live",
            @"nextGameTime":        @"next_game_time",
            @"ownerId":             @"owner_id",
            @"ownerName":           @"owner_name",
            @"paidAt":              @"paid_at",
            @"positions":           @"positions",
            @"remainingSalary":     @"remaining_salary",
            @"score":               @"score",
            @"state":               @"state"
            }];
}

+ (NSArray*)indexes
{
    return [[super indexes]
        arrayByAddingObjectsFromArray:
            @[
                @[
                    @"userKey",
                    @"contestTypeId"
                ],
                @[
                    @"userKey",
                    @"contestId"
                ],
                @[
                    @"userKey",
                    @"ownerId",
                    @"state",
                    @"objId"
                ],
                @[
                    @"contestRank"
                ], // for sorting
                @[
                    @"objId"
                ] // also for sorting
            ]];
}

+ (void)createNewRosterForMarket:(NSString*)marketId
                         session:(SBSession*)sesh
                         success:(SBSuccessBlock)success
                         failure:(SBErrorBlock)failure
{
    NSDictionary* params = @{
                             @"market_id" : marketId
                             };
    [sesh authorizedJSONRequestWithMethod:@"POST"
                                     path:[self bulkPath]
                                paramters:params
                                  success:^(NSURLRequest* request, NSHTTPURLResponse* httpResponse, id JSON)
     {
         [self createWithNetworkRepresentation:JSON
                                       session:sesh
                                       success:success
                                       failure:failure];
     }
                                  failure:
     ^(NSURLRequest * request, NSHTTPURLResponse * httpResponse, NSError * error, id JSON)
     {
         failure(error);
     }];
}

+ (void)createRosterWithContestTypeId:(NSInteger)cTyp
                              session:(SBSession*)sesh
                              success:(SBSuccessBlock)success
                              failure:(SBErrorBlock)failure
{
    NSDictionary* params = @{
        @"contest_type_id" : [NSNumber numberWithInteger:cTyp]
    };
    [sesh authorizedJSONRequestWithMethod:@"POST"
                                     path:[self bulkPath]
                                paramters:params
                                  success:^(NSURLRequest* request, NSHTTPURLResponse* httpResponse, id JSON)
    {
        [self createWithNetworkRepresentation:JSON
                                      session:sesh
                                      success:success
                                      failure:failure];
    }
failure:
    ^(NSURLRequest * request, NSHTTPURLResponse * httpResponse, NSError * error, id JSON)
    {
        failure(error);
    }];
}

+ (void)createWithContestDef:(NSDictionary*)dict
                     session:(SBSession*)sesh
                     success:(SBSuccessBlock)success
                     failure:(SBErrorBlock)failure
{
    [sesh authorizedJSONRequestWithMethod:@"POST"
                                     path:@"/contests"
                                paramters:dict
                                  success:^(NSURLRequest* request, NSHTTPURLResponse* httpResponse, id JSON)
    {
        [self createWithNetworkRepresentation:JSON
                                      session:sesh
                                      success:success
                                      failure:failure];
    }
failure:
    ^(NSURLRequest * request, NSHTTPURLResponse * httpResponse, NSError * error, id JSON)
    {
        failure(error);
    }];
}

#pragma mark -

- (void)addPlayer:(FFPlayer*)player
          success:(SBSuccessBlock)success
          failure:(SBErrorBlock)failure
{
    NSString* path = [[self path] stringByAppendingFormat:@"/add_player/%@/%@", player.objId, player.position];
    [self.session authorizedJSONRequestWithMethod:@"POST"
                                             path:path
                                        paramters:@{}
                                          success:^(NSURLRequest* request, NSHTTPURLResponse* httpResponse, id JSON)
    {
        if (success) {
            self.players = [self.players arrayByAddingObject:player];
            success(JSON);
        }
    }
failure:
    ^(NSURLRequest * request, NSHTTPURLResponse * httpResponse, NSError * error, id JSON)
    {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)removePlayer:(FFPlayer*)player
             success:(SBSuccessBlock)success
             failure:(SBErrorBlock)failure
{
    NSString* path = [[self path] stringByAppendingFormat:@"/remove_player/%@", player.objId];
    [self.session authorizedJSONRequestWithMethod:@"POST"
                                             path:path
                                        paramters:@{}
                                          success:^(NSURLRequest* request, NSHTTPURLResponse* httpResponse, id JSON)
    {
        if (success) {
            FFPlayer* traded = nil;
            for (FFPlayer* ownPlayer in self.players) {
                if ([(NSNumber*)ownPlayer.objId isEqualToNumber:(NSNumber*)player.objId]) { // ???: why not NSString?
                    traded = ownPlayer;
                }
            }
            if (traded) {
                NSMutableArray* newPlayers = [NSMutableArray arrayWithArray:self.players];
                [newPlayers removeObject:traded];
                self.players = [newPlayers copy];
            }
            success(JSON);
        }
    }
failure:
    ^(NSURLRequest * request, NSHTTPURLResponse * httpResponse, NSError * error, id JSON)
    {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)autofillSuccess:(SBSuccessBlock)success
                failure:(SBErrorBlock)failure
{
    NSString* path = [[FFRoster bulkPath] stringByAppendingFormat:@"/%@/autofill", self.objId];
    [self.session authorizedJSONRequestWithMethod:@"POST"
                                             path:path
                                        paramters:[self toNetworkRepresentation]
                                          success:^(NSURLRequest* request, NSHTTPURLResponse* httpResponse, id JSON)
     {
         [FFRoster createWithNetworkRepresentation:JSON
                                           session:self.session
                                           success:^(id successObj) {
                                               success(successObj);
                                           }
                                           failure:^(NSError *error) {
                                               failure(error);
                                           }];
     }
                                          failure:
     ^(NSURLRequest * request, NSHTTPURLResponse * httpResponse, NSError * error, id JSON)
     {
         failure(error);
     }];
}

#pragma mark -

- (void)submitContent:(FFRosterSubmitType)type
              success:(SBSuccessBlock)success
              failure:(SBErrorBlock)failure
{
    NSString* path = [[self path] stringByAppendingString:@"/submit"];
    NSString* contestType = @"";
    switch (type) {
        case FFRosterSubmitType100FB:
            contestType = @"100/30/30";
            break;
        case FFRosterSubmitTypeHTH27FB:
            contestType = @"27 H2H";
            break;
        default:
            break;
    }
    [self.session authorizedJSONRequestWithMethod:@"POST"
                                             path:path
                                        paramters:@{ @"contest_type" : contestType }
                                          success:^(NSURLRequest* request, NSHTTPURLResponse* httpResponse, id JSON)
    {
        [self updateWithNetworkRepresentation:JSON
                                      success:success
                                      failure:failure];
    }
failure:
    ^(NSURLRequest * request, NSHTTPURLResponse * httpResponse, NSError * error, id JSON)
    {
        failure(error);
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

- (FFContestType*)contestType
{
    if (!_contestType) {
        _contestType = [[[[[self.session queryBuilderForClass:[FFContestType class]]
                               property:@"objId"
                              isEqualTo:self.contestTypeId] query] results] first];
    }
    return _contestType;
}

- (FFMarket*)market
{
    if (!_market) {
        _market = [[[[[self.session queryBuilderForClass:[FFMarket class]]
                          property:@"objId"
                         isEqualTo:self.contestTypeId] query] results] first];
    }
    return _market;
}

@end
