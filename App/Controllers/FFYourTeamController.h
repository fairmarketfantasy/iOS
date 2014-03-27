//
//  FFYourTeamController.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/14/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFBaseViewController.h"

@interface FFYourTeamController : FFBaseViewController

@property(nonatomic) FFMarketSet* marketsSet;
@property(nonatomic) UITableView* tableView;
- (void)updateHeader;
- (void)updateMarkets;

@end
