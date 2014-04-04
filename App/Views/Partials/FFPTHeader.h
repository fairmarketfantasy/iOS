//
//  FFPTHeader.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/6/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FFPathImageView;

@interface FFPTHeader : UIView

@property(nonatomic, readonly) FFPathImageView* avatar;
@property(nonatomic, copy) NSString* title;
@property(nonatomic, copy) NSString* team;

@end
