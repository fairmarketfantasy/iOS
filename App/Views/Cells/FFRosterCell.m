//
//  FFRosterCell.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/6/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFRosterCell.h"
#import "FFRoster.h"

@interface FFRosterCell ()

@property(nonatomic) UILabel* nameLabel;
@property(nonatomic) UIImageView* statusView;
@property(nonatomic) UILabel* entryLabel;
@property(nonatomic) UILabel* rankCaptionLabel;
@property(nonatomic) UILabel* rankLabel;
@property(nonatomic) UILabel* scoreLabel;

- (UIImage*)imageForCurrentState;

@end

@implementation FFRosterCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView* disclosure = [[UIImageView alloc] initWithFrame:CGRectMake(295.f, 22.5f, 10.f, 15.f)];
        disclosure.image = [UIImage imageNamed:@"accessory_disclosure"];
        disclosure.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:disclosure];

        UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(15.f, CGRectGetMaxY(self.contentView.frame),
                                                                     290.f, 1.f)];
        separator.backgroundColor = [FFStyle tableViewSeparatorColor];
        separator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self.contentView addSubview:separator];

        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.f, 0.f, 320.f, 36.f)]; // !!!: check width
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.font = [FFStyle mediumFont:19.f];
        [self.contentView addSubview:self.nameLabel];

        self.statusView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, 10.f, 10.f)];
        self.statusView.center = CGPointMake(CGRectGetMaxX(self.nameLabel.frame) + 10.f,
                                             CGRectGetMidY(self.nameLabel.frame));
        self.statusView.backgroundColor = [UIColor clearColor];
        self.statusView.hidden = YES;
        [self.contentView addSubview:self.statusView];

        self.entryLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.f, 32.f, 170.f, 20.f)];
        self.entryLabel.backgroundColor = [UIColor clearColor];
        self.entryLabel.font = [FFStyle regularFont:14.f];
        self.entryLabel.textColor = [FFStyle greyTextColor];
        [self.contentView addSubview:self.entryLabel];

        self.rankCaptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(165.f, 5.f, 50.f, 30.f)];
        self.rankCaptionLabel.backgroundColor = [UIColor clearColor];
        self.rankCaptionLabel.font = [FFStyle regularFont:14.f];
        self.rankCaptionLabel.textColor = [FFStyle darkerColorForColor:[FFStyle lightGrey]];
        self.rankCaptionLabel.text = NSLocalizedString(@"Rank:", nil);
        [self.contentView addSubview:self.rankCaptionLabel];

        UILabel* scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(165.f, 32.f, 50.f, 20.f)];
        scoreLabel.backgroundColor = [UIColor clearColor];
        scoreLabel.font = [FFStyle regularFont:14.f];
        scoreLabel.text = NSLocalizedString(@"Score:", nil);
        scoreLabel.textColor = [FFStyle darkerColorForColor:[FFStyle lightGrey]];
        [self.contentView addSubview:scoreLabel];

        self.rankLabel = [[UILabel alloc] initWithFrame:CGRectMake(210.f, 5.f, 65.f, 30.f)];
        self.rankLabel.backgroundColor = [UIColor clearColor];
        self.rankLabel.font = [FFStyle mediumFont:14.f];
        self.rankLabel.textColor = [FFStyle darkGreyTextColor];
        [self.contentView addSubview:self.rankLabel];

        self.scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(210.f, 32.f, 65.f, 20.f)];
        self.scoreLabel.backgroundColor = [UIColor clearColor];
        self.scoreLabel.font = [FFStyle mediumFont:14.f];
        self.scoreLabel.textColor = [FFStyle darkGreyTextColor];
        [self.contentView addSubview:self.scoreLabel];
    }
    return self;
}

- (UIImage*)imageForCurrentState
{
    return [UIImage imageNamed:
  @{
    @"in_progress" : @"greydot.png",
    @"submitted" : @"greendot.png",
    @"finished" : @"bluedot.png"
    }[self.roster.state]];
}

- (void)setRoster:(FFRoster*)roster
{
    if (self.roster == roster) {
        return;
    }
    self->_roster = roster;
    [self updateContent];
}

- (void)updateContent
{
    FFContestType* contentType = self.roster.contestType;

    self.nameLabel.text = contentType.name;

    self.statusView.image = [self imageForCurrentState];
    self.statusView.hidden = self.statusView.image != nil;

    self.entryLabel.text = [NSString stringWithFormat:@"%@ %@  %@ %@",
                                                      NSLocalizedString(@"Entry:", nil),
                                                      contentType.buyIn,
                                                      NSLocalizedString(@"Payout:", nil),
                                                      self.roster.amountPaid ? self.roster.amountPaid : @"0"];
    self.rankLabel.text = [NSString stringWithFormat:@"%@ %@ %@",
                                                     self.roster.contestRank ? self.roster.contestRank : @"0",
                                                     NSLocalizedString(@"of", nil),
                                                     contentType.maxEntries ? contentType.maxEntries : @"0"];
    self.scoreLabel.text = [NSString stringWithFormat:@"%@",
                                                      self.roster.score ? self.roster.score : @"0"];
}

@end
