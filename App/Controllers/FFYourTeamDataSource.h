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
@property (nonatomic, strong) FFMarket *currentMarket;

- (NSArray *)availableMarkets;
- (NSArray *)team;
- (NSArray *)allPositions;

@end

@protocol FFYourTeamDelegate <NSObject>

- (void)showPosition:(NSString*)position;
- (void)removePlayer:(FFPlayer*)player completion:(void(^)(BOOL success))block;
- (void)submitRoster:(FFRosterSubmitType)rosterType completion:(void(^)(BOOL))block;
- (void)refreshRosterWithCompletion:(void(^)(void))block;
- (void)autoFillWithCompletion:(void(^)(void))block;
- (void)toggleRemoveBenchWithCompletion:(void(^)(void))block;

@end
