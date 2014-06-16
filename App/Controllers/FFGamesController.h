//
//  FFGamesController.h
//  FMF Football
//
//  Created by Anton Chuev on 6/5/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFBaseViewController.h"
#import "FFNonFantasyRosterDataSource.h"
#import "FFSportManager.h"

@class FFTeam;

@protocol FFGamesProtocol <NSObject>

- (void)addTeam:(FFTeam *)team;
- (void)fetchGamesShowAlert:(BOOL)shouldShow withCompletion:(void(^)(void))block;
- (void)makeIndividualPredictionOnTeam:(FFTeam *)team;

@end

@class Reachability;

@interface FFGamesController : FFBaseViewController {
    Reachability* internetReachability;
}

@property (nonatomic, weak) id<FFGamesProtocol> delegate;
@property (nonatomic, weak) id<FFNonFantasyRosterDataSource> dataSource;
@property (nonatomic, weak) id<FFErrorHandlingDelegate> errorDelegate;
@property (nonatomic, readonly) UITableView* tableView;

@end

