//
//  FFWCManager.h
//  FMF Football
//
//  Created by Anton on 5/31/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FFSession;

@interface FFWCManager : NSObject

@property (nonatomic, readonly) NSMutableArray *dailyWins; //array of WCTeams*
@property (nonatomic, readonly) NSMutableArray *mvpCandidates; //array of WCPlayer*
@property (nonatomic, readonly) NSMutableArray *groupWinners; //array of WCGroup*
@property (nonatomic, readonly) NSMutableArray *cupWinners; //array of WCTeams*

+ (FFWCManager*)shared;
- (void)fetchDataForSession:(FFSession *)session dataWithCompletion:(void(^)(BOOL success))block;

@end
