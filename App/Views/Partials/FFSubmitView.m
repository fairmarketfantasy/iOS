//
//  FFSubmitView.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/3/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFSubmitView.h"
#import <FlatUIKit.h>
#import "FFStyle.h"

@implementation FFSubmitView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [FFStyle darkGrey];
        // segments
        _segments = [FUISegmentedControl.alloc initWithItems:@[@"Submit 100FB",
                                                               @"Submit HTH 27FB"]];
        self.segments.frame = CGRectMake(15.f, 10.f, 290.f, 30.f);
        self.segments.cornerRadius = 3.f;
        self.segments.dividerColor = [FFStyle white];
        self.segments.selectedFontColor = [FFStyle white];
        self.segments.deselectedFontColor = [FFStyle white];
        self.segments.selectedFont = [FFStyle blockFont:14.f];
        self.segments.deselectedFont = [FFStyle blockFont:14.f];
        self.segments.deselectedColor = [FFStyle brightGreen];
        self.segments.selectedColor = [FFStyle darkGrey];
        self.segments.selectedSegmentIndex = UISegmentedControlNoSegment;
        [self addSubview:self.segments];
    }
    return self;
}

@end
