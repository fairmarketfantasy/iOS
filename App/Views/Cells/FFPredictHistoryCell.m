//
//  FFPredictHistoryCell.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/28/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFPredictHistoryCell.h"
#import "FFStyle.h"

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
        _gameTimeLabel = [[UILabel alloc] initWithFrame:
                          CGRectMake(230.f, 60.f, 70.f, 20.f)];
        self.gameTimeLabel.backgroundColor = [UIColor clearColor];
        self.gameTimeLabel.font = [FFStyle regularFont:12.f];
        self.gameTimeLabel.textColor = [FFStyle darkGreyTextColor];
        [self.contentView addSubview:self.gameTimeLabel];
        _rankLabel = [[UILabel alloc] initWithFrame:
                      CGRectMake(230.f, 90.f, 70.f, 20.f)];
        self.rankLabel.adjustsFontSizeToFitWidth = YES;
        self.rankLabel.backgroundColor = [UIColor clearColor];
        self.rankLabel.font = [FFStyle regularFont:12.f];
        self.rankLabel.textColor = [FFStyle darkGreyTextColor];
        [self.contentView addSubview:self.rankLabel];
        _awardLabel = [[UILabel alloc] initWithFrame:
                       CGRectMake(230.f, 120.f, 70.f, 20.f)];
        self.awardLabel.backgroundColor = [UIColor clearColor];
        self.awardLabel.font = [FFStyle regularFont:12.f];
        self.awardLabel.textColor = [FFStyle darkGreyTextColor];
        [self.contentView addSubview:self.awardLabel];
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
        UILabel* captionGameTimeLabel = [[UILabel alloc] initWithFrame:
                                         CGRectMake(150.f, 60.f, 80.f, 20.f)];
        captionGameTimeLabel.backgroundColor = [UIColor clearColor];
        captionGameTimeLabel.text = NSLocalizedString(@"○ Game Time", nil);
        captionGameTimeLabel.font = [FFStyle regularFont:12.f];
        captionGameTimeLabel.textColor = [FFStyle greyTextColor];
        [self.contentView addSubview:captionGameTimeLabel];
        UILabel* captionRankLabel = [[UILabel alloc] initWithFrame:
                                     CGRectMake(150.f, 90.f, 80.f, 20.f)];
        captionRankLabel.backgroundColor = [UIColor clearColor];
        captionRankLabel.text = NSLocalizedString(@"○ Rank", nil);
        captionRankLabel.font = [FFStyle regularFont:12.f];
        captionRankLabel.textColor = [FFStyle greyTextColor];
        [self.contentView addSubview:captionRankLabel];
        UILabel* captionAwardLabel = [[UILabel alloc] initWithFrame:
                                      CGRectMake(150.f, 120.f, 80.f, 20.f)];
        captionAwardLabel.backgroundColor = [UIColor clearColor];
        captionAwardLabel.text = NSLocalizedString(@"○ Award", nil);
        captionAwardLabel.font = [FFStyle regularFont:12.f];
        captionAwardLabel.textColor = [FFStyle greyTextColor];
        [self.contentView addSubview:captionAwardLabel];
    }
    return self;
}

@end
