//
//  FFAutoFillCell.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/19/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FUISwitch;

@interface FFAutoFillCell : UITableViewCell

@property(nonatomic, readonly) UIButton* autoFillButton;
@property(nonatomic, readonly) FUISwitch* autoRemovedBenched;

@end
