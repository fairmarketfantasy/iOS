//
//  FFNonFantasyRosterController.h
//  FMF Football
//
//  Created by Anton Chuev on 6/5/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFYourTeamDataSource.h"

@class FFRoster;

@class FFMarket;
@class FFMarketSet;
@class Reachability;
@class FFPlayer;

@interface FFNonFantasyRosterController : UIViewController {
    Reachability* internetReachability;
}

@property(nonatomic, weak) id<FFYourTeamDelegate> delegate;
@property(nonatomic, weak) id<FFYourTeamDataSource> dataSource;
@property(nonatomic, assign) BOOL removeBenched;
@property(nonatomic) UITableView* tableView;

- (void)refreshRosterWithShowingAlert:(BOOL)shouldShow completion:(void(^)(void))block;
- (void)reloadWithServerError:(BOOL)isError;
- (void)showOrHideSubmitIfNeeded;
- (void)updateSubmitViewType;

@end

