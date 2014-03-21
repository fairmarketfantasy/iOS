//
//  FFTeamAddCell.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/19/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFTeamAddCell.h"
#import <FlatUIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "FFStyle.h"

@implementation FFTeamAddCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(82.f, 14.f, 140.f, 16.f)];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.font = [FFStyle regularFont:14.f];
        self.nameLabel.textColor = [FFStyle darkGreyTextColor];
        self.nameLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.nameLabel];

        _costLabel = [[UILabel alloc] initWithFrame:CGRectMake(82.f, 50.f, 140.f, 16.f)];
        self.costLabel.backgroundColor = [UIColor clearColor];
        self.costLabel.font = [FFStyle boldFont:14.f];
        self.costLabel.textColor = [FFStyle darkGreyTextColor];
        self.costLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.costLabel];
        _PTButton = [FFStyle coloredButtonWithText:NSLocalizedString(@"PT", nil)
                                             color:self.contentView.backgroundColor
                                       borderColor:[FFStyle brightBlue]];
        self.PTButton.frame = CGRectMake(222.f,
                                         20.f,
                                         40.f,
                                         40.f);
        self.PTButton.layer.borderWidth = 2.f;
        [self.PTButton setTitleColor:[FFStyle brightBlue]
                            forState:UIControlStateNormal];
        self.PTButton.titleLabel.font = [FFStyle blockFont:17.f];
        self.PTButton.titleEdgeInsets = UIEdgeInsetsMake(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ?
                                                         3.f : 5.5f,
                                                         0.f, 0.f, 0.f);
        [self.contentView addSubview:self.PTButton];
        _AddButton = [FFStyle coloredButtonWithText:NSLocalizedString(@"Add", nil)
                                             color:[FFStyle brightGreen]
                                       borderColor:[FFStyle white]];
        self.AddButton.frame = CGRectMake(267.f,
                                          20.f,
                                          45.f,
                                          40.f);
        self.AddButton.titleLabel.font = [FFStyle blockFont:17.f];
        [self.AddButton setTitleColor:[FFStyle black]
                             forState:UIControlStateNormal];
        self.AddButton.titleEdgeInsets = UIEdgeInsetsMake(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ?
                                                          3.f : 5.5f,
                                                          0.f, 0.f, 0.f);
        [self.contentView addSubview:self.AddButton];
    }
    return self;
}

@end
