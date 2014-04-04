//
//  FFYourTeamController.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/14/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFBaseViewController.h"

@class FFMarket;
@class FFMarketSet;

@interface FFYourTeamController : FFBaseViewController

@property(nonatomic, readonly) BOOL autoRemovedBenched;
@property(nonatomic, readonly) FFRoster* roster;
@property(nonatomic) FFMarket* selectedMarket;
@property(nonatomic) FFMarketSet* marketsSet;
@property(nonatomic) UITableView* tableView;
- (NSArray*)positions;
- (void)createRoster;
- (void)updateMarkets;

@end
