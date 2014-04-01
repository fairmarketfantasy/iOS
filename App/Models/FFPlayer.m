//
//  FFPlayer.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/1/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFPlayer.h"
#import <SBData/NSDictionary+Convenience.h>
#import "FFDataObjectResultSet.h"

@implementation FFPlayer

@dynamic swappedPlayerName;
@dynamic benched;
@dynamic nextGameAt;
@dynamic benchedGames;
@dynamic isEliminated;
@dynamic headshotURL;
@dynamic locked;
@dynamic score;
@dynamic sellPrice;
@dynamic buyPrice;
@dynamic purchasePrice;
@dynamic ppg;
@dynamic status ;
@dynamic jerseyNumber;
@dynamic position;
@dynamic college;
@dynamic weight ;
@dynamic height;
@dynamic birthdate;
@dynamic nameAbbr;
@dynamic name;
@dynamic sportId;
@dynamic team;
@dynamic statsId;

+ (NSString*)tableName
{
    return @"ffplayer";
}

+ (void)load
{
    [self registerModel:self];
}

+ (NSString*)bulkPath
{
    return @"/players";
}

+ (NSDictionary*)propertyToNetworkKeyMapping
{
    return [[super propertyToNetworkKeyMapping] dictionaryByMergingWithDictionary:
            @{
              @"swappedPlayerName" : @"swapped_player_name",
              @"benched" : @"benched",
              @"nextGameAt" : @"next_game_at",
              @"benchedGames" : @"benched_games",
              @"isEliminated" : @"is_eliminated",
              @"headshotURL" : @"headshot_url",
              @"locked" : @"locked",
              @"score" : @"score",
              @"sellPrice" : @"sell_price",
              @"buyPrice" : @"buy_price",
              @"purchasePrice" : @"purchase_price",
              @"ppg" : @"ppg",
              @"status" : @"status" ,
              @"jerseyNumber" : @"jersey_number",
              @"position" : @"position",
              @"college" : @"college",
              @"weight" : @"weight" ,
              @"height" : @"height",
              @"birthdate" : @"birthdate",
              @"nameAbbr" : @"name_abbr",
              @"name" : @"name",
              @"sportId" : @"sport_id",
              @"team" : @"team",
              @"statsId" : @"stats_id"
              }];
}

#pragma mark -

+ (void)fetchPlayersForRoster:(NSString*)rosterId
                     position:(NSString*)position
               removedBenched:(BOOL)removedBenched
                      session:(SBSession*)session
                      success:(SBSuccessBlock)success
                      failure:(SBErrorBlock)failure
{
    // TODO: use FFDataObjectResultSet
    NSDictionary* params = @{
                             @"position" : position,
                             @"dir" : @"desc", // sorting direction
                             @"sort" : @"buy_price", // sorting by
                             @"roster_id" : rosterId,
                             @"removeLow" : removedBenched ? @"true" : @"false" // TODO: convert via JSON lib
                             };
    [session authorizedJSONRequestWithMethod:@"GET"
                                        path:[self bulkPath]
                                   paramters:params
                                     success:
     ^(NSURLRequest* request, NSHTTPURLResponse* httpResponse, id JSON) {
         if (![JSON isKindOfClass:[NSArray class]]) {
             if (failure) {
                 failure(nil);
             }
             return;
         }
         NSArray* dictionaries = (NSArray*)JSON;
         [self makePlayers:@[]
          fromDictionaries:dictionaries
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
+ (void)makePlayers:(NSArray*)players
   fromDictionaries:(NSArray*)dictionaries
            session:(SBSession*)session
            success:(SBSuccessBlock)success
            failure:(SBErrorBlock)failure
{
    if (dictionaries.count == 0) {
        if (success) {
            success(players);
        }
        return;
    }
    [self createWithNetworkRepresentation:dictionaries.lastObject
                                  session:session
                                  success:^(id successObj) {
                                      NSMutableArray* newDictionaries = [dictionaries mutableCopy];
                                      [newDictionaries removeLastObject];
                                      NSMutableArray* newPlayers = [players mutableCopy];
                                      [newPlayers addObject:successObj];
                                      [self makePlayers:[newPlayers copy]
                                       fromDictionaries:[newDictionaries copy]
                                                session:session
                                                success:success
                                                failure:failure];
                                  }
                                  failure:failure];
}

@end
