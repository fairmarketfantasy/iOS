//
//  FFPredictHistoryCell.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/28/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFPredictHistoryCell.h"

@implementation FFPredictHistoryCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor colorWithWhite:.94f
                                                             alpha:1.f];

        UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(7.f, 158.f, 306.f, 1.f)];
        separator.backgroundColor = [UIColor colorWithWhite:.8f
                                                      alpha:.5f];
        [self.contentView addSubview:separator];

        UIView* separator2 = [[UIView alloc] initWithFrame:CGRectMake(7.f, 159.f, 306.f, 1.f)];
        separator2.backgroundColor = [UIColor colorWithWhite:1.f
                                                       alpha:.5f];
        [self.contentView addSubview:separator2];
        // button
        _rosterButton = [FFStyle coloredButtonWithText:NSLocalizedString(@"Roster", nil)
                                                   color:[FFStyle brightBlue]
                                             borderColor:[UIColor clearColor]];
        self.rosterButton.frame = CGRectMake(205.f, 10.f, 100.f, 30.f);
        self.rosterButton.titleEdgeInsets = UIEdgeInsetsMake(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ?
                                                               3.f : 5.5f,
                                                               0.f, 0.f, 0.f);
        self.rosterButton.titleLabel.font = [FFStyle blockFont:17.f];
        [self.rosterButton setTitleColor:[FFStyle white]
                                  forState:UIControlStateNormal];
        [self.contentView addSubview:self.rosterButton];
        // labels
        _nameLabel = [[UILabel alloc] initWithFrame:
                                              CGRectMake(10.f, 10.f, 190.f, 25.f)];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.font = [FFStyle regularFont:19.f];
        self.nameLabel.textColor = [FFStyle darkGreyTextColor];
        [self.contentView addSubview:self.nameLabel];
        _teamLabel = [[UILabel alloc] initWithFrame:
                                              CGRectMake(10.f, 30.f, 190.f, 25.f)];
        self.teamLabel.backgroundColor = [UIColor clearColor];
        self.teamLabel.font = [FFStyle regularFont:19.f];
        self.teamLabel.textColor = [FFStyle darkGreyTextColor];
        [self.contentView addSubview:self.teamLabel];
        _dayLabel = [[UILabel alloc] initWithFrame:
                                             CGRectMake(70.f, 60.f, 70.f, 20.f)];
        self.dayLabel.backgroundColor = [UIColor clearColor];
        self.dayLabel.font = [FFStyle regularFont:12.f];
        self.dayLabel.textColor = [FFStyle darkGreyTextColor];
        [self.contentView addSubview:self.dayLabel];
        _stateLabel = [[UILabel alloc] initWithFrame:
                                               CGRectMake(70.f, 90.f, 70.f, 20.f)];
        self.stateLabel.backgroundColor = [UIColor clearColor];
        self.stateLabel.font = [FFStyle regularFont:12.f];
        self.stateLabel.textColor = [FFStyle darkGreyTextColor];
        [self.contentView addSubview:self.stateLabel];
        _pointsLabel = [[UILabel alloc] initWithFrame:
                                                CGRectMake(70.f, 120.f, 70.f, 20.f)];
        self.pointsLabel.backgroundColor = [UIColor clearColor];
        self.pointsLabel.font = [FFStyle regularFont:12.f];
        self.pointsLabel.textColor = [FFStyle darkGreyTextColor];
        [self.contentView addSubview:self.pointsLabel];
        _paidLabel = [[UILabel alloc] initWithFrame:
                                              CGRectMake(210.f, 60.f, 90.f, 20.f)];
        self.paidLabel.backgroundColor = [UIColor clearColor];
        self.paidLabel.font = [FFStyle regularFont:12.f];
        self.paidLabel.textColor = [FFStyle darkGreyTextColor];
        [self.contentView addSubview:self.paidLabel];
        _raknLabel = [[UILabel alloc] initWithFrame:
                                              CGRectMake(210.f, 90.f, 90.f, 20.f)];
        self.raknLabel.backgroundColor = [UIColor clearColor];
        self.raknLabel.font = [FFStyle regularFont:12.f];
        self.raknLabel.textColor = [FFStyle darkGreyTextColor];
        [self.contentView addSubview:self.raknLabel];
        _awaidLabel = [[UILabel alloc] initWithFrame:
                                               CGRectMake(210.f, 120.f, 90.f, 20.f)];
        self.awaidLabel.backgroundColor = [UIColor clearColor];
        self.awaidLabel.font = [FFStyle regularFont:12.f];
        self.awaidLabel.textColor = [FFStyle darkGreyTextColor];
        [self.contentView addSubview:self.awaidLabel];
        // titles
        UILabel* captionDayLabel = [[UILabel alloc] initWithFrame:
                                                        CGRectMake(10.f, 60.f, 60.f, 20.f)];
        captionDayLabel.backgroundColor = [UIColor clearColor];
        captionDayLabel.text = NSLocalizedString(@"○ Day", nil);
        captionDayLabel.font = [FFStyle regularFont:12.f];
        captionDayLabel.textColor = [FFStyle greyTextColor];
        [self.contentView addSubview:captionDayLabel];
        UILabel* captionStateLabel = [[UILabel alloc] initWithFrame:
                                                          CGRectMake(10.f, 90.f, 60.f, 20.f)];
        captionStateLabel.backgroundColor = [UIColor clearColor];
        captionStateLabel.text = NSLocalizedString(@"○ State", nil);
        captionStateLabel.font = [FFStyle regularFont:12.f];
        captionStateLabel.textColor = [FFStyle greyTextColor];
        [self.contentView addSubview:captionStateLabel];
        UILabel* captionPointsLabel = [[UILabel alloc] initWithFrame:
                                                           CGRectMake(10.f, 120.f, 60.f, 20.f)];
        captionPointsLabel.backgroundColor = [UIColor clearColor];
        captionPointsLabel.text = NSLocalizedString(@"○ Points", nil);
        captionPointsLabel.font = [FFStyle regularFont:12.f];
        captionPointsLabel.textColor = [FFStyle greyTextColor];
        [self.contentView addSubview:captionPointsLabel];
        UILabel* captionPaidLabel = [[UILabel alloc] initWithFrame:
                                                         CGRectMake(150.f, 60.f, 60.f, 20.f)];
        captionPaidLabel.backgroundColor = [UIColor clearColor];
        captionPaidLabel.text = NSLocalizedString(@"○ Paid", nil);
        captionPaidLabel.font = [FFStyle regularFont:12.f];
        captionPaidLabel.textColor = [FFStyle greyTextColor];
        [self.contentView addSubview:captionPaidLabel];
        UILabel* captionRaknLabel = [[UILabel alloc] initWithFrame:
                                                         CGRectMake(150.f, 90.f, 60.f, 20.f)];
        captionRaknLabel.backgroundColor = [UIColor clearColor];
        captionRaknLabel.text = NSLocalizedString(@"○ Rank", nil);
        captionRaknLabel.font = [FFStyle regularFont:12.f];
        captionRaknLabel.textColor = [FFStyle greyTextColor];
        [self.contentView addSubview:captionRaknLabel];
        UILabel* captionAwaidLabel = [[UILabel alloc] initWithFrame:
                                                          CGRectMake(150.f, 120.f, 60.f, 20.f)];
        captionAwaidLabel.backgroundColor = [UIColor clearColor];
        captionAwaidLabel.text = NSLocalizedString(@"○ Award", nil);
        captionAwaidLabel.font = [FFStyle regularFont:12.f];
        captionAwaidLabel.textColor = [FFStyle greyTextColor];
        [self.contentView addSubview:captionAwaidLabel];
#warning for TESTING only! >>>>>
        self.nameLabel.text = @"Cavaliers@Bobcars";
        self.teamLabel.text = @"27 H2H";
        self.dayLabel.text = @"Sat Mar 08";
        self.stateLabel.text = @"Submitted";
        self.pointsLabel.text = @"N/A";
        self.paidLabel.text = @"N/A";
        self.raknLabel.text = @"Not Started yet";
        self.awaidLabel.text = @"-";
#warning for TESTING only! <<<<<
    }
    return self;
}

@end
