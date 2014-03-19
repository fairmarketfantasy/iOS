//
//  FFAutoFillCell.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/19/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFAutoFillCell.h"
#import "FFStyle.h"

@implementation FFAutoFillCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _autoFillButton = [FFStyle coloredButtonWithText:NSLocalizedString(@"Auto Fill", nil)
                                                   color:[FFStyle brightBlue]
                                             borderColor:[UIColor clearColor]];
        self.autoFillButton.frame = CGRectMake(15.f, 10.f, 100.f, 40.f);
        self.autoFillButton.titleLabel.font = [FFStyle blockFont:17.f];
        [self.autoFillButton setTitleColor:[FFStyle white]
                                  forState:UIControlStateNormal];
        [self.contentView addSubview:self.autoFillButton];
        // Initialization code
    }
    return self;
}

@end
