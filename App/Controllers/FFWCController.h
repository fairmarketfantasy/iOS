//
//  FFWCController.h
//  FMF Football
//
//  Created by Anton on 6/1/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFBaseViewController.h"
#import "FFWCManager.h"

@class FFSession;
@class FFWCPlayer;
@class FFWCGame;
@class FFWCTeam;

@protocol FFWCDelegate <NSObject>

- (void)submitPredictionOnTeam:(FFWCTeam *)team
                        inGame:(FFWCGame *)game
                      category:(FFWCPredictionCategory)category;

- (void)submitPredictionOnPlayer:(FFWCPlayer *)player
                        category:(FFWCPredictionCategory)category;

- (void)refreshDataShowingAlert:(BOOL)shouldShow completion:(void(^)(void))block;

@end

@interface FFWCController : FFBaseViewController

@property (nonatomic, assign) FFWCPredictionCategory category;
@property (nonatomic, assign) NSUInteger selectedCroupIndex;
@property (nonatomic, strong) NSArray *candidates;
@property (nonatomic, readonly) UITableView *tableView;

@property (nonatomic, weak) id <FFWCDelegate> delegate;
@property (nonatomic, weak) id <FFErrorHandlingDelegate> errorDelegate;

- (void)resetPicker;

@end
