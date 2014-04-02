//
//  FFEvent.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/2/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFEvent.h"
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
    return @"/events";
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

#pragma mark - private

// TODO: should be refactored in future !!!
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
