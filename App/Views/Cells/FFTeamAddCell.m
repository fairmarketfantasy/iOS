//
//  FFTeamAddCell.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/19/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFTeamAddCell.h"
#import <FlatUIKit.h>

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
        self.nameLabel.textColor = [FFStyle greyTextColor];
        self.nameLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.nameLabel];

        _costLabel = [[UILabel alloc] initWithFrame:CGRectMake(82.f, 49.f, 140.f, 16.f)];
        self.costLabel.backgroundColor = [UIColor clearColor];
        self.costLabel.font = [FFStyle boldFont:14.f];
        self.costLabel.textColor = [FFStyle darkGreyTextColor];
        self.costLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.costLabel];
        _PTButton = [FFStyle coloredButtonWithText:NSLocalizedString(@"PT", nil)
                                             color:[UIColor clearColor]
                                       borderColor:[FFStyle darkGreen]];
        self.PTButton.frame = CGRectMake(222.f,
                                         20.f,
                                         40.f,
                                         40.f);
        [self.PTButton setTitleColor:[FFStyle darkGreen]
                            forState:UIControlStateNormal];
        self.PTButton.titleLabel.font = [FFStyle regularFont:17.f];
        [self.contentView addSubview:self.PTButton];
        _AddButton = [[FUIButton alloc] initWithFrame:CGRectMake(267.f,
                                                                 20.f,
                                                                 45.f,
                                                                 40.f)];
        self.AddButton.cornerRadius = 2.f;
        self.AddButton.titleLabel.font = [FFStyle blockFont:17.f];
        self.AddButton.buttonColor = [FFStyle brightGreen];
        [self.AddButton setTitleColor:[FFStyle darkGreyTextColor]
                             forState:UIControlStateNormal];
        [self.AddButton setTitle:NSLocalizedString(@"Add", nil)
                        forState:UIControlStateNormal];
        [self.contentView addSubview:self.AddButton];
    }
    return self;
}

@end
