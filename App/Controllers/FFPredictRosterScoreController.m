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
    self.scoreView.scoreLabel.text = [NSString stringWithFormat:@"%@ %@",
                                      NSLocalizedString(@"You took 1st place\nAnd won", nil),
                                      @"TODO"]; // TODO: replace MOC
#warning MOC
}

@end
