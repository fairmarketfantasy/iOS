//
//  FFNonFantasyTeamCell.m
//  FMF Football
//
//  Created by Anton Chuev on 5/21/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFNonFantasyTeamCell.h"
#import "FFPathImageView.h"

@implementation FFNonFantasyTeamCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor colorWithWhite:.94f
                                                             alpha:1.f];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        // avatar
        _avatar = [[FFPathImageView alloc] initWithFrame:CGRectMake(15.f, 10.f, 60.f, 60.f)
                                                   image:[UIImage imageNamed:@"empty-team"]
                                                pathType:FFPathImageViewTypeCircle
                                               pathColor:[UIColor clearColor]
                                             borderColor:[UIColor clearColor]
                                               pathWidth:0.f];
        
        self.avatar.contentMode = UIViewContentModeScaleAspectFit;
        self.avatar.pathType = FFPathImageViewTypeCircle;
        self.avatar.pathColor = [FFStyle white];
        self.avatar.borderColor = self.avatar.pathColor;
        self.avatar.pathWidth = 2.f;
        [self.contentView addSubview:self.avatar];
        [self.avatar draw];

        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(82.f, 31.f, 223.f, 16.f)];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [FFStyle regularFont:14.f];
        self.titleLabel.textColor = [FFStyle lightGrey];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.titleLabel];
        // separator
        UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(7.f, 78.f, 306.f, 1.f)];
        separator.backgroundColor = [UIColor colorWithWhite:.8f
                                                      alpha:.5f];
        [self.contentView addSubview:separator];
        // separator 2
        UIView* separator2 = [[UIView alloc] initWithFrame:CGRectMake(7.f, 79.f, 306.f, 1.f)];
        separator2.backgroundColor = [UIColor colorWithWhite:1.f
                                                       alpha:.5f];
        [self.contentView addSubview:separator2];
    }
    return self;
}

@end
