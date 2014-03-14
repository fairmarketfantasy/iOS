//
//  FFTeamCell.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/14/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFTeamCell.h"

@interface FFTeamCell ()

@property(nonatomic) UIImageView* img;
@property(nonatomic) UILabel* emptyPosition;
@property(nonatomic) UILabel* name;
@property(nonatomic) UILabel* team;
@property(nonatomic) UILabel* price;
@property(nonatomic) UIButton* select;
@property(nonatomic) UIButton* trade;
@property(nonatomic) UILabel* diff;
@property(nonatomic) UILabel* points;

//@property(nonatomic) id player;
//@property(nonatomic) FFRoster* roster;
//@property(nonatomic) FFMarket* market;

@end

@implementation FFTeamCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor colorWithWhite:.94
                                                             alpha:1];
        _img = [[UIImageView alloc] initWithFrame:CGRectMake(15, 11, 57, 57)];
        _img.backgroundColor = [UIColor clearColor];
        _img.image = [UIImage imageNamed:@"rosterslotempty.png"];
        _img.contentMode = UIViewContentModeScaleAspectFill;
        _img.clipsToBounds = YES;
        [self.contentView addSubview:_img];

        UIImageView* mask = [[UIImageView alloc] initWithFrame:CGRectMake(15, 11, 57, 57)];
        mask.backgroundColor = [UIColor clearColor];
        mask.image = [UIImage imageNamed:@"playerselectmask.png"];
        [self addSubview:mask];

        _team = [[UILabel alloc] initWithFrame:CGRectMake(82, 32, 140, 16)];
        _team.backgroundColor = [UIColor clearColor];
        _team.font = [FFStyle regularFont:14];
        _team.textColor = [FFStyle greyTextColor];
        [self.contentView addSubview:_team];

        _name = [[UILabel alloc] initWithFrame:CGRectMake(82, 13, 140, 16)];
        _name.backgroundColor = [UIColor clearColor];
        _name.font = [FFStyle regularFont:17];
        _name.textColor = [FFStyle darkGreyTextColor];
        [self.contentView addSubview:_name];

        _price = [[UILabel alloc] initWithFrame:CGRectMake(82, 50, 80, 16)];
        _price.backgroundColor = [UIColor clearColor];
        _price.font = [FFStyle mediumFont:14];
        _price.textColor = [FFStyle darkGreyTextColor];
        [self.contentView addSubview:_price];

        _diff = [[UILabel alloc] initWithFrame:CGRectMake(162, 50, 80, 16)];
        _diff.backgroundColor = [UIColor clearColor];
        _diff.font = [FFStyle regularFont:14];
        _diff.textColor = [FFStyle brightGreen];
        [self.contentView addSubview:_diff];

        _emptyPosition = [[UILabel alloc] initWithFrame:CGRectMake(82, 0, 80, self.frame.size.height)];
        _emptyPosition.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _emptyPosition.backgroundColor = [UIColor clearColor];
        _emptyPosition.font = [FFStyle regularFont:19];
        _emptyPosition.textColor = [FFStyle greyTextColor];
        [self.contentView addSubview:_emptyPosition];

        _select = [FFStyle coloredButtonWithText:NSLocalizedString(@"Select", nil)
                                           color:[FFStyle brightGreen]
                                     borderColor:[FFStyle white]];
        _select.frame = CGRectMake(224, 21, 80, 38);
        [_select addTarget:self
                      action:@selector(select:)
            forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_select];

        _trade = [FFStyle coloredButtonWithText:NSLocalizedString(@"Trade", nil)
                                          color:[FFStyle brightRed]
                                    borderColor:[FFStyle white]];
        _trade.frame = CGRectMake(224, 21, 80, 38);
        _trade.hidden = YES;
        [_trade addTarget:self
                      action:@selector(replace:)
            forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_trade];

        _points = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 20, self.contentView.frame.size.height)];
        _points.backgroundColor = [UIColor clearColor];
        _points.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _points.font = [FFStyle regularFont:17.f];
        _points.hidden = YES;
        [self.contentView addSubview:_points];

        UIView* sep = [[UIView alloc] initWithFrame:CGRectMake(7, 78, 306, 1)];
        sep.backgroundColor = [UIColor colorWithWhite:.8
                                                alpha:.5];
        [self.contentView addSubview:sep];

        sep = [[UIView alloc] initWithFrame:CGRectMake(7, 79, 306, 1)];
        sep.backgroundColor = [UIColor colorWithWhite:1
                                                alpha:.5];
        [self.contentView addSubview:sep];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

@end
