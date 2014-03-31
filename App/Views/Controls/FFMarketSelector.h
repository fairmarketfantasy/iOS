//
//  FFMarketSelector.h
//  FMF Football
//
//  Created by Samuel Sutch on 9/24/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FFMarket;

@protocol FFMarketSelectorDelegate <UICollectionViewDataSource>

@property(nonatomic, readonly) NSArray* markets;

@optional
- (void)marketSelected:(FFMarket*)selectedMarket;

@end

@interface FFMarketSelector : UIView

@property(nonatomic) NSUInteger selectedMarket;
@property(nonatomic, weak) id<FFMarketSelectorDelegate> delegate;
@property(nonatomic, readonly) UIButton* rightButton;
@property(nonatomic, readonly) UIButton* leftButton;

- (void)reloadData;

@end
