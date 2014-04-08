//
//  FFPredictionsSelector.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/3/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, FFPredictionsType) {
    FFPredictionsTypeIndividual,
    FFPredictionsTypeRoster
}; // ???: move to one of models?

@protocol FFPredictionsProtocol <NSObject>

- (void)predictionsTypeSelected:(FFPredictionsType)type;

@end

@interface FFPredictionsSelector : UIView

@property(nonatomic, weak) id<FFPredictionsProtocol> delegate;

@end
