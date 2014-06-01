//
//  FFWCCell.h
//  FMF Football
//
//  Created by Anton on 6/1/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FFPathImageView;

@interface FFWCCell : UITableViewCell

@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, readonly) FFPathImageView *flag;
@property (nonatomic, readonly) FFCustomButton* PTButton;

@end
