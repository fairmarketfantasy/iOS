//
//  FFAutoFillCell.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/19/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFAutoFillCell.h"
#import "FFStyle.h"
#import "FFSessionManager.h"
#import "FUISwitch.h"
#import <FlatUIKit.h>

@interface FFAutoFillCell()

@property (nonatomic, strong) UILabel *switchLabel;

@end

@implementation FFAutoFillCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [FFStyle white];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _autoFillButton = [FFStyle coloredButtonWithText:NSLocalizedString(@"Auto Fill", nil)
                                                   color:[FFStyle brightBlue]
                                             borderColor:[UIColor clearColor]];
        self.autoFillButton.frame = CGRectMake(15.f, 10.f, 100.f, 30.f);
        self.autoFillButton.titleEdgeInsets = UIEdgeInsetsMake(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ?
                                                               3.f : 5.5f,
                                                               0.f, 0.f, 0.f);
        self.autoFillButton.titleLabel.font = [FFStyle blockFont:17.f];
        [self.autoFillButton setTitleColor:[FFStyle white]
                                  forState:UIControlStateNormal];
        [self.contentView addSubview:self.autoFillButton];
        // separator
        UIView* topSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f,
                                                                        320.f, 1.f)];
        topSeparator.backgroundColor = [UIColor colorWithWhite:.8f
                                                         alpha:1.f];
        [self.contentView addSubview:topSeparator];
        
        // switch
        // TODO: fix grayed FUISwitch for iOS 7.1
        _autoRemovedBenched = [[FUISwitch alloc] initWithFrame:CGRectMake(0.f, 0.f,
                                                                          62.f, 30.f)];
        self.autoRemovedBenched.center = CGPointMake(271.f, self.autoFillButton.center.y);
        self.autoRemovedBenched.on = NO;
        self.autoRemovedBenched.onColor = [FFStyle white];
        self.autoRemovedBenched.offColor = [FFStyle white];
        self.autoRemovedBenched.onBackgroundColor = [FFStyle brightBlue];
        self.autoRemovedBenched.highlightedColor = [FFStyle darkGrey];
        self.autoRemovedBenched.offBackgroundColor = [FFStyle lightGrey];
        self.autoRemovedBenched.offLabel.font = [FFStyle blockFont:17.f];
        self.autoRemovedBenched.onLabel.font = [FFStyle blockFont:17.f];
        [self.contentView addSubview:self.autoRemovedBenched];
        
        // switch label
        self.switchLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.f, 10.f,
                                                                         110.f, 30.f)];
        self.switchLabel.backgroundColor = [UIColor clearColor];
        self.switchLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.switchLabel.textAlignment = NSTextAlignmentRight;
        self.switchLabel.numberOfLines = 2;
        self.switchLabel.font = [FFStyle regularFont:12.f];
        self.switchLabel.textColor = [FFStyle lightGrey];
        self.switchLabel.text = NSLocalizedString(@"Auto-remove benched players", nil);
        [self addSubview:self.switchLabel];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGPoint center = self.autoFillButton.center;
    center.y = self.contentView.center.y;
    self.autoFillButton.center = center;
    
    if ([[FFSessionManager shared].currentCategoryName isEqualToString:FANTASY_SPORTS]) {
        _autoRemovedBenched.hidden = NO;
        self.switchLabel.hidden = NO;
        
        // FIX label vertical centered with custom font
        self.autoRemovedBenched.onLabel.frame = CGRectOffset(self.autoRemovedBenched.onLabel.frame, 0.f,
                                                             SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? 1.f : 2.f);
        self.autoRemovedBenched.offLabel.frame = CGRectOffset(self.autoRemovedBenched.offLabel.frame, 0.f,
                                                              SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? 1.f : 2.f);        
    } else {
        _autoRemovedBenched.hidden = YES;
        self.switchLabel.hidden = YES;
    }
}

@end
