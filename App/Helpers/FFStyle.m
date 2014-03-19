//
//  FFStyle.m
//  FMF Football
//
//  Created by Samuel Sutch on 9/12/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import "FFStyle.h"
#import <QuartzCore/QuartzCore.h>
#import "FFNavigationBarItemView.h"
#import "FFLogo.h"

// HELPER FUNCTIONS ----------------------------------------------------------------------------------------------------

CGRect CGRectCopyWithOrigin(CGRect r, CGPoint origin)
{
    CGRect rect = r;
    rect.origin.x = origin.x;
    rect.origin.y = origin.y;
    return rect;
}

// STYLE ---------------------------------------------------------------------------------------------------------------

@implementation FFStyle

// COLORS --------------------------------------------------------------------------------------------------------------

+ (UIColor*)darkBlue
{
    return [UIColor colorWithRed:28.f / 255.f
                           green:27.f / 255.f
                            blue:163.f / 255.f
                           alpha:1.f];
}

+ (UIColor*)darkGreen
{
    return [UIColor colorWithRed:51.0 / 255.0
                           green:96.0 / 255.0
                            blue:48.0 / 255.0
                           alpha:1];
}

+ (UIColor*)white
{
    return [UIColor whiteColor];
}

+ (UIColor*)greyBorder
{
    return [UIColor colorWithWhite:.8
                             alpha:1];
}

+ (UIColor*)brightGreen
{
    return [UIColor colorWithRed:75.0 / 255.0
                           green:172.0 / 255.0
                            blue:69.0 / 255.0
                           alpha:1];
}

+ (UIColor*)brightBlue
{
    return [UIColor colorWithRed:59.0 / 255.0
                           green:104.0 / 255.0
                            blue:1
                           alpha:1];
}

+ (UIColor*)lightGrey
{
    return [UIColor colorWithWhite:.8
                             alpha:1];
}

+ (UIColor*)black
{
    return [UIColor blackColor];
}

+ (UIColor*)brightRed
{
    return [UIColor colorWithRed:190.0 / 255.0
                           green:30.0 / 255.0
                            blue:45.0 / 255.0
                           alpha:1];
}

+ (UIColor*)yellowErrorColor
{
    return [UIColor yellowColor]; // TODO: this
}

+ (UIColor*)greyTextColor
{
    return [UIColor colorWithWhite:.4
                             alpha:1];
}

+ (UIColor*)darkGreyTextColor
{
    return [UIColor colorWithWhite:.25
                             alpha:1];
}

+ (UIColor*)tableViewSeparatorColor
{
    return [UIColor colorWithWhite:.85
                             alpha:1];
}

+ (UIColor*)tableViewSectionHeaderColor
{
    return [UIColor colorWithRed:34.0 / 255.0
                           green:34.0 / 255.0
                            blue:34.0 / 255.0
                           alpha:1];
}

+ (UIColor*)brightOrange
{
    return [UIColor colorWithRed:246.0 / 255.0
                           green:146.0 / 255.0
                            blue:30.0 / 255.0
                           alpha:1];
}

// FONTS ---------------------------------------------------------------------------------------------------------------

+ (UIFont*)blockFont:(int)size
{
    return [UIFont fontWithName:@"Prohibition-Bold"
                           size:size];
}

+ (UIFont*)italicBlockFont:(int)size
{
    return [UIFont fontWithName:@"Prohibition-BoldItalic"
                           size:size];
}

+ (UIFont*)regularFont:(int)size
{
    return [UIFont fontWithName:@"HelveticaNeue-Light"
                           size:size];
}

+ (UIFont*)italicFont:(int)size
{
    return [UIFont fontWithName:@"HelveticaNeue-LightItalic"
                           size:size];
}

+ (UIFont*)lightFont:(int)size
{
    return [UIFont fontWithName:@"HelveticaNeue-UltraLight"
                           size:size];
}

+ (UIFont*)boldFont:(int)size
{
    return [UIFont fontWithName:@"HelveticaNeue-Bold"
                           size:size];
}

+ (UIFont*)mediumFont:(int)size
{
    return [UIFont fontWithName:@"HelveticaNeue-Medium"
                           size:size];
}

// UI CONSTRUCTORS -----------------------------------------------------------------------------------------------------

+ (UIButton*)clearButtonWithText:(NSString*)text borderColor:(UIColor*)color
{
    UIButton* b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.layer.borderColor = color.CGColor;
    b.layer.borderWidth = 1;
    b.layer.cornerRadius = 3;
    b.layer.masksToBounds = YES;
    [b setBackgroundImage:[UIImage imageNamed:@"0-percent.png"]
                  forState:UIControlStateNormal];
    [b setBackgroundImage:[UIImage imageNamed:@"40-percent.png"]
                  forState:UIControlStateHighlighted];
    b.titleLabel.font = [FFStyle blockFont:14];
    [b setTitle:text
        forState:UIControlStateNormal];
    return b;
}

