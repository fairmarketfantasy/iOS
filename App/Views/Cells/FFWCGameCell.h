//
//  FFWCGameCell.h
//  FMF Football
//
//  Created by Anton on 6/1/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FFWCGame;

@interface FFWCGameCell : UITableViewCell

@property (nonatomic, readonly) FFCustomButton *homePTButton;
@property (nonatomic, readonly) FFCustomButton *guestPTButton;

- (void)setupWithGame:(FFWCGame *)game;

@end
