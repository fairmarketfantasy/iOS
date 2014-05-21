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

@interface FFNonFantasyGameCell : UITableViewCell

- (void)setupWithGame:(FFNonFantasyGame *)game;

@end
