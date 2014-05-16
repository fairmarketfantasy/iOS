//
//  FFMarketSelector.h
//  FMF Football
//
//  Created by Samuel Sutch on 9/24/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FFMarket;

@protocol FFMarketSelectorDataSource <UICollectionViewDataSource>

@property(nonatomic, readonly) NSArray* markets;

@end

@protocol FFMarketSelectorDelegate <NSObject>

@optional
- (void)marketSelected:(FFMarket*)selectedMarket;

@end

@interface FFMarketSelector : UIView

@property(nonatomic) NSUInteger selectedMarket;
@property(nonatomic, weak) id<FFMarketSelectorDataSource> dataSource;
@property(nonatomic, weak) id<FFMarketSelectorDelegate> delegate;
@property(nonatomic, readonly) UIButton* rightButton;
@property(nonatomic, readonly) UIButton* leftButton;

/**
 * set selected market without calling delegate
 * @param animated Specify YES to animate the scrolling.
 * @return YES if market updated.
 */
- (BOOL)updateSelectedMarket:(NSUInteger)selectedMarket
                    animated:(BOOL)animated;
- (void)reloadData;

@end
