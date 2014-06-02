//
//  FFTeam.m
//  FMF Football
//
//  Created by Anton Chuev on 5/21/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFTeam.h"
#import "FFDate.h"
#import "Collection+UnNullable.h"

@implementation FFTeam

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        dict = [dict removeNulls];
        
        _name = [dict objectForKey:@"team_name"];
        _opponentName = [dict objectForKey:@"opposite_team"];
        _isHomeTeam = [[dict objectForKey:@"home_team"] boolValue];
        _logoURL = [dict objectForKey:@"team_logo"];
        _gameName = [dict objectForKey:@"market_name"];
        
        if ([[dict objectForKey:@"game_time"] isKindOfClass:[NSString class]]) {
            FFDate *date = (FFDate *)[[FFDate dateFormatter] dateFromString:[dict objectForKey:@"game_time"]];
            _gameDate = date;
        } else {
            _gameDate = [dict objectForKey:@"game_time"];
        }
        
//        NSNumberFormatter *formatter = [NSNumberFormatter new];
//        formatter.numberStyle = NSNumberFormatterDecimalStyle;
//        _pt = [formatter numberFromString:[dict objectForKey:@"pt"]];
        
        _pt = [[dict objectForKey:@"pt"] integerValue];
        
        _statsId = [dict objectForKey:@"team_stats_id"];
        _gameStatsId = [dict objectForKey:@"game_stats_id"];
    }
    return self;
}

@end
