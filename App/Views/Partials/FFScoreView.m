//
//  FFScoreView.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/4/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFScoreView.h"
#import "FFStyle.h"

@implementation FFScoreView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [FFStyle darkGrey];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scoreLabel = [UILabel.alloc initWithFrame:frame];
        self.scoreLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.scoreLabel.numberOfLines = 0;
        self.scoreLabel.backgroundColor = [UIColor clearColor];
        self.scoreLabel.font = [FFStyle blockFont:19.f];
        self.scoreLabel.textColor = [FFStyle white];
        self.scoreLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.scoreLabel];
    }
    return self;
}

@end
