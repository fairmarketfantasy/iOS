//
//  FFTeamTradeCell.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/19/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFTeamCell.h"

#define kTeamTradeCellIdentifier @"TeamTradeCell"

@class FFCustomButton;

@interface FFTeamTradeCell : FFTeamCell

@property(nonatomic, readonly) UILabel* nameLabel;
@property(nonatomic, readonly) UILabel* costLabel;
@property(nonatomic, readonly) UILabel* centLabel;
@property(nonatomic, readonly) FFCustomButton* PTButton;
@property(nonatomic, readonly) FFCustomButton* tradeButton;

@end
