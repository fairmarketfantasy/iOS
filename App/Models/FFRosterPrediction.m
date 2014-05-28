//
//  FFRosterPrediction.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/3/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFRosterPrediction.h"
#import "FFSessionManager.h"
#import <SBData/NSDictionary+Convenience.h>
// model
#import "FFPlayer.h"
#import "FFContestType.h"
#import "FFMarket.h"
#import "FFSession.h"

@implementation FFRosterPrediction

+ (NSString*)tableName
{
    return @"ffroster_prediction";
}

+ (NSString*)bulkPath
{
    return [[super bulkPath] stringByAppendingPathComponent:@"mine"];
}

#pragma mark - public

- (void)loadRosterSuccess:(SBSuccessBlock)success
                  failure:(SBErrorBlock)failure
{
    NSString *path = [[FFSessionManager shared].currentCategoryName isEqualToString:FANTASY_SPORTS] ?
    [[[self superclass] bulkPath] stringByAppendingFormat:@"/%i", self.objId.integerValue] :
    @"/game_predictions/day_games";
    NSDictionary *params = [[FFSessionManager shared].currentCategoryName isEqualToString:FANTASY_SPORTS] ?
    @{} :
    @{@"sport" : [FFSessionManager shared].currentSportName,
      @"roster_id" : [NSNumber numberWithInteger:self.objId.integerValue]
      };

    [self.session authorizedJSONRequestWithMethod:@"GET"
                                             path:path
                                        paramters:params
                                          success:^(NSURLRequest* request, NSHTTPURLResponse* httpResponse, id JSON)
     {
         if ([[FFSessionManager shared].currentCategoryName isEqualToString:FANTASY_SPORTS]) {
             [[self superclass] createWithNetworkRepresentation:JSON
                                                        session:self.session
                                                        success:success
                                                        failure:failure];
         } else {
             [[self superclass] createWithNetworkRepresentation:[JSON objectForKey:@"game_roster"]
                                                        session:self.session
                                                        success:success
                                                        failure:failure];
         }
     }
                                          failure:
     ^(NSURLRequest * request, NSHTTPURLResponse * httpResponse, NSError * error, id JSON)
     {
         failure(error);
     }];
}

#pragma mark - private

- (void)setValuesForKeysWithNetworkDictionary:(NSDictionary*)keyedValues
{
    [super setValuesForKeysWithNetworkDictionary:keyedValues];
}

@end
