//
//  FFPredictRosterScoreController.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/4/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFPredictRosterScoreController.h"
#import "FFScoreView.h"
#import "FFStyle.h"
// model
#import "FFRosterPrediction.h"

@interface FFPredictRosterScoreController ()

@property(nonatomic) FFScoreView* scoreView;

@end

@implementation FFPredictRosterScoreController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scoreView = [FFScoreView.alloc initWithFrame:self.view.bounds];
    [self.view addSubview:self.scoreView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.delegate.roster) {
        NSString* leaderString = [NSString stringWithFormat:NSLocalizedString(@"You took %ist place", nil),
                                  self.delegate.roster.contestRank.integerValue];
        NSString* subTitle = self.delegate.roster.amountPaid.integerValue == 0
        ? NSLocalizedString(@"Didn't win this time", nil)
        : [NSString stringWithFormat:NSLocalizedString(@"And won %i", nil),
           self.delegate.roster.amountPaid.integerValue];
        self.scoreView.scoreLabel.text = [NSString stringWithFormat:@"%@\n%@", leaderString, subTitle];
    } else {
        self.scoreView.scoreLabel.text = @"";
    }
}

@end
