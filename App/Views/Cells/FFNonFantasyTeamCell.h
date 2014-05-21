//
//  FFNonFantasyTeamCell.h
//  FMF Football
//
//  Created by Anton Chuev on 5/21/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kNonFantasyTeamCellIdentifier @"FFNonFantasyTeamCell"

@class FFPathImageView;

@interface FFNonFantasyTeamCell : UITableViewCell

@property(nonatomic, readonly) FFPathImageView* avatar;
@property(nonatomic, readonly) UILabel* titleLabel;

@end
