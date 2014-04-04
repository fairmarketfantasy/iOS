//
//  FFPredictHistoryCell.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/28/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FFCustomButton;

@interface FFPredictHistoryCell : UITableViewCell

@property(nonatomic, readonly) FFCustomButton* rosterButton;
@property(nonatomic, readonly) UILabel* nameLabel;
@property(nonatomic, readonly) UILabel* teamLabel;
@property(nonatomic, readonly) UILabel* dayLabel;
@property(nonatomic, readonly) UILabel* stateLabel;
@property(nonatomic, readonly) UILabel* pointsLabel;
@property(nonatomic, readonly) UILabel* paidLabel;
@property(nonatomic, readonly) UILabel* raknLabel;
@property(nonatomic, readonly) UILabel* awaidLabel;

@end
