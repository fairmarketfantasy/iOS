//
//  FFWideReceiverCell.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/19/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kWideRecieverCellIdentifier @"ReceiverCell"

@class FUISegmentedControl;

@interface FFWideReceiverCell : UITableViewCell

@property(nonatomic) FUISegmentedControl* segments;

- (void)setItems:(NSArray*)items;

@end
