//
//  FFPTCell.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/21/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFPTCell.h"
#import <FlatUIKit.h>
#import "FFStyle.h"

@implementation FFPTCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor colorWithWhite:.94f
                                                             alpha:1.f];
        UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(7.f, 118.f, 306.f, 1.f)];
        separator.backgroundColor = [UIColor colorWithWhite:.8f
                                                      alpha:.5f];
        [self.contentView addSubview:separator];

        UIView* separator2 = [[UIView alloc] initWithFrame:CGRectMake(7.f, 119.f, 306.f, 1.f)];
        separator2.backgroundColor = [UIColor colorWithWhite:1.f
                                                       alpha:.5f];
        [self.contentView addSubview:separator2];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        // segments
        _segments = [FUISegmentedControl.alloc initWithItems:@[@"Less",
                                                               @"More"]];
        self.segments.frame = CGRectMake(30.f, 50.f, 260.f, 40.f);
        self.segments.cornerRadius = 3.f;
        self.segments.dividerColor = [FFStyle white];
        self.segments.selectedFontColor = [FFStyle white];
        self.segments.deselectedFontColor = [FFStyle white];
        self.segments.selectedFont = [FFStyle blockFont:14.f];
        self.segments.deselectedFont = [FFStyle blockFont:14.f];
        self.segments.deselectedColor = [FFStyle brightBlue];
        self.segments.selectedColor = [FFStyle darkGrey];
        self.segments.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.segments.selectedSegmentIndex = 0;
        [self.contentView addSubview:self.segments];
        // title label
        _titleLabel = [UILabel.alloc initWithFrame:CGRectMake(5.f, 16.f, 310.f, 24.f)];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [FFStyle regularFont:17.f];
        self.titleLabel.textColor = [FFStyle darkGreyTextColor];
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

@end
