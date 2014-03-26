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
        self.backgroundColor = [FFStyle darkGrey];
        _avatar = [FFPathImageView.alloc initWithFrame:CGRectMake(0.f, 0.f, 60.f, 60.f)
                                                 image:[UIImage imageNamed:@"defaultuser"]
                                              pathType:FFPathImageViewTypeCircle
                                             pathColor:[UIColor clearColor]
                                           borderColor:[UIColor clearColor]
                                             pathWidth:0.f];
        _avatar.center = CGPointMake(275.f, 0.5f * self.bounds.size.height);
        [self.avatar setPathType:FFPathImageViewTypeCircle];
        [self addSubview:self.avatar];
        [self.avatar draw];
        _nameLabel = [UILabel.alloc  initWithFrame:CGRectMake(15.f, 5.f, 100.f, 30.f)];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.font = [FFStyle regularFont:19.f];
        self.nameLabel.textColor = [FFStyle white];
        [self addSubview:self.nameLabel];
        UIImageView* walletPic = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"wallet"]];
        walletPic.frame = CGRectMake(0.f, 0.f, walletPic.image.size.width, walletPic.image.size.height);
        walletPic.center = CGPointMake(130.f, self.nameLabel.center.y);
        [self addSubview:walletPic];
        _walletLabel = [UILabel.alloc  initWithFrame:CGRectMake(140.f, self.nameLabel.frame.origin.y, 100.f, 30.f)];
        self.walletLabel.backgroundColor = [UIColor clearColor];
        self.walletLabel.textColor = [FFStyle darkBlue];
        [self addSubview:self.walletLabel];
        _dateLabel = [UILabel.alloc  initWithFrame:CGRectMake(15.f, 35.f, 200.f, 15.f)];
        self.dateLabel.backgroundColor = [UIColor clearColor];
        self.dateLabel.font = [FFStyle regularFont:12.f];
        self.dateLabel.textColor = [FFStyle lightGrey];
        [self addSubview:self.dateLabel];
        _pointsLabel = [UILabel.alloc  initWithFrame:CGRectMake(15.f, 55.f, 80.f, 30.f)];
        self.pointsLabel.backgroundColor = [UIColor clearColor];
        self.pointsLabel.font = [FFStyle regularFont:14.f];
        self.pointsLabel.textColor = [FFStyle darkBlue];
        [self addSubview:self.pointsLabel];
        _winsLabel = [UILabel.alloc  initWithFrame:CGRectMake(100.f, self.pointsLabel.frame.origin.y, 140.f, 30.f)];
        self.winsLabel.backgroundColor = [UIColor clearColor];
        self.winsLabel.font = [FFStyle regularFont:14.f];
        self.winsLabel.textColor = [FFStyle darkBlue];
        [self addSubview:self.winsLabel];
    }
    return self;
}

@end
