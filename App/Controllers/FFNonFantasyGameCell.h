//
//  FFNonFantasyGameCell.h
//  FMF Football
//
//  Created by Anton Chuev on 5/21/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kNonFantasyGameCellIdentifier @"FFNonFantasyGameCell"

@class FFNonFantasyGame;
@class FFStyle;

@interface FFNonFantasyGameCell : UITableViewCell

@property (nonatomic, readonly) FFCustomButton *addHomeTeamBtn;
@property (nonatomic, readonly) FFCustomButton *addAwayTeamBtn;
@property (nonatomic, readonly) FFCustomButton *homePTButton;
@property (nonatomic, readonly) FFCustomButton *awayPTButton;

- (void)setupWithGame:(FFNonFantasyGame *)game;

@end
