//
//  FFCategory.m
//  FMF Football
//
//  Created by Anton Chuev on 5/19/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFCategory.h"
#import "FFSport.h"
#import <SBData/NSDictionary+Convenience.h>

@implementation FFCategory

- (NSDictionary *)dictionary
{
    NSMutableArray *sports = [NSMutableArray arrayWithCapacity:self.sports.count];
    for (FFSport *sport in _sports) {
        [sports addObject:[sport dictionary]];
    }
    
    return @{@"note" : _note,
             @"name" : _name,
             @"sports" : sports
             };
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _note = [dict objectForKey:@"note"];
        _name = [dict objectForKey:@"name"];
        
        NSMutableArray *sports = [NSMutableArray array];
        for (NSDictionary *sportDict in [dict objectForKey:@"sports"]) {
            FFSport *sport = [[FFSport alloc] initWithDictionary:sportDict];
            [sports addObject:sport];
        }
        
        _sports = [sports copy];
    }
    
    return self;
}

@end
