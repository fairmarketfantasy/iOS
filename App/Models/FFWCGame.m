//
//  FFWCGame.m
//  FMF Football
//
//  Created by Anton on 5/31/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFWCGame.h"
#import "FFWCTeam.h"
#import "FFDate.h"

@implementation FFWCGame

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [self init];
    if (self) {
        _homeTeam = [[FFWCTeam alloc] initWithDictionary:dict[@"get_home_team"]];
        _guestTeam = [[FFWCTeam alloc] initWithDictionary:dict[@"get_away_team"]];
        _date = (FFDate *)[[FFDate dateFormatter] dateFromString:dict[@"game_time"]];
        _statsId = [dict objectForKey:@"stats_id"];
    }
    return self;
}

- (NSString *)description
{
    NSMutableString *result = [NSMutableString string];
    [result appendFormat:@"\nTime: %@", _date];
    [result appendFormat:@"\nHome team: %@", [_homeTeam description]];
    [result appendFormat:@"\nGuest team: %@", [_guestTeam description]];
    return result;
}

@end
