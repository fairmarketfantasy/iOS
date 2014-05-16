//
//  FFRoster.m
//  FMF Football
//
//  Created by Samuel Sutch on 9/25/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import "FFRoster.h"
#import <BlocksKit.h>
#import <SBData/NSDictionary+Convenience.h>
#import "FFDate.h"
#import "FFContestType.h"
#import <objc/runtime.h>
#import <dispatch/dispatch.h>
#import "FFPlayer.h"
#import "FFContestType.h"
#import "FFMarket.h"
#import "FFSession.h"

@implementation FFRoster

@dynamic bonusPoints;
@dynamic startedAt;
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
@dynamic removeBenched;

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
    return [[super propertyToNetworkKeyMapping] dictionaryByMergingWithDictionary:
  @{
    @"bonusPoints":         @"bonus_points",
    @"startedAt":           @"started_at",
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
    @"state":               @"state",
    @"removeBenched":       @"remove_benched"
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
                ], // also for sorting
            ]];
}

+ (void)createNewRosterForMarket:(NSString*)marketId
                         session:(FFSession*)sesh
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
                              session:(FFSession*)session
                              success:(SBSuccessBlock)success
                              failure:(SBErrorBlock)failure
{
    NSDictionary* params = @{
        @"contest_type_id" : [NSNumber numberWithInteger:cTyp]
    };
    [session authorizedJSONRequestWithMethod:@"POST"
                                        path:[self bulkPath]
                                   paramters:params
                                     success:^(NSURLRequest* request, NSHTTPURLResponse* httpResponse, id JSON)
    {
        [self createWithNetworkRepresentation:JSON
                                      session:session
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
                     session:(FFSession*)session
                     success:(SBSuccessBlock)success
                     failure:(SBErrorBlock)failure
{
    [session authorizedJSONRequestWithMethod:@"POST"
                                        path:@"/contests"
                                   paramters:dict
                                     success:^(NSURLRequest* request, NSHTTPURLResponse* httpResponse, id JSON)
    {
        [self createWithNetworkRepresentation:JSON
                                      session:session
                                      success:success
                                      failure:failure];
    }
                                     failure:
    ^(NSURLRequest * request, NSHTTPURLResponse * httpResponse, NSError * error, id JSON)
    {
        failure(error);
    }];
}

+ (instancetype)fromNetworkRepresentation:(NSDictionary*)dict
                                  session:(SBSession*)session
                                     save:(BOOL)persist
{
    SBDataObject *ret = [self findWithNetworkRepresentation:dict session:session];
    if (!ret) {
        ret = [[self alloc] initWithSession:session];
    }
    [ret setValuesForKeysWithNetworkDictionary:dict];
    if (persist) {
        [[self unsafeMeta] save:ret];
    }
    return (id)ret;
}

+ (void)fetchPositionsForSession:(FFSession*)session
                         success:(SBSuccessBlock)success
                         failure:(SBErrorBlock)failure
{
    NSString* path = [[FFRoster bulkPath] stringByAppendingString:@"/new"];
    [session authorizedJSONRequestWithMethod:@"GET"
                                        path:path
                                   paramters:@{ @"sport" : [FFSport stringFromSport:session.sport] }
                                     success:^(NSURLRequest* request, NSHTTPURLResponse* httpResponse, id JSON)
     {
         if (success) {
             success([self positionsFromJSON:JSON]);
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
        self.players = [self.players arrayByAddingObject:player];
//        NSString* priceString = player.buyPrice;
//        CGFloat price = priceString ? [priceString floatValue] : 0.f;
//        self.remainingSalary = [SBFloat.alloc initWithFloat:self.remainingSalary.floatValue - price];
        if (success) {
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
//            NSString* priceString = traded.sellPrice;
//            CGFloat price = priceString ? [priceString floatValue] : 0.f;
//            self.remainingSalary = [SBFloat.alloc initWithFloat:self.remainingSalary.floatValue + price];
        }
        if (success) {
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

- (void)toggleRemoveBenchedSuccess:(SBSuccessBlock)success
                           failure:(SBErrorBlock)failure
{
    NSString* path = [[FFRoster bulkPath] stringByAppendingFormat:@"/%@/toggle_remove_bench", self.objId];
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
        NSString *message = [[httpResponse allHeaderFields] objectForKey:@"X-CLIENT-FLASH"];
        _messageAfterSubmit = (message != nil && message.length > 0) ? message : NSLocalizedString(@"Roster submitted successfully!", nil);
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
    NSDictionary* contest = keyedValues[@"contest_type"];
    if ([contest isKindOfClass:[NSDictionary class]]) {
        self.contestTypeId = contest[@"id"];
        self.contestType = [FFContestType fromNetworkRepresentation:contest
                                                            session:self.session
                                                               save:YES];
    }
    NSDictionary* market = keyedValues[@"market"];
    if ([market isKindOfClass:[NSDictionary class]]) {
        self.marketId = market[@"id"];
        self.market = [FFMarket fromNetworkRepresentation:market
                                                  session:self.session
                                                     save:NO]; // we don't need save roster's market
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

#pragma mark - private

+ (NSDictionary*)positionsFromJSON:(NSDictionary*)JSON
{
    if (![JSON isKindOfClass:[NSDictionary class]]) {
        return @{};
    }
    NSArray* positions = JSON[@"positions"];
    if (![positions isKindOfClass:[NSArray class]] || positions.count == 0) {
        return @{};
    }
    return [NSDictionary dictionaryWithObjects:[positions valueForKey:@"name"]
                                       forKeys:[positions valueForKey:@"acronym"]];
}

@end
