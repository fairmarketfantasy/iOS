//
//  FFNonFantasyRosterDataSource.h
//  FMF Football
//
//  Created by Anton Chuev on 6/10/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FFTeam;

@protocol FFNonFantasyRosterDataSource <NSObject>

- (NSArray *)availableGames;
- (NSArray *)teams;

@end


@protocol FFNonFantasyRosterDelegate <NSObject>

- (void)submitRosterCompletion:(void (^)(BOOL))block;
- (void)autoFillWithCompletion:(void(^)(BOOL success))block;
- (void)showAvailableGames;
- (void)removeTeam:(FFTeam *)removedTeam;

@end