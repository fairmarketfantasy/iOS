//
//  FFPredictRosterTeamController.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/4/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFBaseViewController.h"


@class FFPlayer;

@protocol FFPredictionPlayersProtocol <NSObject>

@property(nonatomic) NSArray* players; // should contain FFPlayer*
@property(nonatomic, readonly) CGFloat rosterSalary;
@property(nonatomic, readonly) NSString* rosterState;
- (void)removePlayer:(FFPlayer*)player;

@end

@class FFRosterPrediction;

@interface FFPredictRosterTeamController : FFBaseViewController

@property(nonatomic, weak) id<FFPredictionPlayersProtocol> delegate;
@property(nonatomic) UITableView* tableView;

@end
