//
//  FFTeamCell.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/14/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTeamCellIdentifier @"TeamCell"

@class FFPathImageView;

@interface FFTeamCell : UITableViewCell

@property(nonatomic, readonly) FFPathImageView* avatar;
@property(nonatomic, readonly) UIView* benched;
@property(nonatomic, readonly) UIView* swapped;
@property(nonatomic, readonly) UILabel* titleLabel;

@end
