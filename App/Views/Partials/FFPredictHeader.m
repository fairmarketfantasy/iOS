//
//  FFPredictHeader.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/28/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFPredictHeader.h"
#import <FlatUIKit.h>
#import "FFStyle.h"

@implementation FFPredictHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [FFStyle white];
        self.segments = [[FUISegmentedControl alloc] initWithItems:[self predictionTypes]];
        self.segments.frame = CGRectMake(60.f, 16.f, 200.f, 30.f);
        self.segments.cornerRadius = 3.f;
        self.segments.dividerColor = [FFStyle white];
        self.segments.selectedFontColor = [FFStyle white];
        self.segments.deselectedFontColor = [FFStyle white];
        self.segments.selectedFont = [FFStyle regularFont:14.f];
        self.segments.deselectedFont = [FFStyle regularFont:14.f];
        self.segments.deselectedColor = [FFStyle darkGrey];
        self.segments.selectedColor = [FFStyle brightGreen];
        self.segments.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.segments.selectedSegmentIndex = 0;
        [self addSubview:self.segments];
    }
    return self;
}

// TODO: move to model
- (NSArray*)predictionTypes
{
    return @[
             @"ACTIVE",
             @"HISTORY"
             ];
}

@end
