//
//  FFYourTeamDataSource.h
//  FMF Football
//
//  Created by Anton Chuev on 5/13/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FFMarket;

@protocol FFYourTeamDataSource <NSObject>

- (NSArray *)availableMarkets;
- (void)createRosterWithCompletion:(void(^)(void))block;
- (FFRoster *)currentRoster;
- (void)setupCurrentRoster:(FFRoster *)roster;
- (void)setupSelectedMarket:(FFMarket *)market;
- (FFMarket *)getSelectedMarket;

@end
