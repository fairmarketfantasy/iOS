//
//  FFFantasyRosterDataSource.h
//  FMF Football
//
//  Created by Anton Chuev on 6/10/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FFRoster.h"

@class FFMarket;
@class FFMarketSet;
@class FFPlayer;

@protocol FFFantasyRosterDataSource <NSObject>

@property (nonatomic, readonly) FFRoster *currentRoster;
@property (nonatomic, readonly) NSString* rosterId;
@property (nonatomic, readonly) NSDictionary* positionsNames;
@property (nonatomic, strong) FFMarket *currentMarket;

- (NSArray *)availableMarkets;
- (NSArray *)team;
- (NSArray *)allPositions;
- (NSArray *)uniquePositions;

- (void)showIndividualPredictionsForPlayer:(FFPlayer *)player;

@end

@protocol FFFantasyRosterDelegate <NSObject>

- (void)showPosition:(NSString*)position;
- (void)removePlayer:(FFPlayer*)player completion:(void(^)(BOOL success))block;
- (void)submitRoster:(FFRosterSubmitType)rosterType completion:(void(^)(BOOL success))block;
- (void)refreshRosterWithShowingAlert:(BOOL)shouldShow completion:(void(^)(void))block;
- (void)autoFillWithCompletion:(void(^)(BOOL success))block;
- (void)toggleRemoveBenchWithCompletion:(void(^)(BOOL success))block;

@end
