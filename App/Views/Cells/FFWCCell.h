//
//  FFWCCell.h
//  FMF Football
//
//  Created by Anton on 6/1/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FFPathImageView;
@class FFWCPlayer;
@class FFWCTeam;

@interface FFWCCell : UITableViewCell

@property (nonatomic, readonly) FFCustomButton* PTButton;

- (void)setupWithTeam:(FFWCTeam *)team;
- (void)setupWithPlayer:(FFWCPlayer *)player;

@end
