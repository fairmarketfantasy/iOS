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

@property (nonatomic, readonly) NSMutableArray *dailyWins;
@property (nonatomic, readonly) NSMutableArray *mvpCandidates;
@property (nonatomic, readonly) NSMutableArray *groupWinners;
@property (nonatomic, readonly) NSMutableArray *cupWinners;
@property (nonatomic, readonly) NSArray *groupsTitles;

+ (FFWCManager*)shared;
- (void)fetchDataForSession:(FFSession *)session dataWithCompletion:(void(^)(BOOL success))block;

@end
