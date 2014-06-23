//
//  FFNonFantasyTeamTradeCell.m
//  FMF Football
//
//  Created by Anton Chuev on 5/21/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFNonFantasyTeamTradeCell.h"
#import "FFTeam.h"
#import "FFPathImageView.h"
#import "FFDate.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface FFNonFantasyTeamTradeCell()

@property (nonatomic, strong) UILabel *teamNameLabel;
@property (nonatomic, strong) UILabel *gameNameLabel;
@property (nonatomic, strong) UILabel *ptLabel;

@end

@implementation FFNonFantasyTeamTradeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.teamNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(82.f, 12.f, 200.f, 16.f)];
        self.teamNameLabel.backgroundColor = [UIColor clearColor];
        self.teamNameLabel.font = [FFStyle regularFont:14.f];
        self.teamNameLabel.textColor = [FFStyle greyTextColor];
        self.teamNameLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.teamNameLabel];
       
        self.gameNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(82.f, 50.f, 133.f, 16.f)];
        self.gameNameLabel.backgroundColor = [UIColor clearColor];
        self.gameNameLabel.font = [FFStyle regularFont:14.f];
        self.gameNameLabel.textColor = [FFStyle darkGreyTextColor];
        self.gameNameLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.gameNameLabel];
        
        self.ptLabel = [[UILabel alloc] initWithFrame:CGRectMake(217.f, 23.f, 37.f, 37.f)];
        self.ptLabel.backgroundColor = [UIColor colorWithWhite:.9f alpha:1.f];
        self.ptLabel.font = [FFStyle blockFont:17.f];
        self.ptLabel.textColor = [FFStyle brightBlue];
        self.ptLabel.textAlignment = NSTextAlignmentCenter;
        self.ptLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.ptLabel];
        
        _deleteBtn = [FFCustomButton buttonWithType:UIButtonTypeCustom];
        self.deleteBtn.frame = CGRectMake(262.f, 23.f, 37.f, 37.f);
        [self.deleteBtn setImage:[UIImage imageNamed:@"delete-btn"] forState:UIControlStateNormal];
        [self.contentView addSubview:self.deleteBtn];
    }
    
    return self;
}

- (void)setupWithGame:(FFTeam *)team
{
    [self.avatar setImageWithURL:[NSURL URLWithString:team.logoURL]
                placeholderImage:[UIImage imageNamed:@"rosterslotempty"]
     usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    [self.avatar draw];
    
    NSString *dayOfMonth = [[FFStyle dayOfMonthFormatter] stringFromDate:team.gameDate];
    NSString *dayOfWeak = [[FFStyle dayOfWeekFormatter] stringFromDate:team.gameDate];
    self.titleLabel.text = [NSString stringWithFormat:@"%@%@ @ %@", dayOfWeak, dayOfMonth, [[FFStyle timeFormatter] stringFromDate:team.gameDate]];
    
    self.ptLabel.text = [NSString stringWithFormat:@"%i", team.pt];
    self.teamNameLabel.text = team.name;
    if (team.gameName) {
        self.gameNameLabel.text = team.gameName;
    } else {
        self.gameNameLabel.text = team.isHomeTeam ?
        [NSString stringWithFormat:@"%@ @ %@", team.name, team.opponentName] :
        [NSString stringWithFormat:@"%@ @ %@", team.opponentName, team.name];
        self.ptLabel.hidden = YES;
        self.deleteBtn.hidden = YES;
    }
}

@end
