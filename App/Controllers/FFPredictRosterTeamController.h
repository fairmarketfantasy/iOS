//
//  FFPredictRosterTeamController.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/4/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFBaseViewController.h"

@class FFRosterPrediction;

@interface FFPredictRosterTeamController : FFBaseViewController

@property(nonatomic) FFRosterPrediction* roster;
@property(nonatomic) UITableView* tableView;

@end
