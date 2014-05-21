//
//  FFYourTeamDataSource.h
//  FMF Football
//
//  Created by Anton Chuev on 5/13/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFRoster.h"
#import <Foundation/Foundation.h>

@class FFMarket;

@protocol FFYourTeamDataSource <NSObject>

@property (nonatomic, readonly) FFRoster *currentRoster;
@property (nonatomic, readonly) NSString* rosterId;
@property (nonatomic, readonly) NSDictionary* positionsNames;

@property (nonatomic, strong) FFMarket *currentMarket;

- (NSArray *)availableMarkets;
- (NSArray *)team;
- (NSArray *)allPositions;
- (NSArray *)uniquePositions;
- (NSArray *)availableGames;

@end

@protocol FFYourTeamDelegate <NSObject>

- (void)showPosition:(NSString*)position;
- (void)removePlayer:(FFPlayer*)player completion:(void(^)(BOOL success))block;
- (void)submitRoster:(FFRosterSubmitType)rosterType completion:(void(^)(BOOL success))block;
- (void)refreshRosterWithCompletion:(void(^)(BOOL success))block;
- (void)autoFillWithCompletion:(void(^)(BOOL success))block;
- (void)toggleRemoveBenchWithCompletion:(void(^)(BOOL success))block;

@end
