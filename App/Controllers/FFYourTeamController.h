//
//  FFYourTeamController.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/14/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFBaseViewController.h"

@protocol FFYourTeamProtocol <NSObject>

- (void)showPosition:(NSString*)position;

@end

@class FFMarket;
@class FFMarketSet;
@class Reachability;

@interface FFYourTeamController : FFBaseViewController {
    Reachability* internetReachability;
}

@property(nonatomic, weak) id<FFYourTeamProtocol> delegate;
@property(nonatomic, readonly) FFRoster* roster;
@property(nonatomic) FFMarket* selectedMarket;
@property(nonatomic) UITableView* tableView;
@property(nonatomic, readonly) BOOL noGamesAvailable;

- (NSArray*)uniquePositions;
- (void)createRoster;
- (void)refreshRosterWithShowingAlert:(BOOL)shouldShow completion:(void(^)(void))block;
- (void)updateMarkets;

@end
