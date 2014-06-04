//
//  FFWCGameCell.m
//  FMF Football
//
//  Created by Anton on 6/1/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFWCGameCell.h"
#import "FFPathImageView.h"
#import "FFWCGame.h"
#import "FFWCTeam.h"
#import "FFDate.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface FFWCGameCell()

@property (nonatomic, strong) FFPathImageView* homeTeamFlag;
@property (nonatomic, strong) FFPathImageView* guestTeamFlag;
@property (nonatomic, strong) UILabel *homeTeamName;
@property (nonatomic, strong) UILabel *guestTeamName;
@property (nonatomic, strong) UILabel *datelabel;

@property (nonatomic, strong) UIImageView *ptBackground;

@end

@implementation FFWCGameCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor colorWithWhite:.94f
                                                             alpha:1.f];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // avatars
        self.homeTeamFlag = [[FFPathImageView alloc] initWithFrame:CGRectMake(35.f, 10.f, 60.f, 60.f)
                                                               image:[UIImage imageNamed:@"flag_placeholder.jpg"]
                                                            pathType:FFPathImageViewTypeSquare
                                                           pathColor:[UIColor clearColor]
                                                         borderColor:[UIColor clearColor]
                                                           pathWidth:0.f];
        self.homeTeamFlag.contentMode = UIViewContentModeScaleAspectFit;
        self.homeTeamFlag.pathType = FFPathImageViewTypeSquare;
        self.homeTeamFlag.pathColor = [UIColor clearColor];
        [self.contentView addSubview:self.homeTeamFlag];
        [self.homeTeamFlag draw];
        
        self.guestTeamFlag = [[FFPathImageView alloc] initWithFrame:CGRectMake(225.f, 10.f, 60.f, 60.f)
                                                               image:[UIImage imageNamed:@"flag_placeholder.jpg"]
                                                            pathType:FFPathImageViewTypeSquare
                                                           pathColor:[UIColor clearColor]
                                                         borderColor:[UIColor clearColor]
                                                           pathWidth:0.f];
        self.guestTeamFlag.contentMode = UIViewContentModeScaleAspectFit;
        self.guestTeamFlag.pathType = FFPathImageViewTypeSquare;
        self.guestTeamFlag.pathColor = [UIColor clearColor];
        [self.contentView addSubview:self.guestTeamFlag];
        [self.guestTeamFlag draw];
        
        // teams' names
        self.homeTeamName = [[UILabel alloc] initWithFrame:CGRectMake(25.f, 70.f, 80.f, 20.f)];
        self.homeTeamName.textAlignment = NSTextAlignmentCenter;
        self.homeTeamName.backgroundColor = [UIColor clearColor];
        self.homeTeamName.font = [FFStyle regularFont:14.f];
        self.homeTeamName.textColor = [FFStyle darkGreyTextColor];
        self.homeTeamName.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.homeTeamName];
        
        self.guestTeamName = [[UILabel alloc] initWithFrame:CGRectMake(215.f, 70.f, 80.f, 20.f)];
        self.guestTeamName.textAlignment = NSTextAlignmentCenter;
        self.guestTeamName.backgroundColor = [UIColor clearColor];
        self.guestTeamName.font = [FFStyle regularFont:14.f];
        self.guestTeamName.textColor = [FFStyle darkGreyTextColor];
        self.guestTeamName.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.guestTeamName];
        
        // date
        self.datelabel = [[UILabel alloc] initWithFrame:CGRectMake(120.f, 70.f, 80.f, 20.f)];
        self.datelabel.textAlignment = NSTextAlignmentCenter;
        self.datelabel.backgroundColor = [UIColor clearColor];
        self.datelabel.font = [FFStyle regularFont:14.f];
        self.datelabel.textColor = [FFStyle lightGrey];
        self.datelabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.datelabel];
        
        // pt background
        self.ptBackground = [[UIImageView alloc] initWithFrame:CGRectMake(115.f, 22.f, 89.f, 36.f)];
        [self.contentView addSubview:self.ptBackground];
        
        // pt buttons
        _homePTButton = [FFCustomButton buttonWithType:UIButtonTypeCustom];
        self.homePTButton.frame = CGRectMake(120.f, 28.f, 35.f, 25.f);
        self.homePTButton.backgroundColor = [UIColor clearColor];
        self.homePTButton.titleLabel.font = [FFStyle blockFont:17.f];
        [self.contentView addSubview:self.homePTButton];
        
        _guestPTButton = [FFCustomButton buttonWithType:UIButtonTypeCustom];
        self.guestPTButton.frame = CGRectMake(165.f, 28.f, 35.f, 25.f);
        self.guestPTButton.backgroundColor = [UIColor clearColor];
        self.guestPTButton.titleLabel.font = [FFStyle blockFont:17.f];
        [self.contentView addSubview:self.guestPTButton];
        
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

- (void)setupWithGame:(FFWCGame *)game
{
    self.homeTeamName.text = game.homeTeam.name;
    self.guestTeamName.text = game.guestTeam.name;
    
    [self.homeTeamFlag setImageWithURL:[NSURL URLWithString:game.homeTeam.flagURL]
                        placeholderImage:[UIImage imageNamed:@"flag_placeholder.jpg"]
             usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.homeTeamFlag draw];
    
    [self.guestTeamFlag setImageWithURL:[NSURL URLWithString:game.guestTeam.flagURL]
                      placeholderImage:[UIImage imageNamed:@"flag_placeholder.jpg"]
           usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.guestTeamFlag draw];
    
    NSString *imageName = nil;
    if (game.homeTeam.disablePT && game.guestTeam.disablePT) {
        imageName = @"pt_disable_both";
    } else if (!game.homeTeam.disablePT && game.guestTeam.disablePT) {
        imageName = @"pt_disable_right";
    } else if (game.homeTeam.disablePT && !game.guestTeam.disablePT) {
        imageName = @"pt_disable_left";
    } else {
        imageName = @"pt_enable_both";
    }
    self.ptBackground.image = [UIImage imageNamed:imageName];
    
    UIColor *homePTColor = game.homeTeam.disablePT ? [FFStyle lightGrey] : [FFStyle brightBlue];
    UIColor *guestPTColor = game.guestTeam.disablePT ? [FFStyle lightGrey] : [FFStyle brightBlue];
    [self.homePTButton setTitleColor:homePTColor forState:UIControlStateNormal];
    [self.guestPTButton setTitleColor:guestPTColor forState:UIControlStateNormal];
    
    [self.homePTButton setTitle:[NSString stringWithFormat:@"%@%i", @"PT", game.homeTeam.pt]
                       forState:UIControlStateNormal];
    [self.guestPTButton setTitle:[NSString stringWithFormat:@"%@%i", @"PT", game.guestTeam.pt]
                        forState:UIControlStateNormal];
    
    self.homePTButton.enabled = !game.homeTeam.disablePT;
    self.guestPTButton.enabled = !game.guestTeam.disablePT;
    
    self.datelabel.text = [[FFDate prettyDateFormatter] stringFromDate:game.date];
}

@end
