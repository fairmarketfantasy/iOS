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
             @"title" : _title,
             @"sports" : sports
             };
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _note = [dict objectForKey:@"note"];
        _title = [dict objectForKey:@"title"];
        _name = [self stringWithoutUnderscore:[dict objectForKey:@"name"]];
        
        NSMutableArray *sports = [NSMutableArray array];
        for (NSDictionary *sportDict in [dict objectForKey:@"sports"]) {
            FFSport *sport = [[FFSport alloc] initWithDictionary:sportDict];
            [sports addObject:sport];
        }
        
        _sports = [sports copy];
    }
    
    return self;
}

+ (NSArray *)categoriesFromDictionaries:(NSArray *)categoriesDicts
{
    NSMutableArray *categories = [NSMutableArray arrayWithCapacity:categoriesDicts.count];
    for (NSDictionary *categoryDict in categoriesDicts) {
        [categories addObject:[[FFCategory alloc] initWithDictionary:categoryDict]];
    }

    return [categories copy];
}

- (NSString *)stringWithoutUnderscore:(NSString *)string
{
    return [string stringByReplacingOccurrencesOfString:@"_" withString:@" "];
}

- (NSString*)descriptionWithLocale:(NSDictionary*)locale indent:(NSUInteger)indent
{
	NSMutableString* result = [NSMutableString stringWithFormat:@"Category: %@\n", _name];
    [result appendFormat:@"title in menu: %@\n", _title];
	[result appendFormat:@"note: %@\n\n", _note];
    for (FFSport *sport in _sports) {
        [result appendFormat:@"%@\n", sport.description];
    }

    [result appendString:@"*********\n"];
	return result;
}

- (NSString *)description
{
    return [self descriptionWithLocale:nil indent:0];
}

@end
