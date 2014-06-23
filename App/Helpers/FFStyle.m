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

+ (NSNumberFormatter*)priceFormatter
{
    NSNumberFormatter* formatter = NSNumberFormatter.new;
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    [formatter setNegativeFormat:@"¤-#,##0.00"];
    formatter.maximumFractionDigits = 0;
    return formatter;
}

+ (NSNumberFormatter*)funbucksFormatter
{
    NSNumberFormatter* formatter = NSNumberFormatter.new;
//    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    return formatter;
}

+ (NSDateFormatter*)marketDateFormatter
{

    NSDateFormatter* formatter = NSDateFormatter.new;
    [formatter setDateFormat:@"E d @ h:mm a"];
    formatter.timeZone = [NSTimeZone localTimeZone];
   return formatter;
}

+ (NSDateFormatter*)dateFormatter
{
    NSDateFormatter* formatter = NSDateFormatter.new;
    formatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"MMMM d, y"
                                                           options:0
                                                            locale:[NSLocale currentLocale]];
    formatter.timeZone = [NSTimeZone localTimeZone];
    return formatter;
}

+ (NSDateFormatter*)dayFormatter
{
    NSDateFormatter* formatter = NSDateFormatter.new;
    formatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"E M dd"
                                                           options:0
                                                            locale:[NSLocale currentLocale]];
    formatter.timeZone = [NSTimeZone localTimeZone];
    return formatter;
}

+ (NSDateFormatter*)timeFormatter
{
    NSDateFormatter* formatter = NSDateFormatter.new;
    formatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"h:m a"
                                                           options:0
                                                            locale:[NSLocale currentLocale]];
    formatter.timeZone = [NSTimeZone localTimeZone];
    return formatter;
}

// COLORS --------------------------------------------------------------------------------------------------------------

+ (UIColor*)darkGrey
{
    return [UIColor colorWithWhite:71.f / 255.f
                             alpha:1.f];
}

+ (UIColor*)darkBlue
{
    return [UIColor colorWithRed:0.f
                           green:201.f / 255.f
                            blue:120.f / 255.f
                           alpha:1.f];
}

+ (UIColor*)darkGreen
{
    return [UIColor colorWithRed:62.f / 255.f
                           green:111.f / 255.f
                            blue:67.f / 255.f
                           alpha:1.f];
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
    return [UIColor colorWithRed:108.f / 255.f
                           green:164.f / 255.f
                            blue:81.f / 255.f
                           alpha:1];
}

+ (UIColor*)brightBlue
{
    return [UIColor colorWithRed:41.f / 255.f
                           green:95.f / 255.f
                            blue:135.f / 255.f
                           alpha:1.f];
}

+ (UIColor*)lightGrey
{
    return [UIColor colorWithWhite:.8f
                             alpha:1.f];
}

+ (UIColor*)black
{
    return [UIColor blackColor];
}

+ (UIColor*)brightRed
{
    return [UIColor colorWithRed:242.f / 255.f
                           green:68.f / 255.f
                            blue:62.f / 255.f
                           alpha:1.f];
}

+ (UIColor*)greyTextColor
{
    return [UIColor colorWithWhite:.4f
                             alpha:1.f];
}

+ (UIColor*)darkGreyTextColor
{
    return [UIColor colorWithWhite:.25f
                             alpha:1.f];
}

+ (UIColor*)tableViewSeparatorColor
{
    return [UIColor colorWithWhite:.85f
                             alpha:1.f];
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
    return [UIColor colorWithRed:1.f
                           green:163.f / 255.f
                            blue:42.f / 255.f
                           alpha:1.f];
}

// FONTS ---------------------------------------------------------------------------------------------------------------

+ (UIFont*)blockFont:(CGFloat)size
{
    return [UIFont fontWithName:@"Prohibition-Bold"
                           size:size];
}

+ (UIFont*)italicBlockFont:(CGFloat)size
{
    return [UIFont fontWithName:@"Prohibition-BoldItalic"
                           size:size];
}

+ (UIFont*)regularFont:(CGFloat)size
{
    return [UIFont fontWithName:@"HelveticaNeue-Light"
                           size:size];
}

+ (UIFont*)italicFont:(CGFloat)size
{
    return [UIFont fontWithName:@"HelveticaNeue-LightItalic"
                           size:size];
}

+ (UIFont*)lightFont:(CGFloat)size
{
    return [UIFont fontWithName:@"HelveticaNeue-UltraLight"
                           size:size];
}

+ (UIFont*)boldFont:(CGFloat)size
{
    return [UIFont fontWithName:@"HelveticaNeue-Bold"
                           size:size];
}

+ (UIFont*)mediumFont:(CGFloat)size
{
    return [UIFont fontWithName:@"HelveticaNeue-Medium"
                           size:size];
}

