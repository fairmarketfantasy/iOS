//
//  FFDate.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/9/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFDate.h"

@implementation FFDate

+ (NSDateFormatter*)dateFormatter
{
    NSDateFormatter* formatter = NSDateFormatter.new;
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ";
    formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
//    formatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    return formatter;
}

#pragma mark - SBField protocol

- (NSString*)description
{
    NSDate* date = [NSDate.alloc initWithTimeInterval:(NSTimeInterval)0.f
                                            sinceDate:self];
    return [date description];
}

+ (instancetype)fromDatabase:(NSString*)string
{
//    if ([string isEqualToString:@"2014-03-26T23:00:00.000Z"]) {
//        return nil;
//    }
    NSError* error = nil;
    NSDate* date = nil;
    NSDateFormatter* formatter = [self dateFormatter];
    [formatter getObjectValue:&date
                    forString:string
                        range:nil
                        error:&error];
    return [self.alloc initWithTimeInterval:(NSTimeInterval)0.f
                                  sinceDate:date];
}

@end
