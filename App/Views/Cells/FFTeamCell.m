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
        _img.image = [UIImage imageNamed:@"rosterslotempty"];
        _img.contentMode = UIViewContentModeScaleAspectFill;
        _img.clipsToBounds = YES;
        [self.contentView addSubview:_img];

        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(82.f, 31.f, 140.f, 16.f)];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [FFStyle regularFont:14.f];
        self.titleLabel.textColor = [FFStyle greyTextColor];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
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
