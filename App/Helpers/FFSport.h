//
//  FFSport.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/3/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

typedef NS_ENUM(NSInteger, FFMarketSport) {
    FFMarketSportNBA,
    FFMarketSportNFL,
    FFMarketSportMLB
};

@interface FFSport : NSObject

+ (NSString*)stringFromSport:(FFMarketSport)sport;

@end