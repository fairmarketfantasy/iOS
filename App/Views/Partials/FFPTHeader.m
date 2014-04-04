//
//  FFPTHeader.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/6/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFPTHeader.h"
#import "FFStyle.h"
#import "FFPathImageView.h"

@interface FFPTHeader ()

@property(nonatomic, readonly) UILabel* titleLabel;
@property(nonatomic, readonly) UILabel* teamLabel;

@end

@implementation FFPTHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // avatar
        _avatar = [FFPathImageView.alloc initWithFrame:CGRectMake(15.f, 3.f, 34.f, 34.f)
                                                 image:[UIImage imageNamed:@"rosterslotempty"]
                                              pathType:FFPathImageViewTypeCircle
                                             pathColor:[UIColor clearColor]
                                           borderColor:[UIColor clearColor]
                                             pathWidth:0.f];
        self.avatar.contentMode = UIViewContentModeScaleAspectFit;
        self.avatar.pathType = FFPathImageViewTypeCircle;
        self.avatar.pathColor = [FFStyle white];
        self.avatar.borderColor = self.avatar.pathColor;
        self.avatar.pathWidth = 2.f;
        [self addSubview:self.avatar];
        [self.avatar draw];
        // title label
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(55.f, 0.f, 160, 50.f)];
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [FFStyle lightFont:26.f];
        self.titleLabel.textColor = [FFStyle greyTextColor];
        [self addSubview:self.titleLabel];
        // price label
        _teamLabel = [[UILabel alloc] initWithFrame:CGRectMake(215.f, 0.f, 90.f, 50.f)];
        self.teamLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.teamLabel.backgroundColor = [UIColor clearColor];
        self.teamLabel.font = [FFStyle blockFont:17.f];
        self.teamLabel.textColor = [FFStyle greyTextColor];
        self.teamLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.teamLabel];
        // background
        self.backgroundColor = [UIColor colorWithWhite:.9f
                                                 alpha:1.f];
        UIView* topSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f,
                                                                        320.f, 1.f)];
        topSeparator.backgroundColor = [UIColor colorWithWhite:.8f
                                                         alpha:1.f];
        [self addSubview:topSeparator];
        UIView* bottomSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.f, 39.f,
                                                                            320.f, 1.f)];
        bottomSeparator.backgroundColor = [UIColor colorWithWhite:.8f
                                                             alpha:1.f];
        [self addSubview:bottomSeparator];
    }
    return self;
}

#pragma mark - attributes

- (NSString*)title
{
    return self.titleLabel.text;
}

- (void)setTitle:(NSString*)title
{
    self.titleLabel.text = title;
}

- (NSString*)team
{
    return self.teamLabel.text;
}

- (void)setTeam:(NSString*)team
{
    self.teamLabel.text = team;
}

@end
