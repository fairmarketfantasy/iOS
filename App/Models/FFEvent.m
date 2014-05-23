//
//  FFEvent.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/2/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFEvent.h"
#import "FFSession.h"
#import "FFSessionManager.h"
#import <SBData/NSDictionary+Convenience.h>

@implementation FFEvent

@dynamic bidMore;
@dynamic bidLess;
@dynamic value;
@dynamic name;

+ (NSString*)tableName
{
    return @"ffevent";
}

+ (void)load
{
    [self registerModel:self];
}

+ (NSString*)bulkPath
{
    return [[FFSessionManager shared].currentCategoryName isEqualToString:FANTASY_SPORTS] ? @"/events" : @"/game_predictions";
}

+ (NSDictionary*)propertyToNetworkKeyMapping
{
    return [[super propertyToNetworkKeyMapping] dictionaryByMergingWithDictionary:
            @{
              @"bidMore" : @"bid_more",
              @"bidLess" : @"bid_less",
              @"value"   : @"value",
              @"name"    : @"name"
              }];
}

#pragma mark -

+ (void)fetchEventsForMarket:(NSString*)marketId
                     player:(NSString*)statId
                      session:(SBSession*)session
                      success:(SBSuccessBlock)success
                      failure:(SBErrorBlock)failure
{
    // TODO: use FFDataObjectResultSet
    NSDictionary* params = @{
                             @"player_ids" : statId,
                             @"average" : @"true", // for this request only, API specific
                             @"market_id" : marketId,
                             };
    [session authorizedJSONRequestWithMethod:@"GET"
                                        path:[[self bulkPath] stringByAppendingString:@"/for_players"]
                                   paramters:params
                                     success:
     ^(NSURLRequest* request, NSHTTPURLResponse* httpResponse, id JSON) {
         if (![JSON isKindOfClass:[NSDictionary class]]) {
             if (failure) {
                 failure(nil);
             }
             return;
         }
         NSDictionary* eventsDictionary = (NSDictionary*)JSON;
         NSArray* events = eventsDictionary[@"events"]; // TODO: refactore this
         if (![events isKindOfClass:[NSArray class]]) {
             if (failure) {
                 failure(nil);
             }
             return;
         }
         [self makeEvents:@[]
          fromDictionaries:events
                   session:session
                   success:success
                   failure:failure];
     }
                                     failure:
     ^(NSURLRequest * request, NSHTTPURLResponse * httpResponse, NSError * error, id JSON) {
         if (failure) {
             failure(error);
         }
     }];
}

+ (void)fetchEventsForTeam:(NSString *)teamId
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
                                        path:[self bulkPath]
                                   paramters:params
                                     success:^(NSURLRequest *request, NSHTTPURLResponse *httpResponse, id JSON) {
                                         NSLog(@"JSON : %@", JSON);
                                     } failure:^(NSURLRequest *request, NSHTTPURLResponse *httpResponse, NSError *error, id JSON) {
                                         NSLog(@"Error: %@", error);
                                     }];
}

- (void)individualPredictionsForMarket:(NSString*)marketId
                                player:(NSString*)statId
                                roster:(NSString*)rosterId
                                  diff:(NSString*)diff
                               success:(SBSuccessBlock)success
                               failure:(SBErrorBlock)failure
{
    NSParameterAssert(self.session != nil);
    NSDictionary* params = @{
                             @"player_id" : statId,
                             @"market_id" : marketId,
                             @"roster_id" : rosterId,
                             @"events" : @[@{
                                               @"diff" : diff,
                                               @"name" : self.name,
                                               @"value" : self.value
                                               }]};
    AFHTTPClient* client = self.authorized ? self.session.authorizedHttpClient : self.session.anonymousHttpClient;
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:
                                         [client requestWithMethod:@"POST"
                                                              path:@"/individual_predictions/"
                                                        parameters:params]];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success([NSString stringWithUTF8String:[responseObject bytes]]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    [client enqueueHTTPRequestOperation:operation];

}

#pragma mark - private

// TODO: should be refactored in future !!!
// @see + (instancetype)fromNetworkRepresentation:(NSDictionary *)dict session:(SBSession *)session save:(BOOL)persist
+ (void)makeEvents:(NSArray*)events
   fromDictionaries:(NSArray*)dictionaries
            session:(SBSession*)session
            success:(SBSuccessBlock)success
            failure:(SBErrorBlock)failure
{
    if (dictionaries.count == 0) {
        if (success) {
            success(events);
        }
        return;
    }
    [self createWithNetworkRepresentation:dictionaries.lastObject
                                  session:session
                                  success:^(id successObj) {
                                      NSMutableArray* newDictionaries = [dictionaries mutableCopy];
                                      [newDictionaries removeLastObject];
                                      NSMutableArray* newEvents = [events mutableCopy];
                                      [newEvents addObject:successObj];
                                      [self makeEvents:[newEvents copy]
                                       fromDictionaries:[newDictionaries copy]
                                                session:session
                                                success:success
                                                failure:failure];
                                  }
                                  failure:failure];
}

@end
