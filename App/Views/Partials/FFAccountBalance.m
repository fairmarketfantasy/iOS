//
//  FFAccountBalance.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/11/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFAccountBalance.h"
#import "FFStyle.h"

@implementation FFAccountBalance

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:.94f
                                                 alpha:1.f];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[self(==145)]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:NSDictionaryOfVariableBindings(self)]];

        // balance

        _balanceLabel = [UILabel.alloc initWithFrame:CGRectMake(130.f, 10.f, 120.f, 30.f)];
        self.balanceLabel.backgroundColor = [UIColor clearColor];
        self.balanceLabel.textColor = [FFStyle brightGreen];
        self.balanceLabel.font = [FFStyle blockFont:17.f];
        self.balanceLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.balanceLabel];

        UILabel* captionBalanceLabel = [UILabel.alloc initWithFrame:CGRectMake(10.f, 10.f, 120.f, 30.f)];
        captionBalanceLabel.backgroundColor = [UIColor clearColor];
        captionBalanceLabel.textColor = [FFStyle darkGreyTextColor];
        captionBalanceLabel.font = [FFStyle blockFont:17.f];
        captionBalanceLabel.text = @"Account Balance";
        [self addSubview:captionBalanceLabel];

        // separator

        UIView* separator = [UIView.alloc initWithFrame:CGRectMake(0.f, 44.f, self.bounds.size.width, 1.f)];
        separator.backgroundColor = [FFStyle lightGrey];
        separator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:separator];

        // subTitle

        UILabel* titleLabel = [UILabel.alloc initWithFrame:CGRectMake(10.f, 55.f, 250.f, 20.f)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [FFStyle darkGreyTextColor];
        titleLabel.font = [FFStyle blockFont:14.f];
        titleLabel.text = @"Your account this month";
        [self addSubview:titleLabel];

        // fan bucks

        _fanBucksLabel = [UILabel.alloc initWithFrame:CGRectMake(75.f, 85.f, 35.f, 20.f)];
        self.fanBucksLabel.backgroundColor = [UIColor clearColor];
        self.fanBucksLabel.textColor = [FFStyle darkGreyTextColor];
        self.fanBucksLabel.font = [FFStyle regularFont:12.f];
        self.fanBucksLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.fanBucksLabel];

        UILabel* captionFanBucksLabel = [UILabel.alloc initWithFrame:CGRectMake(10.f, 85.f, 65.f, 20.f)];
        captionFanBucksLabel.backgroundColor = [UIColor clearColor];
        captionFanBucksLabel.textColor = [FFStyle greyTextColor];
        captionFanBucksLabel.font = [FFStyle regularFont:12.f];
        captionFanBucksLabel.text = @"○ FanBuks";
        [self addSubview:captionFanBucksLabel];

        // awards

        _awardsLabel = [UILabel.alloc initWithFrame:CGRectMake(75.f, 110.f, 35.f, 20.f)];
        self.awardsLabel.backgroundColor = [UIColor clearColor];
        self.awardsLabel.textColor = [FFStyle darkGreyTextColor];
        self.awardsLabel.font = [FFStyle regularFont:12.f];
        self.awardsLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.awardsLabel];

        UILabel* captionAwardsLabel = [UILabel.alloc initWithFrame:CGRectMake(10.f, 110.f, 65.f, 20.f)];
        captionAwardsLabel.backgroundColor = [UIColor clearColor];
        captionAwardsLabel.textColor = [FFStyle greyTextColor];
        captionAwardsLabel.font = [FFStyle regularFont:12.f];
        captionAwardsLabel.text = @"○ Awards";
        [self addSubview:captionAwardsLabel];

        // predictions

        _predictionsLabel = [UILabel.alloc initWithFrame:CGRectMake(230.f, 85.f, 25.f, 20.f)];
        self.predictionsLabel.backgroundColor = [UIColor clearColor];
        self.predictionsLabel.textColor = [FFStyle darkGreyTextColor];
        self.predictionsLabel.font = [FFStyle regularFont:12.f];
        self.predictionsLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.predictionsLabel];

        UILabel* captionPredictionsLabel = [UILabel.alloc initWithFrame:CGRectMake(115.f, 85.f, 75.f, 20.f)];
        captionPredictionsLabel.backgroundColor = [UIColor clearColor];
        captionPredictionsLabel.textColor = [FFStyle greyTextColor];
        captionPredictionsLabel.font = [FFStyle regularFont:12.f];
        captionPredictionsLabel.text = @"○ Predictions";
        [self addSubview:captionPredictionsLabel];

        // winnings multiplier

        _winningsMultiplierLabel = [UILabel.alloc initWithFrame:CGRectMake(230.f, 110.f, 25.f, 20.f)];
        self.winningsMultiplierLabel.backgroundColor = [UIColor clearColor];
        self.winningsMultiplierLabel.textColor = [FFStyle darkGreyTextColor];
        self.winningsMultiplierLabel.font = [FFStyle regularFont:12.f];
        self.winningsMultiplierLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.winningsMultiplierLabel];

        UILabel* captionWinningsMultiplierLabel = [UILabel.alloc initWithFrame:CGRectMake(115.f, 110.f, 115.f, 20.f)];
        captionWinningsMultiplierLabel.backgroundColor = [UIColor clearColor];
        captionWinningsMultiplierLabel.textColor = [FFStyle greyTextColor];
        captionWinningsMultiplierLabel.font = [FFStyle regularFont:12.f];
        captionWinningsMultiplierLabel.text = @"○ Winnings Multiplier";
        [self addSubview:captionWinningsMultiplierLabel];
    }
    return self;
}

@end
