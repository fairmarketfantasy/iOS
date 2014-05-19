//
//  FFSport.m
//  FMF Football
//
//  Created by Anton Chuev on 5/19/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFSport.h"
#import <SBData/NSDictionary+Convenience.h>

@implementation FFSport

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _commingSoon = [[dictionary objectForKey:@"commingSoon"] boolValue];
        _isActive = [[dictionary objectForKey:@"isActive"] boolValue];
        _isPlayoffsOn = [[dictionary objectForKey:@"isPlayoffsOn"] boolValue];
        _name = [dictionary objectForKey:@"name"];
    }
    
    return self;
}

- (NSDictionary *)dictionary
{
    return @{
             @"commingSoon" : [NSNumber numberWithBool:_commingSoon],
             @"isActive" : [NSNumber numberWithBool:_isActive],
             @"isPlayoffsOn" : [NSNumber numberWithBool:_isPlayoffsOn],
             @"name" : _name
             };
}

@end
