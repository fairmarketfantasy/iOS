//
//  FFSportHelper.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/3/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFSportHelper.h"

@implementation FFSportHelper

+ (NSString*)stringFromSport:(FFMarketSport)key
{
    switch (key) {
        case FFMarketSportNBA:
            return @"NBA";
        case FFMarketSportNFL:
            return @"NFL";
        case FFMarketSportMLB:
            return @"MLB";
        default:
            NSAssert(FALSE, @"Wrong FFMarketSport key argument!");
    }
}

@end
