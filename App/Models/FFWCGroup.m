//
//  FFWCGroup.m
//  FMF Football
//
//  Created by Anton on 5/31/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFWCGroup.h"
#import "FFWCTeam.h"

@implementation FFWCGroup

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _title = dict[@"name"];

        NSArray *teamsDicts = dict[@"teams"];
        _teams = [NSMutableArray arrayWithCapacity:teamsDicts.count];
        for (NSDictionary *teamDict in teamsDicts) {
            FFWCTeam *team = [[FFWCTeam alloc] initWithDictionary:teamDict];
            [_teams addObject:team];
        }
    }
    return self;
}

- (NSString *)description
{
    NSMutableString *result = [NSMutableString string];
    [result appendFormat:@"\nTitle: %@", _title];
    [result appendString:@"\nTeams:"];
    for (FFWCTeam *team in _teams) {
        [result appendString:team.description];
    }
    return result;
}


@end
