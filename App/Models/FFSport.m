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
        _commingSoon = [[dictionary objectForKey:@"coming_soon"] boolValue];
        _isActive = [[dictionary objectForKey:@"is_active"] boolValue];
        _isPlayoffsOn = [[dictionary objectForKey:@"playoffs_on"] boolValue];
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

- (NSString*)descriptionWithLocale:(NSDictionary*)locale indent:(NSUInteger)indent
{
	NSMutableString* result = [NSMutableString stringWithFormat:@"Sport: %@\n", _name];
	[result appendFormat:@"commingSoon: %d\n", _commingSoon];
	[result appendFormat:@"isActive: %d\n", _isActive];
    [result appendFormat:@"isPlayoffsOn: %d\n", _isPlayoffsOn];
    
	return result;
}

- (NSString *)description
{
    return [self descriptionWithLocale:nil indent:0];
}

@end
