//
//  FFPredictionsSelector.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/3/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFPredictionsSelector.h"
#import "FFStyle.h"
#import <QuartzCore/QuartzCore.h>

@interface FFPredictionsSelector ()

@property(nonatomic) UIButton* individualButton;
@property(nonatomic) UIButton* rosterButton;

@end

@implementation FFPredictionsSelector

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:1.f
                                                 alpha:.9f];
        // individual button
        self.individualButton = [FFStyle clearButtonWithText:@"Individual predictions"
                                                 borderColor:[FFStyle lightGrey]];
        self.individualButton.frame = CGRectMake(-1.f, -1.f, 322.f, 52.f);
        self.individualButton.layer.cornerRadius = 0.f;
        [self.individualButton setTitleColor:[FFStyle darkGreyTextColor]
                                    forState:UIControlStateNormal];
        self.individualButton.titleLabel.font = [FFStyle regularFont:17.f];
        [self.individualButton addTarget:self
                                  action:@selector(individualSelected:)
                        forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.individualButton];
        // roster button
        self.rosterButton = [FFStyle clearButtonWithText:@"Roster predictions"
                                             borderColor:[FFStyle lightGrey]];
        self.rosterButton.frame = CGRectMake(-1.f, 50.f, 322.f, 52.f);
        self.rosterButton.layer.cornerRadius = 0.f;
        self.rosterButton.titleLabel.textColor = [FFStyle darkGreyTextColor];
        [self.rosterButton setTitleColor:[FFStyle darkGreyTextColor]
                                forState:UIControlStateNormal];
        [self.rosterButton setTitle:@"Roster predictions"
                           forState:UIControlStateNormal];
        self.rosterButton.titleLabel.font = [FFStyle regularFont:17.f];
        [self.rosterButton addTarget:self
                              action:@selector(rosterSelected:)
                    forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.rosterButton];
    }
    return self;
}

#pragma mark - button actions

- (void)individualSelected:(UIButton*)button
{
    if (self.delegate) {
        [self.delegate predictionsTypeSelected:FFPredictionsTypeIndividual];
    }
}

- (void)rosterSelected:(UIButton*)button
{
    if (self.delegate) {
        [self.delegate predictionsTypeSelected:FFPredictionsTypeRoster];
    }
}

@end
