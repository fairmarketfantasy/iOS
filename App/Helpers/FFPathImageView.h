//
//  FFPathImageView.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/24/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, FFPathImageViewType) {
    FFPathImageViewTypeCircle,
    FFPathImageViewTypeSquare
};

@interface FFPathImageView : UIImageView

@property (nonatomic) FFPathImageViewType pathType;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) UIColor *pathColor;
@property CGFloat pathWidth;

- (id)initWithFrame:(CGRect)frame
              image:(UIImage *)image;
- (id)initWithFrame:(CGRect)frame
              image:(UIImage *)image
           pathType:(FFPathImageViewType)pathType
          pathColor:(UIColor *)pathColor
        borderColor:(UIColor *)borderColor
          pathWidth:(float)pathWidth;
- (void)draw;

@end
