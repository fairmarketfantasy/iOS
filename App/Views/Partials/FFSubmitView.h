//
//  FFSubmitView.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/3/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

typedef NS_ENUM(NSInteger, FFSubmitViewType) {
    FFSubmitViewTypeFantasy,
    FFSubmitViewTypeNonFantasy
};

#import <UIKit/UIKit.h>

@class FUISegmentedControl;

@interface FFSubmitView : UIView

@property(nonatomic, readonly) FUISegmentedControl* segments;
@property(nonatomic, readonly) UIButton *submitButton;

- (void)setupWithType:(FFSubmitViewType)type;

@end
