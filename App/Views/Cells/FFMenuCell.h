//
//  FFMenuCell.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 2/27/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FFMenuCell : UITableViewCell

@property(nonatomic) UIView* separator;
- (void)setAccessoryNamed:(NSString*)accessoryName;

@end
