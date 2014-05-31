//
//  FFWCTeam.m
//  FMF Football
//
//  Created by Anton on 5/31/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFWCTeam.h"

@implementation FFWCTeam

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super initWithDictionary:dict];
    if (self) {
        _name = dict[@"name"];
        _flagURL = dict[@"logo_url"];
        _pt = [dict[@"pt"] integerValue];
        _disablePT = [dict[@"disable_pt"] boolValue];
    }
    
    return self;
}

@end
