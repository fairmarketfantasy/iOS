//
//  FFSport.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/3/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFSport.h"

@implementation FFSport

+ (NSString*)stringFromSport:(FFMarketSport)key
{
    switch (key) {
        case FFMarketSportNBA:
            return @"NBA";
        case FFMarketSportNFL:
            return @"NFL";
        default:
            NSAssert(FALSE, @"Wrong FFMarketSport key argument!");
    }
}

@end
