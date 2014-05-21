//
//  FFNonFantasyGameCell.m
//  FMF Football
//
//  Created by Anton Chuev on 5/21/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFNonFantasyGameCell.h"
#import "FFPathImageView.h"
#import "FFStyle.h"
#import "FFNonFantasyGame.h"
#import "FFDate.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface FFNonFantasyGameCell()

@property (nonatomic, strong) FFPathImageView* homeTeamAvatar;
@property (nonatomic, strong) FFPathImageView* awayTeamAvatar;
@property (nonatomic, strong) UILabel *homeTeamName;
@property (nonatomic, strong) UILabel *awayTeamName;
@property (nonatomic, strong) FFCustomButton *homePT;
@property (nonatomic, strong) FFCustomButton *awayPT;
@property (nonatomic, strong) UILabel *datelabel;

@end

@implementation FFNonFantasyGameCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor colorWithWhite:.94f
                                                             alpha:1.f];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        // avatar
        self.homeTeamAvatar = [[FFPathImageView alloc] initWithFrame:CGRectMake(35.f, 10.f, 60.f, 60.f)
                                                               image:[UIImage imageNamed:@"rosterslotempty"]
                                                            pathType:FFPathImageViewTypeCircle
                                                           pathColor:[UIColor clearColor]
                                                         borderColor:[UIColor clearColor]
                                                           pathWidth:0.f];
        self.homeTeamAvatar.contentMode = UIViewContentModeScaleAspectFit;
        self.homeTeamAvatar.pathType = FFPathImageViewTypeCircle;
        self.homeTeamAvatar.pathColor = [FFStyle white];
//        self.homeTeamAvatar.borderColor = self.avatar.pathColor;
        self.homeTeamAvatar.pathWidth = 2.f;
        [self.contentView addSubview:self.homeTeamAvatar];
        [self.homeTeamAvatar draw];
        
        self.awayTeamAvatar = [[FFPathImageView alloc] initWithFrame:CGRectMake(225.f, 10.f, 60.f, 60.f)
                                                               image:[UIImage imageNamed:@"rosterslotempty"]
                                                            pathType:FFPathImageViewTypeCircle
                                                           pathColor:[UIColor clearColor]
                                                         borderColor:[UIColor clearColor]
                                                           pathWidth:0.f];
        self.awayTeamAvatar.contentMode = UIViewContentModeScaleAspectFit;
        self.awayTeamAvatar.pathType = FFPathImageViewTypeCircle;
        self.awayTeamAvatar.pathColor = [FFStyle white];
        //        self.homeTeamAvatar.borderColor = self.avatar.pathColor;
        self.awayTeamAvatar.pathWidth = 2.f;
        [self.contentView addSubview:self.awayTeamAvatar];
        [self.awayTeamAvatar draw];
        
        self.homeTeamName = [[UILabel alloc] initWithFrame:CGRectMake(25.f, 70.f, 80.f, 20.f)];
        self.homeTeamName.textAlignment = NSTextAlignmentCenter;
        self.homeTeamName.backgroundColor = [UIColor clearColor];
        self.homeTeamName.font = [FFStyle regularFont:14.f];
        self.homeTeamName.textColor = [FFStyle darkGreyTextColor];
        self.homeTeamName.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.homeTeamName];
        
        self.awayTeamName = [[UILabel alloc] initWithFrame:CGRectMake(215.f, 70.f, 80.f, 20.f)];
        self.awayTeamName.textAlignment = NSTextAlignmentCenter;
        self.awayTeamName.backgroundColor = [UIColor clearColor];
        self.awayTeamName.font = [FFStyle regularFont:14.f];
        self.awayTeamName.textColor = [FFStyle darkGreyTextColor];
        self.awayTeamName.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.awayTeamName];

        self.homePT = [FFStyle coloredButtonWithText:NSLocalizedString(@"PT", nil)
                                               color:self.contentView.backgroundColor
                                         borderColor:[FFStyle brightBlue]];
        self.homePT.frame = CGRectMake(120.f, 30.f, 40.f, 40.f);
        self.homePT.layer.borderWidth = 2.f;
        self.homePT.userInteractionEnabled = NO;
        [self.homePT setTitleColor:[FFStyle brightBlue]
                          forState:UIControlStateNormal];
        self.homePT.titleLabel.font = [FFStyle blockFont:17.f];
        self.homePT.titleEdgeInsets = UIEdgeInsetsMake(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ?
                                                       3.f : 5.5f,
                                                       0.f, 0.f, 0.f);
        [self.contentView addSubview:self.homePT];
        
        self.awayPT = [FFStyle coloredButtonWithText:NSLocalizedString(@"PT", nil)
                                               color:self.contentView.backgroundColor
                                         borderColor:[FFStyle brightBlue]];
        self.awayPT.frame = CGRectMake(160.f, 30.f, 40.f, 40.f);
        self.awayPT.layer.borderWidth = 2.f;
        self.awayPT.userInteractionEnabled = NO;
        [self.awayPT setTitleColor:[FFStyle brightBlue]
                          forState:UIControlStateNormal];
        self.awayPT.titleLabel.font = [FFStyle blockFont:17.f];
        self.awayPT.titleEdgeInsets = UIEdgeInsetsMake(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ?
                                                       3.f : 5.5f,
                                                       0.f, 0.f, 0.f);
        [self.contentView addSubview:self.awayPT];

        self.datelabel = [[UILabel alloc] initWithFrame:CGRectMake(120.f, 70.f, 80.f, 20.f)];
        self.datelabel.textAlignment = NSTextAlignmentCenter;
        self.datelabel.backgroundColor = [UIColor clearColor];
        self.datelabel.font = [FFStyle regularFont:14.f];
        self.datelabel.textColor = [FFStyle lightGrey];
        self.datelabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.datelabel];
        
        // separator
        UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(7.f, 98.f, 306.f, 1.f)];
        separator.backgroundColor = [UIColor colorWithWhite:.8f
                                                      alpha:.5f];
        [self.contentView addSubview:separator];
        // separator 2
        UIView* separator2 = [[UIView alloc] initWithFrame:CGRectMake(7.f, 99.f, 306.f, 1.f)];
        separator2.backgroundColor = [UIColor colorWithWhite:1.f
                                                       alpha:.5f];
        [self.contentView addSubview:separator2];
    }
    return self;
}

- (void)setupWithGame:(FFNonFantasyGame *)game
{
    [self.homeTeamAvatar setImageWithURL:[NSURL URLWithString:game.homeTeamLogoURL]
                        placeholderImage:[UIImage imageNamed:@"rosterslotempty"]
             usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    [self.homeTeamAvatar draw];
    
    [self.awayTeamAvatar setImageWithURL:[NSURL URLWithString:game.awayTeamLogoURL]
                        placeholderImage:[UIImage imageNamed:@"rosterslotempty"]
             usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    [self.awayTeamAvatar draw];
    
    self.homeTeamName.text = game.homeTeamName;
    self.awayTeamName.text = game.awayTeamName;
    self.datelabel.text = [[FFDate prettyDateFormatter] stringFromDate:game.gameTime];
}

@end
