//
//  FFContest.m
//  FMF Football
//
//  Created by Samuel Sutch on 9/24/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import "FFGame.h"
#import <SBData/NSDictionary+Convenience.h>
#import "FFDate.h"

@implementation FFGame

@dynamic gameTime;

+ (NSString *)tableName { return @"ffgame"; }

+ (void)load { [self registerModel:self]; }

//+ (NSString *)bulkPath { return @"/games"; }

+ (NSDictionary *)propertyToNetworkKeyMapping
{
    return [[super propertyToNetworkKeyMapping] dictionaryByMergingWithDictionary:@{
                @"gameTime":    @"game_time",
            }];
}

@end
