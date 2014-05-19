//
//  FFRosterPrediction.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/3/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFRosterPrediction.h"
#import <SBData/NSDictionary+Convenience.h>
// model
#import "FFSportHelper.h"
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
    [self.session authorizedJSONRequestWithMethod:@"GET"
                                             path:[[[self superclass] bulkPath] stringByAppendingFormat:@"/%i",
                                                   self.objId.integerValue]
                                        paramters:@{}
                                          success:^(NSURLRequest* request, NSHTTPURLResponse* httpResponse, id JSON)
     {
         [[self superclass] createWithNetworkRepresentation:JSON
                                                    session:self.session
                                                    success:success
                                                    failure:failure];
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
