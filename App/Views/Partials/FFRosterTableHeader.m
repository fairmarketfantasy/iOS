//
//  FFRosterTableHeader.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/6/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFRosterTableHeader.h"
#import "FFStyle.h"

@implementation FFRosterTableHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [FFStyle white];
        // title label
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.f, 0.f, 200.f, 50.f)];
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [FFStyle lightFont:26.f];
        self.titleLabel.textColor = [FFStyle greyTextColor];
        [self addSubview:self.titleLabel];
        // price label
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(215.f, 0.f, 90.f, 50.f)];
        self.priceLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.priceLabel.backgroundColor = [UIColor clearColor];
        self.priceLabel.font = [FFStyle blockFont:19.f];
        self.priceLabel.textColor = [FFStyle brightGreen];
        self.priceLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.priceLabel];
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

@end
