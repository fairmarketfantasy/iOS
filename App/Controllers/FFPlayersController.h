//
//  FFPlayersController.h
//  FMF Football
//
//  Created by Anton Chuev on 6/5/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFBaseViewController.h"
#import "FFFantasyRosterDataSource.h"
#import "FFSportManager.h"

@class FFPlayer;

@protocol FFPlayersProtocol <NSObject>

- (void)addPlayer:(FFPlayer*)player;
- (void)fetchPlayersForPosition:(NSInteger)position showAlert:(BOOL)shouldShow completion:(void(^)(void))block;

@end

@class Reachability;

@interface FFPlayersController : FFBaseViewController {
    Reachability* internetReachability;
}

@property (nonatomic, strong) NSArray* players; // should contain FFPlayer*
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, weak) id<FFErrorHandlingDelegate> errorDelegate;
@property (nonatomic, weak) id<FFPlayersProtocol> delegate;
@property (nonatomic, weak) id<FFFantasyRosterDataSource> dataSource;
@property (nonatomic, readonly) NSUInteger position;

- (void)showPosition:(NSString*)position;

@end

