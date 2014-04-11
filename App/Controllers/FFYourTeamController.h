//
//  FFYourTeamController.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/14/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFBaseViewController.h"

@protocol FFYourTeamProtocol <NSObject>

- (void)showPosition:(NSString*)position;

@end

@class FFMarket;
@class FFMarketSet;

@interface FFYourTeamController : FFBaseViewController

@property(nonatomic, weak) id<FFYourTeamProtocol> delegate;
@property(nonatomic, readonly) BOOL autoRemovedBenched;
@property(nonatomic, readonly) FFRoster* roster;
@property(nonatomic) FFMarket* selectedMarket;
@property(nonatomic) FFMarketSet* marketsSet;
@property(nonatomic) UITableView* tableView;
- (NSArray*)uniquePositions;
- (void)createRoster;
- (void)updateMarkets;

@end
