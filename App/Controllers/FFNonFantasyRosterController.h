//
//  FFNonFantasyRosterController.h
//  FMF Football
//
//  Created by Anton Chuev on 6/5/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFNonFantasyRosterDataSource.h"
#import "FFBaseViewController.h"
#import "FFManager.h"

@class FFRoster;

@class FFMarket;
@class FFMarketSet;
@class Reachability;
@class FFPlayer;

@interface FFNonFantasyRosterController : FFBaseViewController {
    Reachability* internetReachability;
}

@property (nonatomic, weak) id<FFNonFantasyRosterDelegate> delegate;
@property (nonatomic, weak) id<FFNonFantasyRosterDataSource> dataSource;
@property (nonatomic, weak) id<FFErrorHandlingDelegate> errorDelegate;
@property (nonatomic, assign) BOOL removeBenched;
@property (nonatomic, strong) UITableView* tableView;

- (void)showOrHideSubmitIfNeeded;

@end

