//
//  FFMenuCell.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 2/27/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFMenuCell.h"

#define MENU_CELL_ANIMATION_DURATION ((NSTimeInterval).5f)

@implementation FFMenuCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.textColor = [FFStyle lightGrey];
        // add custom separator
        self.separator = [self newSeparator];
        [self addSubview:self.separator];
        // selected color
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
        [self.selectedBackgroundView addSubview:[self newSeparator]];
        self.selectedBackgroundView.backgroundColor = [FFStyle darkGreen];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted
              animated:(BOOL)animated
{
    [super setHighlighted:highlighted
                 animated:animated];
    [self updateSelection:highlighted];
}

- (void)setAccessoryNamed:(NSString*)accessoryName
{
    UIImage* accessoryImage = [UIImage imageNamed:accessoryName];
    UIImageView* accessory = [[UIImageView alloc] initWithFrame:
                                                      CGRectMake(0.f, 0.f,
                                                                 accessoryImage.size.width,
                                                                 accessoryImage.size.height)];
    accessory.image = accessoryImage;
    accessory.backgroundColor = [UIColor clearColor];
    self.accessoryView = accessory;
}

- (UIView*)newSeparator
{
    CGFloat separatorHeight = 1.f;
    CGFloat contentHeight = self.frame.size.height - separatorHeight;
    UIView* separator = [[UIView alloc] initWithFrame:
                                            CGRectMake(0.f,
                                                       contentHeight,
                                                       self.frame.size.width, separatorHeight)];
    separator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    separator.backgroundColor = [FFStyle lightGrey];
    return separator;
}

#pragma mark - private

- (void)updateSelection:(BOOL)enable
{
    if (enable) {
        [self addSubview:self.selectedBackgroundView];
        [self sendSubviewToBack:self.selectedBackgroundView];
        self.selectedBackgroundView.alpha = 1.f;
    } else {
        [UIView animateWithDuration:MENU_CELL_ANIMATION_DURATION
                         animations:^{
                             self.selectedBackgroundView.alpha = 0.f;
                         }
                         completion:^(BOOL finished)
        {
            [self.selectedBackgroundView removeFromSuperview];
        }];
    }
}

@end
