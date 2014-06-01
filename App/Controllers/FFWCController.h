//
//  FFWCController.h
//  FMF Football
//
//  Created by Anton on 6/1/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFBaseViewController.h"

typedef NS_ENUM(NSUInteger, FFWCPredictionCategory)
{
    FFWCDailyWins = 0,
    FFWCGroupWinners,
    FFWCMvp,
    FFWCCupWinner
};

@interface FFWCController : FFBaseViewController

@property (nonatomic, assign) FFWCPredictionCategory category;
@property (nonatomic, assign) NSUInteger selectedCroupIndex;
@property (nonatomic, strong) NSArray *elements;
@property (nonatomic, readonly) UITableView *tableView;

@end
