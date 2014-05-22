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
#import "FFTeam.h"
#import "FFDate.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface FFNonFantasyGameCell()

@property (nonatomic, strong) FFPathImageView* homeTeamAvatar;
@property (nonatomic, strong) FFPathImageView* awayTeamAvatar;
@property (nonatomic, strong) UILabel *homeTeamName;
@property (nonatomic, strong) UILabel *awayTeamName;
@property (nonatomic, strong) UILabel *datelabel;
@property (nonatomic, strong) UILabel *homePTLabel;
@property (nonatomic, strong) UILabel *awayPTLabel;

@property (nonatomic, strong) UIImageView *homePlusView;
@property (nonatomic, strong) UIImageView *awayPlusView;

@end

@implementation FFNonFantasyGameCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor colorWithWhite:.94f
                                                             alpha:1.f];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // avatars
        self.homeTeamAvatar = [[FFPathImageView alloc] initWithFrame:CGRectMake(35.f, 10.f, 60.f, 60.f)
                                                               image:[UIImage imageNamed:@"rosterslotempty"]
                                                            pathType:FFPathImageViewTypeCircle
                                                           pathColor:[UIColor clearColor]
                                                         borderColor:[UIColor clearColor]
                                                           pathWidth:0.f];
        self.homeTeamAvatar.contentMode = UIViewContentModeScaleAspectFit;
        self.homeTeamAvatar.pathType = FFPathImageViewTypeCircle;
        self.homeTeamAvatar.pathColor = [FFStyle white];
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
        self.awayTeamAvatar.pathWidth = 2.f;
        [self.contentView addSubview:self.awayTeamAvatar];
        [self.awayTeamAvatar draw];
        
        // buttons
        _addHomeTeamBtn = [FFCustomButton buttonWithType:UIButtonTypeCustom];
        _addHomeTeamBtn.frame = CGRectMake(0.f, 0.f, 40.f, 100.f);
        _addHomeTeamBtn.backgroundColor = [UIColor clearColor];
        
        self.homePlusView = [[UIImageView alloc] initWithFrame:CGRectMake(10.f, 42.5f, 15.f, 15.f)];
        self.homePlusView.image = [UIImage imageNamed:@"plus-btn"];
        [_addHomeTeamBtn addSubview:self.homePlusView];
        [self.contentView addSubview:_addHomeTeamBtn];
        
        _addAwayTeamBtn = [FFCustomButton buttonWithType:UIButtonTypeCustom];
        _addAwayTeamBtn.frame = CGRectMake(280.f, 0.f, 40.f, 100.f);
        _addAwayTeamBtn.backgroundColor = [UIColor clearColor];
        
        self.awayPlusView = [[UIImageView alloc] initWithFrame:CGRectMake(15.f, 42.5f, 15.f, 15.f)];
        self.awayPlusView.image = [UIImage imageNamed:@"plus-btn"];
        [_addAwayTeamBtn addSubview:self.awayPlusView];
        [self.contentView addSubview:_addAwayTeamBtn];
        
        // teams' names
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

        // date
        self.datelabel = [[UILabel alloc] initWithFrame:CGRectMake(120.f, 70.f, 80.f, 20.f)];
        self.datelabel.textAlignment = NSTextAlignmentCenter;
        self.datelabel.backgroundColor = [UIColor clearColor];
        self.datelabel.font = [FFStyle regularFont:14.f];
        self.datelabel.textColor = [FFStyle lightGrey];
        self.datelabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.datelabel];
        
        // pt background
        UIImageView *ptBackground = [[UIImageView alloc] initWithFrame:CGRectMake(115.f, 20.f, 89.f, 36.f)];
        ptBackground.image = [UIImage imageNamed:@"pt-nonfantasy"];
        [self.contentView addSubview:ptBackground];
        
        // pt labels
        self.homePTLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.f, 25.f, 35.f, 25.f)];
        self.homePTLabel.textAlignment = NSTextAlignmentCenter;
        self.homePTLabel.backgroundColor = [UIColor clearColor];
        self.homePTLabel.font = [FFStyle blockFont:17.f];
        self.homePTLabel.textColor = [FFStyle brightBlue];
        self.homePTLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.homePTLabel];
        
        self.awayPTLabel = [[UILabel alloc] initWithFrame:CGRectMake(166.f, 25.f, 35.f, 25.f)];
        self.awayPTLabel.textAlignment = NSTextAlignmentCenter;
        self.awayPTLabel.backgroundColor = [UIColor clearColor];
        self.awayPTLabel.font = [FFStyle blockFont:17.f];
        self.awayPTLabel.textColor = [FFStyle brightBlue];
        self.awayPTLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.awayPTLabel];

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
    
    self.homePTLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"PT", nil), game.homeTeamPT];
    self.awayPTLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"PT", nil), game.awayTeamPT];
    
    self.homeTeamName.text = game.homeTeamName;
    self.awayTeamName.text = game.awayTeamName;
    self.datelabel.text = [[FFDate prettyDateFormatter] stringFromDate:game.gameTime];
    
    self.addAwayTeamBtn.enabled = !game.awayTeam.selected;
    self.addHomeTeamBtn.enabled = !game.homeTeam.selected;
    
    self.awayPlusView.image = game.awayTeam.selected ? [UIImage imageNamed:@"backbtn"] : [UIImage imageNamed:@"plus-btn"];
    self.homePlusView.image = game.homeTeam.selected ? [UIImage imageNamed:@"backbtn"] : [UIImage imageNamed:@"plus-btn"];
}

@end

