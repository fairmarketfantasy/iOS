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
#import "FFRoster.h"
#import "FFSessionManager.h"

@interface FFSubmitView()

@property (nonatomic, strong) NSArray *items;

@end

@implementation FFSubmitView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [FFStyle darkGrey];
        // segments
        _segments = [[FUISegmentedControl alloc] initWithItems:@[@"Submit 100FB",
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

- (void)setupWithType:(FFSubmitViewType)type
{
    switch (type) {
        case FFSubmitViewTypeFantasy:
            self.items = @[@"Submit 100FB", @"Submit HTH 27FB"];
            [self.segments setTitle:@"Submit 100FB" forSegmentAtIndex:0];
            [self.segments setTitle:@"Submit HTH 27FB" forSegmentAtIndex:1];
            break;
            
        case FFSubmitViewTypeNonFantasy:
            self.items = @[@"Submit", @"Pick 5"];
            [self.segments setTitle:@"Submit" forSegmentAtIndex:0];
            [self.segments setTitle:@"Pick 5" forSegmentAtIndex:1];
            break;
            
        default:
            break;
    }
}

- (FFRosterSubmitType)submitionType
{
    return [self submitTypeForTitle:self.items[self.segments.selectedSegmentIndex]];
}

- (FFRosterSubmitType)submitTypeForTitle:(NSString *)title
{
    if ([title isEqualToString:@"Submit 100FB"])
        return FFRosterSubmitType100FB;
    else if ([title isEqualToString:@"Submit HTH 27FB"])
        return FFRosterSubmitTypeHTH27FB;
    else if ([title isEqualToString:@"Submit"])
        return FFRosterSubmitTypeCommonNonFantasy;
    else
        return FFRosterSubmitTypePick5;
}

@end
