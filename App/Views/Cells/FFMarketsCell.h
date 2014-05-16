//
//  FFMarketsCell.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/14/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FFMarketSelector;

@interface FFMarketsCell : UITableViewCell

@property(nonatomic) FFMarketSelector* marketSelector;

- (void)showStatusLabelWithMessage:(NSString *)message;
- (void)hideStatusLabel;

@end
