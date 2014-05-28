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

@interface FFWideReceiverCell()

@property(nonatomic, strong) UILabel *noConnectionLabel;

@end

@implementation FFWideReceiverCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [FFStyle white];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.segments = [[FUISegmentedControl alloc] initWithFrame:CGRectMake(5.f, 18.f, 310.f, 26.f)];
        self.segments.cornerRadius = 3.f;
        self.segments.dividerColor = [FFStyle white];
        self.segments.selectedFontColor = [FFStyle white];
        self.segments.deselectedFontColor = [FFStyle white];
        self.segments.selectedFont = [FFStyle regularFont:12.f];
        self.segments.deselectedFont = [FFStyle regularFont:12.f];
        self.segments.deselectedColor = [FFStyle brightGreen];
        self.segments.selectedColor = [FFStyle darkGrey];
        self.segments.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.segments.selectedSegmentIndex = 0;
        [self.contentView addSubview:self.segments];
        
        self.noConnectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 18.f, self.contentView.frame.size.width, 30.f)];
        self.noConnectionLabel.font = [FFStyle blockFont:20.f];
        self.noConnectionLabel.textColor = [FFStyle lightGrey];
        self.noConnectionLabel.backgroundColor = [UIColor clearColor];
        self.noConnectionLabel.textAlignment = NSTextAlignmentCenter;
        self.noConnectionLabel.text = @"NO INTERNET CONNECTION";
        [self.contentView addSubview:self.noConnectionLabel];
        self.noConnectionLabel.hidden = YES;
    }
    return self;
}

- (void)setItems:(NSArray*)items
{
    for (NSUInteger index = self.segments.numberOfSegments; index > 0; index--) {
        [self.segments removeSegmentAtIndex:index - 1
                                   animated:NO];
    }
    for (NSString* item in items) {
        [self.segments insertSegmentWithTitle:item
                                      atIndex:self.segments.numberOfSegments
                                     animated:NO];
    }
}

@end
