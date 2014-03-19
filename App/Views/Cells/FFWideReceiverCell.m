//
//  FFWideReceiverCell.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/19/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFWideReceiverCell.h"
#import <FlatUIKit.h>
#import "FFStyle.h"


@implementation FFWideReceiverCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.segments = [[FUISegmentedControl alloc] initWithItems:[self gameTypes]];
        self.segments.selectedFont = [FFStyle regularFont:14.f];
        self.segments.deselectedFont = [FFStyle regularFont:14.f];
        self.segments.deselectedColor = [FFStyle brightGreen];
        self.segments.selectedColor = [UIColor darkGrayColor];
        self.segments.frame = CGRectMake(5.f, 16.f, 310.f, 30.f);
        self.segments.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.segments.selectedSegmentIndex = 0;
        [self.contentView addSubview:self.segments];
    }
    return self;
}

#pragma mark - private

// TODO: move to model
- (NSArray*)gameTypes
{
    return @[
             @"PG",
             @"SG",
             @"PF",
             @"C",
             @"G",
             @"F",
             @"UTIL"
             ];
}

@end
