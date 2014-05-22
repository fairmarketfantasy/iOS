//
//  FFNonFantasyTeamTradeCell.h
//  FMF Football
//
//  Created by Anton Chuev on 5/21/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFNonFantasyTeamCell.h"
#import "FFTeam.h"
#import "FFStyle.h"

#define kNonFantasyTeamTradeCellIdentifier @"NonFantasyTeamTradeCell"

@interface FFNonFantasyTeamTradeCell : FFNonFantasyTeamCell

@property (nonatomic, readonly) FFCustomButton *deleteBtn;

- (void)setupWithGame:(FFTeam *)team;

@end
