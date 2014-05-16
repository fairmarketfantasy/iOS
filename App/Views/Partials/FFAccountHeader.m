//
//  FFAccountHeader.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/21/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFAccountHeader.h"
#import <FlatUIKit.h>
#import "FFPathImageView.h"
#import "FFStyle.h"
#import <QuartzCore/QuartzCore.h>

@implementation FFAccountHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // background
        self.backgroundColor = [UIColor clearColor];
        UIImageView* backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginbg.png"]];
        backgroundView.frame = self.bounds;
        backgroundView.clipsToBounds = YES;
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        backgroundView.contentMode = UIViewContentModeTop;
        [self addSubview:backgroundView];
        // avatar
        _avatar = [FFPathImageView.alloc initWithFrame:CGRectMake(15.f, 15.f, 60.f, 60.f)
                                                 image:[UIImage imageNamed:@"defaultuser"]
                                              pathType:FFPathImageViewTypeCircle
                                             pathColor:[UIColor clearColor]
                                           borderColor:[UIColor clearColor]
                                             pathWidth:0.f];
        self.avatar.contentMode = UIViewContentModeScaleAspectFit;
        self.avatar.pathType = FFPathImageViewTypeCircle;
        self.avatar.pathColor = [FFStyle white];
        self.avatar.borderColor = self.avatar.pathColor;
        self.avatar.pathWidth = -2.5f;
        [self addSubview:self.avatar];
        [self.avatar draw];
        // name label
        _nameLabel = [UILabel.alloc  initWithFrame:CGRectMake(90.f, 20.f, 200.f, 30.f)];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.font = [FFStyle regularFont:19.f];
        self.nameLabel.textColor = [FFStyle white];
        [self addSubview:self.nameLabel];
        // date
        _dateLabel = [UILabel.alloc  initWithFrame:CGRectMake(90.f, 50.f, 200.f, 15.f)];
        self.dateLabel.backgroundColor = [UIColor clearColor];
        self.dateLabel.font = [FFStyle regularFont:12.f];
        self.dateLabel.textColor = [FFStyle lightGrey];
        [self addSubview:self.dateLabel];

        // fan bucks

        _fanBucksButton = [FFStyle coloredButtonWithText:@""
                                                   color:[FFStyle brightGreen]
                                             borderColor:[UIColor clearColor]];
        self.fanBucksButton.frame = CGRectMake(15.f, 90.f, 94.f, 50.f);
        self.fanBucksButton.layer.borderWidth = 0.f;
        self.fanBucksButton.layer.cornerRadius = 0.f;
        [self addSubview:self.fanBucksButton];

        UILabel* fanBucksCaptionLabel = [UILabel.alloc initWithFrame:CGRectMake(10.f, 5.f, 84.f, 20.f)];
        fanBucksCaptionLabel.backgroundColor = [UIColor clearColor];
        fanBucksCaptionLabel.font = [FFStyle regularFont:14.f];
        fanBucksCaptionLabel.textColor = [FFStyle black];
        fanBucksCaptionLabel.text = NSLocalizedString(@"FanBucks  〉", nil);
        [self.fanBucksButton addSubview:fanBucksCaptionLabel];

        _fanBucksLabel = [UILabel.alloc  initWithFrame:CGRectMake(10.f, 25.f, 84.f, 20.f)];
        self.fanBucksLabel.backgroundColor = [UIColor clearColor];
        self.fanBucksLabel.font = [FFStyle regularFont:14.f];
        self.fanBucksLabel.textColor = [FFStyle white];
        [self.fanBucksButton addSubview:self.fanBucksLabel];

        // prestige

        UIView* prestige = [UIView.alloc initWithFrame:CGRectMake(113.f, 90.f, 94.f, 50.f)];
        prestige.backgroundColor = [FFStyle brightGreen];
        [self addSubview:prestige];

        UILabel* prestigeCaptionLabel = [UILabel.alloc initWithFrame:CGRectMake(10.f, 5.f, 84.f, 20.f)];
        prestigeCaptionLabel.backgroundColor = [UIColor clearColor];
        prestigeCaptionLabel.font = [FFStyle regularFont:14.f];
        prestigeCaptionLabel.textColor = [FFStyle black];
        prestigeCaptionLabel.text = NSLocalizedString(@"PresTige", nil);
        [prestige addSubview:prestigeCaptionLabel];

        _prestigeLabel = [UILabel.alloc  initWithFrame:CGRectMake(10.f, 25.f, 84.f, 20.f)];
        self.prestigeLabel.backgroundColor = [UIColor clearColor];
        self.prestigeLabel.font = [FFStyle regularFont:14.f];
        self.prestigeLabel.textColor = [FFStyle white];
        [prestige addSubview:self.prestigeLabel];

        // wins

        UIView* wins = [UIView.alloc initWithFrame:CGRectMake(211.f, 90.f, 94.f, 50.f)];
        wins.backgroundColor = [FFStyle brightGreen];
        [self addSubview:wins];

        UILabel* winsCaptionLabel = [UILabel.alloc initWithFrame:CGRectMake(10.f, 5.f, 84.f, 20.f)];
        winsCaptionLabel.backgroundColor = [UIColor clearColor];
        winsCaptionLabel.font = [FFStyle regularFont:14.f];
        winsCaptionLabel.textColor = [FFStyle black];
        winsCaptionLabel.text = NSLocalizedString(@"Wins", nil);
        [wins addSubview:winsCaptionLabel];

        _winsLabel = [UILabel.alloc  initWithFrame:CGRectMake(10.f, 25.f, 84.f, 20.f)];
        self.winsLabel.backgroundColor = [UIColor clearColor];
        self.winsLabel.font = [FFStyle regularFont:14.f];
        self.winsLabel.textColor = [FFStyle white];
        [wins addSubview:self.winsLabel];
        
    }
    return self;
}

@end
