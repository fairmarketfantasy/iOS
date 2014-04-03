//
//  FFPredictIndividualCell.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/3/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FFPredictIndividualCell : UITableViewCell

@property(nonatomic, readonly) UILabel* nameLabel;
@property(nonatomic, readonly) UILabel* teamLabel;
@property(nonatomic, readonly) UILabel* dayLabel;
@property(nonatomic, readonly) UILabel* ptLabel;
@property(nonatomic, readonly) UILabel* predictLabel;
@property(nonatomic, readonly) UILabel* timeLabel;
@property(nonatomic, readonly) UILabel* awaidLabel;

@end
