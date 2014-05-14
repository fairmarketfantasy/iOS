//
//  FFYourTeamController.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/14/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFBaseViewController.h"
#import "FFYourTeamDataSource.h"

@class FFRoster;

@class FFMarket;
@class FFMarketSet;
@class Reachability;
@class FFPlayer;

@interface FFYourTeamController : FFBaseViewController {
    Reachability* internetReachability;
}

@property(nonatomic, weak) id<FFYourTeamDelegate> delegate;
@property(nonatomic, weak) id<FFYourTeamDataSource> dataSource;
@property(nonatomic) UITableView* tableView;
@property(nonatomic, readonly) BOOL noGamesAvailable;

- (void)refreshRosterWithShowingAlert:(BOOL)shouldShow completion:(void(^)(void))block;
- (void)showOrHideSubmitIfNeeded;

@end
