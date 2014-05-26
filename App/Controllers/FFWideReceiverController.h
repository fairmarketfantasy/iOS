//
//  FFWideReceiverController.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/19/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFBaseViewController.h"
#import "FFYourTeamDataSource.h"

@class FFPlayer;
@class FFTeam;

@protocol FFPlayersProtocol <NSObject>

- (void)addPlayer:(FFPlayer*)player;
- (void)addTeam:(FFTeam *)team;
- (void)fetchGamesShowAlert:(BOOL)shouldShow withCompletion:(void(^)(void))block;
- (void)showIndividualPredictionsForTeam:(FFTeam *)team;

@end

@class Reachability;

@interface FFWideReceiverController : FFBaseViewController {
       Reachability* internetReachability;
}

@property(nonatomic) NSArray* players; // should contain FFPlayer*
@property(nonatomic, weak) id<FFPlayersProtocol> delegate;
@property(nonatomic, weak) id<FFYourTeamDataSource> dataSource;
@property(nonatomic) UITableView* tableView;

- (void)showPosition:(NSString*)position;
- (void)resetPosition;
- (void)reloadWithServerError:(BOOL)isError;
- (void)fetchPlayersWithShowingAlert:(BOOL)shouldShow completion:(void(^)(void))block;

@end
