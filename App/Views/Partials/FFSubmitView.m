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
        _segments = [FUISegmentedControl.alloc initWithItems:@[NSLocalizedString(@"Submit 100FB", nil),
                                                               NSLocalizedString(@"Submit HTH 27FB", nil)]];
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
        
        _submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.submitButton.frame = CGRectMake(60.f, 10.f, 200.f, 30.f);
        self.submitButton.layer.cornerRadius = 3.f;
        self.submitButton.backgroundColor = [FFStyle brightGreen];
        self.submitButton.titleLabel.font = [FFStyle blockFont:14.f];
        self.submitButton.titleLabel.textColor = [FFStyle white];
        [self.submitButton setTitle:NSLocalizedString(@"Submit", nil) forState:UIControlStateNormal];
        [self addSubview:self.submitButton];
    }
    return self;
}

- (void)setupWithType:(FFSubmitViewType)type
{
    switch (type) {
        case FFSubmitViewTypeFantasy:
            self.segments.hidden = NO;
            self.submitButton.hidden = YES;
            break;
        case FFSubmitViewTypeNonFantasy:
            self.submitButton.hidden = NO;
            self.segments.hidden = YES;
            break;
            
        default:
            break;
    }
}

@end
