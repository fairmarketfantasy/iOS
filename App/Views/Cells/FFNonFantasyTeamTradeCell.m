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
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface FFNonFantasyTeamTradeCell()

@property (nonatomic, strong) UILabel *teamName;
@property (nonatomic, strong) UILabel *gameName;

@end

@implementation FFNonFantasyTeamTradeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    
    return self;
}

- (void)setupWithGame:(FFTeam *)team
{
    self.titleLabel.text = team.name;
    
    [self.avatar setImageWithURL:[NSURL URLWithString:team.logoURL]
                placeholderImage:[UIImage imageNamed:@"rosterslotempty"]
     usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    [self.avatar draw];
}

@end
