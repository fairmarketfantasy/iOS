//
//  FFPredictHistoryTable.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/28/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFPredictionsSelector.h"

@class FUISegmentedControl;

@protocol FFPredictHistoryProtocol <NSObject>

- (void)changeHistory:(FUISegmentedControl*)segments;

@end

@interface FFPredictHistoryTable : UITableView

@property(nonatomic, weak) id<FFPredictHistoryProtocol> historyDelegate;
- (void)setPredictionType:(FFPredictionsType)type;

@end
