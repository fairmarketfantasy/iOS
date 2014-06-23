//
//  FFTeamTradeCell.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/19/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFTeamTradeCell.h"

@implementation FFTeamTradeCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        // title label
        CGRect titleRect = self.titleLabel.frame;
        titleRect.size.width = 125.f;
        self.titleLabel.frame = titleRect;
        // name label
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(82.f, 14.f, 125.f, 16.f)];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.font = [FFStyle regularFont:14.f];
        self.nameLabel.textColor = [FFStyle darkGreyTextColor];
        self.nameLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.nameLabel];
        // cost label
        _costLabel = [[UILabel alloc] initWithFrame:CGRectMake(82.f, 50.f, 70.f, 16.f)];
        self.costLabel.backgroundColor = [UIColor clearColor];
        self.costLabel.font = [FFStyle boldFont:14.f];
        self.costLabel.textColor = [FFStyle darkGreyTextColor];
        self.costLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.costLabel];
        // cent label
        _centLabel = [[UILabel alloc] initWithFrame:CGRectMake(155.f, 50.f, 50.f, 16.f)];
        self.centLabel.backgroundColor = [UIColor clearColor];
        self.centLabel.font = [FFStyle boldFont:14.f];
        self.centLabel.textColor = [FFStyle brightBlue];
        self.centLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.centLabel];
        // pt button
        _PTButton = [FFStyle coloredButtonWithText:@"PT"
                                             color:self.contentView.backgroundColor
                                       borderColor:[FFStyle brightBlue]];
        self.PTButton.frame = CGRectMake(207.f,
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
        // trade button
        _tradeButton = [FFStyle coloredButtonWithText:@"Trade"
                                              color:[FFStyle brightOrange]
                                        borderColor:[FFStyle white]];
        self.tradeButton.frame = CGRectMake(252.f,
                                            20.f,
                                            50.f,
                                            40.f);
        self.tradeButton.titleLabel.font = [FFStyle blockFont:17.f];
        [self.tradeButton setTitleColor:[FFStyle black]
                             forState:UIControlStateNormal];
        self.tradeButton.titleEdgeInsets = UIEdgeInsetsMake(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ?
                                                            3.f : 5.5f,
                                                            0.f, 0.f, 0.f);
        [self.contentView addSubview:self.tradeButton];
    }
    return self;
}

@end
