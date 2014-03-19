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
//@property(nonatomic) UILabel* emptyPosition;
//@property(nonatomic) UILabel* name;
//@property(nonatomic) UILabel* team;
//@property(nonatomic) UILabel* price;
//@property(nonatomic) UIButton* select;
//@property(nonatomic) UIButton* trade;
//@property(nonatomic) UILabel* diff;
//@property(nonatomic) UILabel* points;

//@property(nonatomic) id player;
//@property(nonatomic) FFRoster* roster;
//@property(nonatomic) FFMarket* market;

@end

@implementation FFTeamCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor colorWithWhite:.94
                                                             alpha:1];
        _img = [[UIImageView alloc] initWithFrame:CGRectMake(15, 11, 57, 57)];
        _img.backgroundColor = [UIColor clearColor];
        _img.image = [UIImage imageNamed:@"tshirt-placeholder"];
        _img.contentMode = UIViewContentModeScaleAspectFill;
        _img.clipsToBounds = YES;
        [self.contentView addSubview:_img];

        UIImageView* mask = [[UIImageView alloc] initWithFrame:CGRectMake(15, 11, 57, 57)];
        mask.backgroundColor = [UIColor clearColor];
        mask.image = [UIImage imageNamed:@"playerselectmask"];
        [self addSubview:mask];

//        _team = [[UILabel alloc] initWithFrame:CGRectMake(82, 32, 140, 16)];
//        _team.backgroundColor = [UIColor clearColor];
//        _team.font = [FFStyle regularFont:14];
//        _team.textColor = [FFStyle greyTextColor];
//        [self.contentView addSubview:_team];
//
//        _name = [[UILabel alloc] initWithFrame:CGRectMake(82, 13, 140, 16)];
//        _name.backgroundColor = [UIColor clearColor];
//        _name.font = [FFStyle regularFont:17];
//        _name.textColor = [FFStyle darkGreyTextColor];
//        [self.contentView addSubview:_name];
//
//        _price = [[UILabel alloc] initWithFrame:CGRectMake(82, 50, 80, 16)];
//        _price.backgroundColor = [UIColor clearColor];
//        _price.font = [FFStyle mediumFont:14];
//        _price.textColor = [FFStyle darkGreyTextColor];
//        [self.contentView addSubview:_price];
//
//        _diff = [[UILabel alloc] initWithFrame:CGRectMake(162, 50, 80, 16)];
//        _diff.backgroundColor = [UIColor clearColor];
//        _diff.font = [FFStyle regularFont:14];
//        _diff.textColor = [FFStyle brightGreen];
//        [self.contentView addSubview:_diff];
//
//        _emptyPosition = [[UILabel alloc] initWithFrame:CGRectMake(82, 0, 80, self.frame.size.height)];
//        _emptyPosition.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//        _emptyPosition.backgroundColor = [UIColor clearColor];
//        _emptyPosition.font = [FFStyle regularFont:19];
//        _emptyPosition.textColor = [FFStyle greyTextColor];
//        [self.contentView addSubview:_emptyPosition];
//
//        _select = [FFStyle coloredButtonWithText:NSLocalizedString(@"Select", nil)
//                                           color:[FFStyle brightGreen]
//                                     borderColor:[FFStyle white]];
//        _select.frame = CGRectMake(224, 21, 80, 38);
//        [_select addTarget:self
//                      action:@selector(select:)
//            forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:_select];
//
//        _trade = [FFStyle coloredButtonWithText:NSLocalizedString(@"Trade", nil)
//                                          color:[FFStyle brightRed]
//                                    borderColor:[FFStyle white]];
//        _trade.frame = CGRectMake(224, 21, 80, 38);
//        _trade.hidden = YES;
//        [_trade addTarget:self
//                      action:@selector(replace:)
//            forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:_trade];
//
//        _points = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 20, self.contentView.frame.size.height)];
//        _points.backgroundColor = [UIColor clearColor];
//        _points.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//        _points.font = [FFStyle regularFont:17.f];
//        _points.hidden = YES;
//        [self.contentView addSubview:_points];


        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(82.f, 31.f, 140.f, 16.f)];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [FFStyle regularFont:14.f];
        self.titleLabel.textColor = [FFStyle lightGrey];
        [self.contentView addSubview:self.titleLabel];

        UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(7.f, 78.f, 306.f, 1.f)];
        separator.backgroundColor = [UIColor colorWithWhite:.8f
                                                      alpha:.5f];
        [self.contentView addSubview:separator];

        UIView* separator2 = [[UIView alloc] initWithFrame:CGRectMake(7.f, 79.f, 306.f, 1.f)];
        separator2.backgroundColor = [UIColor colorWithWhite:1.f
                                                       alpha:.5f];
        [self.contentView addSubview:separator2];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

@end
