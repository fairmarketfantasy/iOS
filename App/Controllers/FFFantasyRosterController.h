//
//  FFFantasyRosterController.h
//  FMF Football
//
//  Created by Anton Chuev on 6/5/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFBaseViewController.h"
#import "FFFantasyRosterDataSource.h"
#import "FFManager.h"

@class Reachability;

@interface FFFantasyRosterController : FFBaseViewController {
    Reachability* internetReachability;
}

@property(nonatomic, weak) id<FFErrorHandlingDelegate> errorDelegate;
@property(nonatomic, weak) id<FFFantasyRosterDelegate> delegate;
@property(nonatomic, weak) id<FFFantasyRosterDataSource> dataSource;
@property(nonatomic, assign) BOOL removeBenched;
@property(nonatomic) UITableView* tableView;

- (void)refreshRosterWithShowingAlert:(BOOL)shouldShow completion:(void(^)(void))block;
- (void)reloadWithServerError:(BOOL)isError;
- (void)showOrHideSubmitIfNeeded;

@end

