//
//  FFPredictRosterTeamCell.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/4/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFPredictRosterTeamCell.h"

@implementation FFPredictRosterTeamCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [FFStyle white];
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(82.f, 14.f, 223.f, 16.f)];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.font = [FFStyle regularFont:14.f];
        self.nameLabel.textColor = [FFStyle darkGreyTextColor];
        self.nameLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.nameLabel];

        _costLabel = [[UILabel alloc] initWithFrame:CGRectMake(82.f, 50.f, 223.f, 16.f)];
        self.costLabel.backgroundColor = [UIColor clearColor];
        self.costLabel.font = [FFStyle boldFont:14.f];
        self.costLabel.textColor = [FFStyle darkGreyTextColor];
        self.costLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.costLabel];
   }
    return self;
}

@end
