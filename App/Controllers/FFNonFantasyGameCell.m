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

@property (nonatomic, strong) UIImageView *homePlusView;
@property (nonatomic, strong) UIImageView *awayPlusView;

@property (nonatomic, strong) UIImageView *ptBackground;

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
        self.ptBackground = [[UIImageView alloc] initWithFrame:CGRectMake(115.f, 20.f, 89.f, 36.f)];
        [self.contentView addSubview:self.ptBackground];
        
        // pt buttons
        _homePTButton = [FFCustomButton buttonWithType:UIButtonTypeCustom];
        self.homePTButton.frame = CGRectMake(120.f, 25.f, 35.f, 25.f);
        self.homePTButton.backgroundColor = [UIColor clearColor];
        self.homePTButton.titleLabel.font = [FFStyle blockFont:17.f];
        [self.contentView addSubview:self.homePTButton];
        
        _awayPTButton = [FFCustomButton buttonWithType:UIButtonTypeCustom];
        self.awayPTButton.frame = CGRectMake(166.f, 25.f, 35.f, 25.f);
        self.awayPTButton.backgroundColor = [UIColor clearColor];
        self.awayPTButton.titleLabel.font = [FFStyle blockFont:17.f];
        [self.contentView addSubview:self.awayPTButton];

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
    
    NSString *imageName = nil;
    if ([game.homeTeamDisablePt boolValue] && [game.awayTeamDisablePt boolValue]) {
        imageName = @"pt_disable_both";
    } else if (![game.homeTeamDisablePt boolValue] && [game.awayTeamDisablePt boolValue]) {
        imageName = @"pt_disable_right";
    } else if ([game.homeTeamDisablePt boolValue] && ![game.awayTeamDisablePt boolValue]) {
        imageName = @"pt_disable_left";
    } else {
        imageName = @"pt_enable_both";
    }
    self.ptBackground.image = [UIImage imageNamed:imageName];
    
    self.homePTButton.enabled = ![game.homeTeamDisablePt boolValue];
    self.awayPTButton.enabled = ![game.awayTeamDisablePt boolValue];
    
    UIColor *homePTColor = [game.homeTeamDisablePt boolValue] ? [FFStyle lightGrey] : [FFStyle brightBlue];
    UIColor *awayPTColor = [game.awayTeamDisablePt boolValue] ? [FFStyle lightGrey] : [FFStyle brightBlue];
    [self.homePTButton setTitleColor:homePTColor forState:UIControlStateNormal];
    [self.awayPTButton setTitleColor:awayPTColor forState:UIControlStateNormal];
    
    [self.homePTButton setTitle:[NSString stringWithFormat:@"%@%i", @"PT", [game.homeTeamPT integerValue]]
                       forState:UIControlStateNormal];
    [self.awayPTButton setTitle:[NSString stringWithFormat:@"%@%i", @"PT", [game.awayTeamPT integerValue]]
                       forState:UIControlStateNormal];
    
    self.homeTeamName.text = game.homeTeamName;
    self.awayTeamName.text = game.awayTeamName;
    self.datelabel.text = [[FFDate prettyDateFormatter] stringFromDate:game.gameTime];
    
    self.addAwayTeamBtn.enabled = !game.awayTeam.selected;
    self.addHomeTeamBtn.enabled = !game.homeTeam.selected;
    self.awayPlusView.image = game.awayTeam.selected ? [UIImage imageNamed:@"plus-btn-disable"] : [UIImage imageNamed:@"plus-btn"];
    self.homePlusView.image = game.homeTeam.selected ? [UIImage imageNamed:@"plus-btn-disable"] : [UIImage imageNamed:@"plus-btn"];
}

@end

