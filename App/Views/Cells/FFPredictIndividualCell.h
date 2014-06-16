//
//  FFPredictIndividualCell.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/3/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFIndividualPrediction.h"

@interface FFPredictIndividualCell : UITableViewCell

@property(nonatomic, readonly) UILabel* choiceLabel;
@property(nonatomic, readonly) UILabel* eventLabel;
@property(nonatomic, readonly) UILabel* dayLabel;
@property(nonatomic, readonly) UILabel* ptLabel;
@property(nonatomic, readonly) UILabel* predictLabel;
@property(nonatomic, readonly) UILabel* timeLabel;
@property(nonatomic, readonly) UILabel* awaidLabel;
@property(nonatomic, readonly) UILabel* resultLabel;

- (void)setupWithPrediction:(FFIndividualPrediction *)prediction;

@end