+ (NSArray*)clearNavigationBarButtonWithText:(NSString*)text
                                 borderColor:(UIColor*)color
                                      target:(id)target
                                    selector:(SEL)selector
                               leftElseRight:(BOOL)left
{
    UIButton* b = [FFNavigationBarItemButton buttonWithType:UIButtonTypeCustom];
    b.frame = CGRectMake(0, 0, 65, 27);
    b.layer.borderColor = color.CGColor;
    b.layer.borderWidth = 1;
    b.layer.cornerRadius = 3;
    b.layer.masksToBounds = YES;
    [b setBackgroundImage:[UIImage imageNamed:@"0-percent.png"]
                  forState:UIControlStateNormal];
    [b setBackgroundImage:[UIImage imageNamed:@"40-percent.png"]
                  forState:UIControlStateHighlighted];
    b.titleLabel.font = [FFStyle blockFont:14];
    [b setTitle:text
        forState:UIControlStateNormal];
    [b addTarget:target
                  action:selector
        forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:b];

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        UIBarButtonItem* spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                target:nil
                                                                                action:NULL];
        spacer.width = -8;
        if (left) {
            return @[
                spacer,
                item
            ];
        } else {
            UIView* cont = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 65, 27)];
            cont.backgroundColor = [UIColor clearColor];
            b.frame = CGRectOffset(b.frame, 7, 0);
            [cont addSubview:b];
            return @[
                [[UIBarButtonItem alloc] initWithCustomView:cont]
            ];
        }
    } else {
        return @[
            item
        ];
    }
}

+ (UIButton*)coloredButtonWithText:(NSString*)text
                             color:(UIColor*)color
                       borderColor:(UIColor*)borderColor
{
    FFCustomButton* button = [FFCustomButton new];
    button.autoresizesSubviews = YES;
    button.contentMode = UIViewContentModeScaleAspectFit;
    button.layer.borderColor = borderColor.CGColor;
    button.layer.borderWidth = 1.f;
    button.layer.cornerRadius = 3.f;
    [button setBackgroundColor:color
                      forState:UIControlStateNormal];
    [button setBackgroundColor:[self darkerColorForColor:color]
                      forState:UIControlStateHighlighted];
    button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    button.titleLabel.font = [FFStyle blockFont:17.f];
    [button setTitle:text
            forState:UIControlStateNormal];
    return button;
}

+ (CGRect)leftItemRect
{
    return CGRectMake(0.f, 0.f, 44.f, 44.f);
}

+ (NSArray*)backBarItemsForController:(UIViewController*)controller
{
    UIView* leftView = [[FFNavigationBarItemButton alloc] initWithFrame:[self leftItemRect]];
    UIButton* gmenu = [UIButton buttonWithType:UIButtonTypeCustom];
    [gmenu setImage:[UIImage imageNamed:@"backbtn.png"]
           forState:UIControlStateNormal];
    [gmenu addTarget:controller.navigationController
                  action:@selector(popViewControllerAnimated:)
        forControlEvents:UIControlEventTouchUpInside];
    gmenu.frame = CGRectMake(-2, 0, 35, 44);
    [leftView addSubview:gmenu];

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                              target:nil
                                                                              action:NULL];
        item.width = -16;

        return @[
            item,
            [[UIBarButtonItem alloc] initWithCustomView:leftView]
        ];
    } else {
        return @[
            [[UIBarButtonItem alloc] initWithCustomView:leftView]
        ];
    }
}

+ (UIColor*)lighterColorForColor:(UIColor*)c
{
    CGFloat r, g, b, w, a;
    if ([c getRed:&r
             green:&g
              blue:&b
             alpha:&a]) {
        return [UIColor colorWithRed:MIN(r + 0.2f, 1.f)
                               green:MIN(g + 0.2f, 1.f)
                                blue:MIN(b + 0.2f, 1.f)
                               alpha:a];
    } else if ([c getWhite:&w
                      alpha:&a]) {
        return [UIColor colorWithWhite:MIN(w + 0.2f, 1.f)
                                 alpha:a];
    }
    return nil;
}

+ (UIColor*)darkerColorForColor:(UIColor*)c
{
    CGFloat r, g, b, w, a;
    if ([c getRed:&r
             green:&g
              blue:&b
             alpha:&a]) {
        return [UIColor colorWithRed:MAX(r - 0.2f, 0.f)
                               green:MAX(g - 0.2f, 0.f)
                                blue:MAX(b - 0.2f, 0.f)
                               alpha:a];
    } else if ([c getWhite:&w
                      alpha:&a]) {
        return [UIColor colorWithWhite:MAX(w - 0.2f, 0.f)
                                 alpha:a];
    }
    return nil;
}