// UI CONSTRUCTORS -----------------------------------------------------------------------------------------------------

+ (UIButton*)clearButtonWithText:(NSString*)text
                     borderColor:(UIColor*)color
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.borderColor = color.CGColor;
    button.layer.borderWidth = 1;
    button.layer.cornerRadius = 3;
    button.layer.masksToBounds = YES;
    [button setBackgroundImage:[UIImage imageNamed:@"button_normal"]
                  forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"button_pressed"]
                  forState:UIControlStateHighlighted];
    button.titleLabel.font = [FFStyle blockFont:14];
    [button setTitle:text
        forState:UIControlStateNormal];
    return button;
}

+ (NSArray*)clearNavigationBarButtonWithText:(NSString*)text
                                 borderColor:(UIColor*)color
                                      target:(id)target
                                    selector:(SEL)selector
                               leftElseRight:(BOOL)left
{
    UIButton* button = [FFNavigationBarItemButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.f, 0.f, 65.f, 27.f);
    button.layer.borderColor = color.CGColor;
    button.layer.borderWidth = 1.f;
    button.layer.cornerRadius = 3.f;
    button.layer.masksToBounds = YES;
    [button setBackgroundImage:[UIImage imageNamed:@"button_normal"]
                  forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"button_pressed"]
                  forState:UIControlStateHighlighted];
    button.titleLabel.font = [FFStyle blockFont:14.f];
    button.titleEdgeInsets = UIEdgeInsetsMake(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ?
                                         1.5f : 4.f,
                                         0.f, 0.f, 0.f);
    [button setTitle:text
            forState:UIControlStateNormal];
    [button addTarget:target
               action:selector
     forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:button];

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        UIBarButtonItem* spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                   target:nil
                                                                                   action:NULL];
        spaceItem.width = -8.f;
        if (left) {
            return @[
                     spaceItem,
                     item
            ];
        } else {
            UIView* content = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 65.f, 27.f)];
            content.backgroundColor = [UIColor clearColor];
            button.frame = CGRectOffset(button.frame, 7.f, 0.f);
            [content addSubview:button];
            return @[
                     [[UIBarButtonItem alloc] initWithCustomView:content]
            ];
        }
    } else {
        return @[
                 item
        ];
    }
}

+ (FFCustomButton*)coloredButtonWithText:(NSString*)text
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

+ (CGRect)itemRect
{
    return CGRectMake(0.f, 0.f, 44.f, 44.f);
}

+ (NSArray*)backBarItemsForController:(UIViewController*)controller
{
    UIView* leftView = [[FFNavigationBarItemButton alloc] initWithFrame:[self itemRect]];
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

+ (UIImage *)imageWithColor:(UIColor*)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

+ (void)customizeAppearance
{
    // bar button item
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        [[UIBarButtonItem appearance] setTintColor:[self darkGreen]];
        [[UIBarButtonItem appearance] setTitleTextAttributes:@{UITextAttributeTextShadowColor:[UIColor clearColor],
                                                               UITextAttributeTextShadowOffset:[NSValue valueWithUIOffset:UIOffsetZero]}
                                                    forState:UIControlStateNormal];
        [[UIBarButtonItem appearance] setTitleTextAttributes:@{UITextAttributeTextShadowColor:[UIColor clearColor],
                                                               UITextAttributeTextShadowOffset:[NSValue valueWithUIOffset:UIOffsetZero]}
                                                    forState:UIControlStateHighlighted];
        [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"button_normal"]
                                                forState:UIControlStateNormal
                                                   style:UIBarButtonItemStyleBordered
                                              barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"button_pressed"]
                                                forState:UIControlStateHighlighted
                                                   style:UIBarButtonItemStyleBordered
                                              barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"button_normal"]
                                                forState:UIControlStateNormal
                                                   style:UIBarButtonItemStyleDone
                                              barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"button_pressed"]
                                                forState:UIControlStateHighlighted
                                                   style:UIBarButtonItemStyleDone
                                              barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"button_normal"]
                                                forState:UIControlStateNormal
                                                   style:UIBarButtonItemStylePlain
                                              barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"button_pressed"]
                                                forState:UIControlStateHighlighted
                                                   style:UIBarButtonItemStylePlain
                                              barMetrics:UIBarMetricsDefault];
    }
    // navigation bar
    [[UINavigationBar appearance] setBackgroundImage:[self imageWithColor:[self darkGreen]]
                                       forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundImage:[self imageWithColor:[self darkGreen]]
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

    [[UIToolbar appearance] setBackgroundImage:[self imageWithColor:[self darkGreen]]
                            forToolbarPosition:UIToolbarPositionAny
                                    barMetrics:UIBarMetricsDefault];
    [[UIToolbar appearance] setBackgroundImage:[self imageWithColor:[self darkGreen]]
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
