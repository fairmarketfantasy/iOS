//
//  FFPredictRosterScoreController.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/4/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFBaseViewController.h"

@class FFRosterPrediction;

@protocol FFPredictRosterScoreProtocol <NSObject>

@property(nonatomic, readonly) FFRosterPrediction* roster;

@end

@interface FFPredictRosterScoreController : FFBaseViewController

@property(nonatomic, weak) id<FFPredictRosterScoreProtocol> delegate;

@end
