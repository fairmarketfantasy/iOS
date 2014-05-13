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

@protocol FFPlayersProtocol <NSObject>

@property(nonatomic, readonly) NSString* rosterId;
@property(nonatomic, readonly) CGFloat rosterSalary;
@property(nonatomic, readonly) NSArray* positions;
@property(nonatomic, readonly) NSDictionary* positionsNames;
@property(nonatomic, readonly) BOOL autoRemovedBenched;

- (void)addPlayer:(FFPlayer*)player;

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

@end
