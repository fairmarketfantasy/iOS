//
//  FFCollectionMarketCell.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/26/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FFCollectionMarketCell : UICollectionViewCell

@property(nonatomic, readonly) UILabel* marketLabel;
@property(nonatomic, readonly) UILabel* timeLabel;

- (void)showNoGamesMessage;

@end
