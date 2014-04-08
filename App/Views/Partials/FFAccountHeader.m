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

        // points

        UIView* points = [UIView.alloc initWithFrame:CGRectMake(15.f, 90.f, 143.f, 40.f)];
        points.backgroundColor = [FFStyle brightGreen];
        [self addSubview:points];
        
        UILabel* pointsCaptionLabel = [UILabel.alloc initWithFrame:CGRectMake(10.f, 0.f, 70.f, 40.f)];
        pointsCaptionLabel.backgroundColor = [UIColor clearColor];
        pointsCaptionLabel.font = [FFStyle regularFont:14.f];
        pointsCaptionLabel.textColor = [FFStyle black];
        pointsCaptionLabel.text = NSLocalizedString(@"FanBucks", nil);
        [points addSubview:pointsCaptionLabel];

        _pointsLabel = [UILabel.alloc  initWithFrame:CGRectMake(70.f, 0.f, 63.f, 40.f)];
        self.pointsLabel.backgroundColor = [UIColor clearColor];
        self.pointsLabel.font = [FFStyle regularFont:14.f];
        self.pointsLabel.textColor = [FFStyle white];
        self.pointsLabel.textAlignment = NSTextAlignmentRight;
        [points addSubview:self.pointsLabel];

        // wins

        UIView* wins = [UIView.alloc initWithFrame:CGRectMake(15.f, 134.f, 143.f, 40.f)];
        wins.backgroundColor = [FFStyle brightGreen];
        [self addSubview:wins];
        
        UILabel* winsCaptionLabel = [UILabel.alloc initWithFrame:CGRectMake(10.f, 0.f, 40.f, 40.f)];
        winsCaptionLabel.backgroundColor = [UIColor clearColor];
        winsCaptionLabel.font = [FFStyle regularFont:14.f];
        winsCaptionLabel.textColor = [FFStyle black];
        winsCaptionLabel.text = NSLocalizedString(@"Wins", nil);
        [wins addSubview:winsCaptionLabel];

        _winsLabel = [UILabel.alloc  initWithFrame:CGRectMake(50.f, 0.f, 83.f, 40.f)];
        self.winsLabel.backgroundColor = [UIColor clearColor];
        self.winsLabel.font = [FFStyle regularFont:14.f];
        self.winsLabel.textColor = [FFStyle white];
        self.winsLabel.textAlignment = NSTextAlignmentRight;
        [wins addSubview:self.winsLabel];

        // balance

        UIView* balance = [UIView.alloc initWithFrame:CGRectMake(162.f, 90.f, 143.f, 40.f)];
        balance.backgroundColor = [FFStyle brightGreen];
        [self addSubview:balance];

        UILabel* balanceCaptionLabel = [UILabel.alloc initWithFrame:CGRectMake(10.f, 0.f, 40.f, 40.f)];
        balanceCaptionLabel.backgroundColor = [UIColor clearColor];
        balanceCaptionLabel.font = [FFStyle regularFont:14.f];
        balanceCaptionLabel.textColor = [FFStyle black];
        balanceCaptionLabel.text = NSLocalizedString(@"Cash", nil);
        [balance addSubview:balanceCaptionLabel];

        _balanceLabel = [UILabel.alloc  initWithFrame:CGRectMake(50.f, 0.f, 83.f, 40.f)];
        self.balanceLabel.backgroundColor = [UIColor clearColor];
        self.balanceLabel.font = [FFStyle regularFont:14.f];
        self.balanceLabel.textColor = [FFStyle white];
        self.balanceLabel.textAlignment = NSTextAlignmentRight;
        [balance addSubview:self.balanceLabel];

        // prestige

        UIView* prestige = [UIView.alloc initWithFrame:CGRectMake(162.f, 134.f, 143.f, 40.f)];
        prestige.backgroundColor = [FFStyle brightGreen];
        [self addSubview:prestige];

        UILabel* prestigeCaptionLabel = [UILabel.alloc initWithFrame:CGRectMake(10.f, 0.f, 60.f, 40.f)];
        prestigeCaptionLabel.backgroundColor = [UIColor clearColor];
        prestigeCaptionLabel.font = [FFStyle regularFont:14.f];
        prestigeCaptionLabel.textColor = [FFStyle black];
        prestigeCaptionLabel.text = NSLocalizedString(@"PresTige", nil);
        [prestige addSubview:prestigeCaptionLabel];

        _prestigeLabel = [UILabel.alloc  initWithFrame:CGRectMake(70.f, 0.f, 63.f, 40.f)];
        self.prestigeLabel.backgroundColor = [UIColor clearColor];
        self.prestigeLabel.font = [FFStyle regularFont:14.f];
        self.prestigeLabel.textColor = [FFStyle white];
        self.prestigeLabel.textAlignment = NSTextAlignmentRight;
        [prestige addSubview:self.prestigeLabel];
    }
    return self;
}

@end
