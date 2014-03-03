//
//  FFBaseViewController.h
//  FMF Football
//
//  Created by Samuel Sutch on 9/17/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFDrawerViewController.h"
#import "FFMenuViewController.h"
#import <A2StoryboardSegueContext/A2StoryboardSegueContext.h>
#import "FFTickerDataSource.h"
#import "FFTickerMaximizedDrawerViewController.h"
#import "FFTickerMinimizedDrawerViewController.h"

@interface FFBaseViewController : UIViewController <FFMenuViewControllerDelegate>

@property(nonatomic) FFTickerMaximizedDrawerViewController* maximizedTicker;
@property(nonatomic) FFTickerMinimizedDrawerViewController* minimizedTicker;
@property(nonatomic) FFTickerDataSource* tickerDataSource;

@property(nonatomic, readonly) UIView* banner;
@property(nonatomic, readonly) FFDrawerViewController* maximizedDrawerController;
@property(nonatomic, readonly) FFDrawerViewController* minimizedDrawerController;
@property(nonatomic, readonly) BOOL drawerIsMinimized;
@property(nonatomic, readonly) FFMenuViewController* menuController;

- (void)showBanner:(NSString*)text
            target:(id)target
          selector:(SEL)selector
          animated:(BOOL)animated;
- (void)closeBannerAnimated:(BOOL)animated;
- (void)showInDrawerMaximizedController:(FFDrawerViewController*)maximizedController
            withMinimizedViewController:(FFDrawerViewController*)minimizedController
                        resizeTableView:(UITableView*)tableView
                               animated:(BOOL)animated;
- (void)showInDrawerMaximizedController:(FFDrawerViewController*)maximizedController
            withMinimizedViewController:(FFDrawerViewController*)minimizedController
                               animated:(BOOL)animated;
- (void)maximizeDrawerAnimated:(BOOL)animated;
- (void)minimizeDrawerAnimated:(BOOL)animated;
- (void)closeDrawerAnimated:(BOOL)animated;
- (void)showMenuController;
- (void)hideMenuController;

@end
