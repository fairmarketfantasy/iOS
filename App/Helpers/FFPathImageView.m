//
//  FFPathImageView.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/24/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFPathImageView.h"


static CGFloat const LINE_BORDER_WIDTH = 1.f;


@interface FFPathImageView ()
{
    UIImage* _originalImage;
}

@end


@implementation FFPathImageView

- (id)initWithFrame:(CGRect)frame
              image:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _originalImage = image;
        
        [self setDefaultParam];
        
        [self draw];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
              image:(UIImage *)image
           pathType:(FFPathImageViewType)pathType
          pathColor:(UIColor *)pathColor
        borderColor:(UIColor *)borderColor
          pathWidth:(float)pathWidth
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _originalImage = image;
        _pathType = pathType;
        _pathColor = pathColor;
        _borderColor = borderColor;
        _pathWidth = pathWidth;
         
        [self draw];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _originalImage = self.image;
    
    [self setDefaultParam];
    
    [self draw];
}

- (void)setNeedsLayout
{
    [super setNeedsLayout];
    [self draw];
}

- (void)draw
{
    if (self.image) {
        _originalImage = self.image;
    }

    CGRect rect;
    rect.size = self.frame.size;
    rect.origin = CGPointMake(0, 0);
    
    CGRect rectImage = rect;
    rectImage.origin.x += _pathWidth;
    rectImage.origin.y += _pathWidth;
    rectImage.size.width -= _pathWidth*2.0;
    rectImage.size.height -= _pathWidth*2.0;
    
    UIGraphicsBeginImageContextWithOptions(rect.size,0,0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    switch (_pathType) {
        case FFPathImageViewTypeCircle:
            CGContextAddEllipseInRect(ctx, rect);
            break;
        case FFPathImageViewTypeSquare:
            CGContextAddRect(ctx, rect);
            break;
        default:
            break;
    }
    
    CGContextClip(ctx);
    [_originalImage drawInRect:rectImage];
    
    //Add intern and extern line
    rectImage.origin.x -= LINE_BORDER_WIDTH/2.0;
    rectImage.origin.y -= LINE_BORDER_WIDTH/2.0;
    rectImage.size.width += LINE_BORDER_WIDTH;
    rectImage.size.height += LINE_BORDER_WIDTH;
    
    rect.origin.x += LINE_BORDER_WIDTH/2.0;
    rect.origin.y += LINE_BORDER_WIDTH/2.0;
    rect.size.width -= LINE_BORDER_WIDTH;
    rect.size.height -= LINE_BORDER_WIDTH;
    
    CGContextSetStrokeColorWithColor(ctx, [_borderColor CGColor]);
    CGContextSetLineWidth(ctx, LINE_BORDER_WIDTH);
    
    switch (_pathType) {
        case FFPathImageViewTypeCircle:
            CGContextStrokeEllipseInRect(ctx, rectImage);
            CGContextStrokeEllipseInRect(ctx, rect);
            break;
        case FFPathImageViewTypeSquare:
            CGContextStrokeRect(ctx, rectImage);
            CGContextStrokeRect(ctx, rect);
            break;
        default:
            break;
    }
    
    //Add center line
    float centerLineWidth = _pathWidth - LINE_BORDER_WIDTH*2.0;
    
    rectImage.origin.x -= LINE_BORDER_WIDTH/2.0+centerLineWidth/2.0;
    rectImage.origin.y -= LINE_BORDER_WIDTH/2.0+centerLineWidth/2.0;
    rectImage.size.width += LINE_BORDER_WIDTH+centerLineWidth;
    rectImage.size.height += LINE_BORDER_WIDTH+centerLineWidth;
    
    CGContextSetStrokeColorWithColor(ctx, [_pathColor CGColor]);
    CGContextSetLineWidth(ctx, centerLineWidth > 0.f ? centerLineWidth : 0.f);
    
    switch (_pathType) {
        case FFPathImageViewTypeCircle:
            CGContextStrokeEllipseInRect(ctx, rectImage);
            break;
        case FFPathImageViewTypeSquare:
            CGContextStrokeRect(ctx, rectImage);
            break;
        default:
            break;
    }
    
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
}

- (void)setDefaultParam
{
    _pathType = FFPathImageViewTypeCircle;
    _pathColor = [UIColor whiteColor];
    _borderColor = [UIColor darkGrayColor];
    _pathWidth = 5.f;
}

@end
