//
//  FFWCController.h
//  FMF Football
//
//  Created by Anton on 6/1/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFBaseViewController.h"
#import "FFWCManager.h"
#import "FFYourTeamDataSource.h"

@interface FFWCController : FFBaseViewController

@property (nonatomic, assign) FFWCPredictionCategory category;
@property (nonatomic, assign) NSUInteger selectedCroupIndex;
@property (nonatomic, strong) NSArray *candidates;
@property (nonatomic, readonly) UITableView *tableView;

//@property (nonatomic, weak) id<FFYourTeamDataSource> dataSource;

@end
