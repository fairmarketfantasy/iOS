//
//  FFWCDataModel.m
//  FMF Football
//
//  Created by Anton on 5/31/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFWCDataModel.h"

@implementation FFWCDataModel

- (instancetype)initWithDictionary:(NSDictionary *)dict;
{
    return [super init];
}

- (NSString *)description
{
    NSMutableString *result = [NSMutableString string];
    [result appendFormat:@"\nName: %@", _name];
    [result appendFormat:@"\nFlag URL: %@", _flagURL];
    [result appendFormat:@"\nPT: %i", _pt];
    [result appendFormat:@"\nDisable PT: %@", _disablePT ? @"YES" : @"NO"];
    return result;
}

@end
