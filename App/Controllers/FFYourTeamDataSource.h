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

@property (nonatomic, strong) FFRoster *currentRoster;
@property (nonatomic, strong) FFMarket *currentMarket;

- (NSArray *)availableMarkets;
- (void)createRosterWithCompletion:(void(^)(void))block;

- (void)submitRoster:(FFRosterSubmitType)rosterType completion:(void(^)(BOOL))block;
- (NSArray *)allPositions;
- (NSArray *)getMyTeam;

@end
