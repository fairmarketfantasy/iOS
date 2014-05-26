//
//  FFTeam.m
//  FMF Football
//
//  Created by Anton Chuev on 5/21/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFTeam.h"
#import "FFDate.h"

@implementation FFTeam

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _name = [dict objectForKey:@"team_name"];
        _logoURL = [dict objectForKey:@"team_logo"];
        _gameName = [dict objectForKey:@"market_name"];
        
        FFDate *date = (FFDate *)[[FFDate dateFormatter] dateFromString:[dict objectForKey:@"game_time"]];
        _gameDate = date;
        
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        _pt = [formatter numberFromString:[dict objectForKey:@"pt"]];
        
        _statsId = [dict objectForKey:@"team_stats_id"];
        _gameStatsId = [dict objectForKey:@"game_stats_id"];
        _disablePt = [[dict objectForKey:@"disable_pt"] boolValue];
    }
    return self;
}

@end
