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
- (NSArray *)team;
- (NSArray *)allPositions;

@end

@protocol FFYourTeamDelegate <NSObject>

- (void)showPosition:(NSString*)position;
- (void)removePlayer:(FFPlayer*)player completion:(void(^)(BOOL success))block;
- (void)submitRoster:(FFRosterSubmitType)rosterType completion:(void(^)(BOOL))block;

@end