// customize uiappearance ----------------------------------------------------------------------------------------------
+ (void)customizeAppearance
{
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"darkgreen.png"]
                                       forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"darkgreen.png"]
                                       forBarMetrics:UIBarMetricsLandscapePhone];

    if ([[UINavigationBar appearance] respondsToSelector:@selector(setBarTintColor:)]) {
        [[UINavigationBar appearance] setBarTintColor:[FFStyle darkGreen]];
    }
    [[UINavigationBar appearance] setTintColor:[FFStyle white]];

    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                             UITextAttributeTextColor : [FFStyle white],
                                                             UITextAttributeTextShadowColor : [UIColor colorWithWhite:0
                                                                                                                alpha:.15],
                                                             UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
                                                             UITextAttributeFont : [FFStyle regularFont:22]
                                                         }];

    [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:0
                                                       forBarMetrics:UIBarMetricsDefault];

    if ([[UIToolbar appearance] respondsToSelector:@selector(setBarTintColor:)]) {
        [[UIToolbar appearance] setBarTintColor:[FFStyle darkGreen]];
    }
    [[UIToolbar appearance] setTintColor:[FFStyle white]];

    [[UIToolbar appearance] setBackgroundImage:[UIImage imageNamed:@"darkgreen.png"]
                            forToolbarPosition:UIToolbarPositionAny
                                    barMetrics:UIBarMetricsDefault];
    [[UIToolbar appearance] setBackgroundImage:[UIImage imageNamed:@"darkgreen.png"]
                            forToolbarPosition:UIToolbarPositionAny
                                    barMetrics:UIBarMetricsLandscapePhone];
    // pager
    UIPageControl* pageControl = [UIPageControl appearance];
    pageControl.currentPageIndicatorTintColor = [self white];
    pageControl.pageIndicatorTintColor = [self darkerColorForColor:pageControl.currentPageIndicatorTintColor];
    pageControl.backgroundColor = [UIColor clearColor];
}

@end

#pragma mark - Custom Button

#import <objc/runtime.h>

@implementation FFCustomButton

static char overviewKey;

@dynamic actions;

- (void)setAction:(NSString*)action withBlock:(void (^)())block
{

    if (!self.actions) {
        self.actions = [NSMutableDictionary new];
    }

    [self.actions setObject:block
                     forKey:action];

    if ([kUIButtonBlockTouchUpInside isEqualToString:action]) {
        [self addTarget:self
                      action:@selector(doTouchUpInside:)
            forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)setActions:(NSMutableDictionary*)actions
{
    objc_setAssociatedObject(self, &overviewKey, actions, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary*)actions
{
    return objc_getAssociatedObject(self, &overviewKey);
}

- (void)doTouchUpInside:(id)sender
{
    void (^block)();
    block = [[self actions] objectForKey:kUIButtonBlockTouchUpInside];
    block();
}

- (void)setBackgroundColor:(UIColor*)_backgroundColor forState:(UIControlState)_state
{
    if (backgroundStates == nil) {
        backgroundStates = [[NSMutableDictionary alloc] init];
    }

    [backgroundStates setObject:_backgroundColor
                         forKey:[NSNumber numberWithInt:_state]];

    if (self.backgroundColor == nil) {
        [self setBackgroundColor:_backgroundColor];
    }
}

- (UIColor*)backgroundColorForState:(UIControlState)_state
{
    return [backgroundStates objectForKey:[NSNumber numberWithInt:_state]];
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    [super touchesBegan:touches
              withEvent:event];

    UIColor* selectedColor = [backgroundStates objectForKey:[NSNumber numberWithInt:UIControlStateHighlighted]];
    if (selectedColor) {
        CATransition* animation = [CATransition animation];
        [animation setType:kCATransitionFade];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [self.layer addAnimation:animation
                          forKey:@"EaseOut"];
        self.backgroundColor = selectedColor;
    }
}

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{
    [super touchesCancelled:touches
                  withEvent:event];

    UIColor* normalColor = [backgroundStates objectForKey:[NSNumber numberWithInt:UIControlStateNormal]];
    if (normalColor) {
        CATransition* animation = [CATransition animation];
        [animation setType:kCATransitionFade];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [self.layer addAnimation:animation
                          forKey:@"EaseOut"];
        self.backgroundColor = normalColor;
    }
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    [super touchesEnded:touches
              withEvent:event];

    UIColor* normalColor = [backgroundStates objectForKey:[NSNumber numberWithInt:UIControlStateNormal]];
    if (normalColor) {
        CATransition* animation = [CATransition animation];
        [animation setType:kCATransitionFade];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [self.layer addAnimation:animation
                          forKey:@"EaseOut"];
        self.backgroundColor = normalColor;
    }
}

@end
