//
//  FFWCManager.h
//  FMF Football
//
//  Created by Anton on 5/31/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FFManager.h"

typedef NS_ENUM(NSUInteger, FFWCPredictionCategory)
{
    FFWCDailyWins = 0,
    FFWCGroupWinners,
    FFWCMvp,
    FFWCCupWinner
};

@interface FFWCManager : FFManager

@end
