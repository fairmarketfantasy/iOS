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
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.f, 0.f, 200.f, 50.f)];
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(215.f, 0.f, 90.f, 50.f)];
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.priceLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [FFStyle lightFont:26.f];
        self.titleLabel.textColor = [FFStyle tableViewSectionHeaderColor];
        self.priceLabel.backgroundColor = [UIColor clearColor];
        self.priceLabel.font = [FFStyle blockFont:19.f];
        self.priceLabel.textColor = [FFStyle darkGreen];
        self.priceLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.titleLabel];
        [self addSubview:self.priceLabel];
        // background
        self.backgroundColor = [UIColor colorWithWhite:.9f
                                                 alpha:1.f];
        UIView* topSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f,
                                                                        320.f, 1.f)];
        topSeparator.backgroundColor = [UIColor colorWithWhite:.8f
                                                         alpha:1.f];
        [self addSubview:topSeparator];
        UIView* bottomSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.f, 38.f,
                                                                           320.f, 1.f)];
        bottomSeparator.backgroundColor = [UIColor colorWithWhite:.8f
                                                            alpha:1.f];
        [self addSubview:bottomSeparator];
        UIView* bottomSeparator2 = [[UIView alloc] initWithFrame:CGRectMake(0.f, 39.f,
                                                                            320.f, 1.f)];
        bottomSeparator2.backgroundColor = [UIColor colorWithWhite:1.f
                                                             alpha:.5f];
        [self addSubview:bottomSeparator2];
    }
    return self;
}

@end
