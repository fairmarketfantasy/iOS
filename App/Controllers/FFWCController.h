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

@class FFSession;
@class FFWCPlayer;
@class FFWCGame;
@class FFWCTeam;

@protocol FFWCDelegate <NSObject>

- (void)fetchDataForSession:(FFSession *)session dataWithCompletion:(void(^)(BOOL success))block;
- (NSString *)stringForWCCategory:(FFWCPredictionCategory)category;
- (void)disablePTForPlayer:(FFWCPlayer *)player;
- (void)disablePTForTeam:(FFWCTeam *)team inGame:(FFWCGame *)game inCategory:(FFWCPredictionCategory)category;

@end

@interface FFWCController : FFBaseViewController

@property (nonatomic, assign) FFWCPredictionCategory category;
@property (nonatomic, assign) NSUInteger selectedCroupIndex;
@property (nonatomic, strong) NSArray *candidates;
@property (nonatomic, readonly) UITableView *tableView;

@property (nonatomic, weak) id <FFWCDelegate> delegate;

@end
