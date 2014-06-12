//
//  FFWCManager.h
//  FMF Football
//
//  Created by Anton on 5/31/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FFManager.h"
#import "FFPagerController.h"

@class FFSession;
@class FFWCPlayer;
@class FFWCTeam;
@class FFWCGame;

typedef NS_ENUM(NSUInteger, FFWCPredictionCategory)
{
    FFWCDailyWins = 0,
    FFWCGroupWinners,
    FFWCMvp,
    FFWCCupWinner
};

@interface FFWCManager : FFManager <FFPagerDelegate>

@property (nonatomic, readonly) NSMutableArray *dailyWins; //array of WCTeams*
@property (nonatomic, readonly) NSMutableArray *mvpCandidates; //array of WCPlayer*
@property (nonatomic, readonly) NSMutableArray *groupWinners; //array of WCGroup*
@property (nonatomic, readonly) NSMutableArray *cupWinners; //array of WCTeams*

- (void)fetchDataForSession:(FFSession *)session dataWithCompletion:(void(^)(BOOL success))block;
- (NSString *)stringForWCCategory:(FFWCPredictionCategory)category;
- (void)disablePTForPlayer:(FFWCPlayer *)player;
- (void)disablePTForTeam:(FFWCTeam *)team inGame:(FFWCGame *)game inCategory:(FFWCPredictionCategory)category;

@end
