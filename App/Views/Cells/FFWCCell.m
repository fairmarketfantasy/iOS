//
//  FFWCCell.m
//  FMF Football
//
//  Created by Anton on 6/1/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFWCCell.h"
#import "FFPathImageView.h"
#import "FFWCTeam.h"
#import "FFWCPlayer.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface FFWCCell()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) FFPathImageView *flag;

@end

@implementation FFWCCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor colorWithWhite:.94f
                                                             alpha:1.f];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // flag
        _flag = [[FFPathImageView alloc] initWithFrame:CGRectMake(15.f, 10.f, 60.f, 60.f)
                                                 image:[UIImage imageNamed:@"flag_placeholder.jpg"]
                                              pathType:FFPathImageViewTypeSquare
                                             pathColor:[UIColor clearColor]
                                           borderColor:[UIColor clearColor]
                                             pathWidth:0.f];
        
        self.flag.contentMode = UIViewContentModeScaleAspectFit;
        self.flag.pathType = FFPathImageViewTypeSquare;
        self.flag.pathColor = [UIColor clearColor];
        self.flag.borderColor = [UIColor clearColor];
        [self.contentView addSubview:self.flag];
        [self.flag draw];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(82.f, 31.f, 223.f, 16.f)];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [FFStyle regularFont:14.f];
        self.titleLabel.textColor = [FFStyle greyTextColor];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.titleLabel];
        
        // pt button
        _PTButton = [FFStyle coloredButtonWithText:@"PT"
                                             color:self.contentView.backgroundColor
                                       borderColor:[FFStyle brightBlue]];
        self.PTButton.frame = CGRectMake(237.f,
                                         20.f,
                                         60.f,
                                         40.f);
        self.PTButton.layer.borderWidth = 2.f;
        [self.PTButton setTitleColor:[FFStyle brightBlue]
                            forState:UIControlStateNormal];
        self.PTButton.titleLabel.font = [FFStyle blockFont:17.f];
        self.PTButton.titleEdgeInsets = UIEdgeInsetsMake(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ?
                                                         3.f : 5.5f,
                                                         0.f, 0.f, 0.f);
        [self.contentView addSubview:self.PTButton];
        
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

- (void)setupWithTeam:(FFWCTeam *)team
{
    self.titleLabel.text = team.name;
    
    self.PTButton.enabled = !team.disablePT;
    
    UIColor *color = team.disablePT ? [FFStyle lightGrey] : [FFStyle brightBlue];
    [self.PTButton setTitleColor:color forState:UIControlStateNormal];
    self.PTButton.layer.borderColor = color.CGColor;
    
    [self.flag setImageWithURL:[NSURL URLWithString:team.flagURL]
              placeholderImage:[UIImage imageNamed:@"flag_placeholder.jpg"]
   usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.flag draw];
    
    [self.PTButton setTitle:[NSString stringWithFormat:@"%@%i", @"PT", team.pt]
                   forState:UIControlStateNormal];
}

- (void)setupWithPlayer:(FFWCPlayer *)player
{
    self.titleLabel.text = player.name;
    
    self.PTButton.enabled = !player.disablePT;
    
    UIColor *color = player.disablePT ? [FFStyle lightGrey] : [FFStyle brightBlue];
    [self.PTButton setTitleColor:color forState:UIControlStateNormal];
    self.PTButton.layer.borderColor = color.CGColor;
    
    [self.flag setImageWithURL:[NSURL URLWithString:player.flagURL]
              placeholderImage:[UIImage imageNamed:@"flag_placeholder.jpg"]
   usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.flag draw];
    
    [self.PTButton setTitle:[NSString stringWithFormat:@"%@%i", @"PT", player.pt]
                   forState:UIControlStateNormal];
}

@end
