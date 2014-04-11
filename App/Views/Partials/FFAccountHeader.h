//
//  FFAccountHeader.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/21/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FFPathImageView;
@class FFCustomButton;

@interface FFAccountHeader : UIView

@property(nonatomic) FFPathImageView* avatar;
@property(nonatomic, readonly) UILabel* nameLabel;
@property(nonatomic, readonly) UILabel* dateLabel;
@property(nonatomic, readonly) UILabel* fanBucksLabel;
@property(nonatomic, readonly) FFCustomButton* fanBucksButton;
@property(nonatomic, readonly) UILabel* prestigeLabel;
@property(nonatomic, readonly) UILabel* winsLabel;

@end
