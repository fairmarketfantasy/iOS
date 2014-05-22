//
//  FFTeam.m
//  FMF Football
//
//  Created by Anton Chuev on 5/21/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFTeam.h"

@implementation FFTeam

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _name = [dict objectForKey:@"name"];
        _logoURL = [dict objectForKey:@"logoURL"];
        _gameName = [dict objectForKey:@"gameName"];
        _gameDate = [dict objectForKey:@"gameDate"];
        _pt = [dict objectForKey:@"pt"];
        _statsId = [dict objectForKey:@"teamStatsId"];
        _gameStatsId = [dict objectForKey:@"gameStatsId"];
    }
    return self;
}

@end
