//
//  FFBaseViewController.m
//  FMF Football
//
//  Created by Samuel Sutch on 9/17/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import "FFBaseViewController.h"
#import "FFStyle.h"
#import "FFSessionViewController.h"

@interface FFDrawerBackingView : UIView

@property(nonatomic) BOOL frameLocked;

@end

@interface FFBaseViewController () <UIGestureRecognizerDelegate>

@property(nonatomic) UITableView* _resizingTableView;

@end

#define DRAWER_HEIGHT (95.f)
#define DRAWER_MINIMIZED_HEIGHT (48.f)

@implementation FFBaseViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)showBanner:(NSString*)text target:(id)target selector:(SEL)sel animated:(BOOL)animated
{
    if (_banner) {
        WTFLog;
        NSLog(@"trying to show a banner when there already is one %@ %@ -> %@",
              text, target, NSStringFromSelector(sel));
        return;
    }
    FFCustomButton* v = [FFCustomButton buttonWithType:UIButtonTypeCustom];
    _banner = v;
    v.frame = CGRectMake(0, self.view.frame.origin.y - 44, self.view.frame.size.width, 44);
    [v setBackgroundColor:[FFStyle brightGreen]
                  forState:UIControlStateNormal];
    [v setBackgroundColor:[FFStyle darkerColorForColor:[FFStyle brightGreen]]
                  forState:UIControlStateHighlighted];
    if (target != nil && sel != NULL) {
        [v addTarget:target
                      action:sel
            forControlEvents:UIControlEventTouchUpInside];
    }
    [v addTarget:self
                  action:@selector(closeBanner:)
        forControlEvents:UIControlEventTouchUpInside];
    [self.view.superview addSubview:v];

    UILabel* lab = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.view.frame.size.width - 30, 44)];
    lab.backgroundColor = [UIColor clearColor];
    lab.font = [FFStyle regularFont:14];
    lab.textColor = [FFStyle white];
    lab.text = text;
    lab.numberOfLines = 2;
    lab.userInteractionEnabled = NO;

    [v addSubview:lab];
    v.alpha = 0;

    UIImageView* close = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bannerclose.png"]];
    close.frame = CGRectMake(v.frame.size.width - 16, v.frame.size.height - 16, 8, 16);
    close.contentMode = UIViewContentModeCenter;
    [v addSubview:close];

    [UIView animateWithDuration:animated ? .25f : 0.f
                     animations:^{
                         v.alpha = 1;
                         v.frame = CGRectOffset(v.frame, 0, 44);
                     }];
}

- (void)closeBannerAnimated:(BOOL)animated
{
    if (self.banner) {
        [self closeBanner:self.banner
                 animated:animated];
    }
}

- (void)closeBanner:(UIView*)banner
{
    [self closeBanner:banner
             animated:YES];
}

- (void)closeBanner:(UIView*)banner
           animated:(BOOL)animated
{
    [UIView animateWithDuration: animated ? .25f : 0.f
                     animations:^{
        banner.alpha = 0;
        banner.frame = CGRectOffset(banner.frame, 0, -44);
    } completion:^(BOOL finished)
    {
        if (!finished) {
            return;
        }
        [banner removeFromSuperview];
        _banner = nil;
    }];
}

- (void)showControllerInDrawer:(FFDrawerViewController*)vc minimizedViewController:(FFDrawerViewController*)mvc animated:(BOOL)animated
{
    [self showControllerInDrawer:vc
         minimizedViewController:mvc
                          inView:self.view
                        animated:NO];
}

- (void)showControllerInDrawer:(FFDrawerViewController*)vc
       minimizedViewController:(FFDrawerViewController*)mvc
                        inView:(UIView*)view
               resizeTableView:(UITableView*)tableView
                      animated:(BOOL)animated
{
    __resizingTableView = tableView;
    [self showControllerInDrawer:vc
         minimizedViewController:mvc
                        animated:YES];
}

- (void)showControllerInDrawer:(FFDrawerViewController*)vc
       minimizedViewController:(FFDrawerViewController*)mvc
                        inView:(UIView*)view
                      animated:(BOOL)animated
{
    if (_minimizedDrawerController || _maximizedDrawerController) {
        NSLog(@"trying to show a drawer when there already is one %@ %@", vc, mvc);
        return;
    }
    NSParameterAssert(vc != nil); // require the full vc, but minimized vc is optional

    _drawerIsMinimized = NO;

    _maximizedDrawerController = vc;
    vc.view.frame = CGRectMake(0, 0, view.frame.size.width, DRAWER_HEIGHT);

    CGRect viewFrame = view.frame;
    viewFrame.size.height -= DRAWER_HEIGHT;

    UISwipeGestureRecognizer* minSwipeRecognizer = [[UISwipeGestureRecognizer alloc]
        initWithTarget:self
                action:@selector(swipeDrawer:)];
    minSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    minSwipeRecognizer.delegate = self;
    [vc.view addGestureRecognizer:minSwipeRecognizer];

    if (mvc) {
        _minimizedDrawerController = mvc;
        FFDrawerBackingView* mview = [[FFDrawerBackingView alloc] initWithFrame:
                                                                      CGRectMake(0, viewFrame.size.height, viewFrame.size.width, DRAWER_MINIMIZED_HEIGHT)];
        mview.frameLocked = YES;
        mview.alpha = 0;
        [mview addSubview:mvc.view];
        [view addSubview:mview];

        mvc.view.frame = CGRectMake(0, 0, viewFrame.size.width, DRAWER_MINIMIZED_HEIGHT);

        UISwipeGestureRecognizer* maxSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                                 action:@selector(swipeMinimizedDrawer:)];
        maxSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
        maxSwipeRecognizer.delegate = self;
        [mvc.view addGestureRecognizer:maxSwipeRecognizer];
    }

    [vc viewWillAppear:YES];

    FFDrawerBackingView* mview = [[FFDrawerBackingView alloc] initWithFrame:
                                                                  CGRectMake(0,
                                                                             viewFrame.size.height + DRAWER_HEIGHT,
                                                                             viewFrame.size.width,
                                                                             DRAWER_HEIGHT)];
    [mview addSubview:vc.view];
    [view addSubview:mview];

        [UIView animateWithDuration:.25
                         animations:^{
                             mview.frame = CGRectMake(0, viewFrame.size.height, viewFrame.size.width, DRAWER_HEIGHT);
                             mview.frameLocked = YES; // TODO: remove it hackity hack
                             if (__resizingTableView) {
                                 __resizingTableView.contentInset = UIEdgeInsetsMake(0, 0, DRAWER_HEIGHT, 0);
                             }
                         }
                         completion:^(BOOL finished)
        {
            if (finished) {
                [vc viewDidAppear:YES];
            }
        }];
}

- (void)swipeDrawer:(UISwipeGestureRecognizer*)recognizer
{
    [self minimizeDrawerAnimated:YES];
}

- (void)swipeMinimizedDrawer:(UISwipeGestureRecognizer*)recognizer
{
    [self maximizeDrawerAnimated:YES];
}

- (void)maximizeDrawerAnimated:(BOOL)animated
{
    if (!_minimizedDrawerController) {
        NSLog(@"tried to maximize drawer but there is no minimized controller...");
        WTFLog;
        return;
    }
    if (!_drawerIsMinimized) {
        NSLog(@"tried to maximize drawer that is already maximized");
        return;
    }

    _drawerIsMinimized = NO;

    CGFloat diff = DRAWER_MINIMIZED_HEIGHT - DRAWER_HEIGHT;

    CGRect viewFrame = _maximizedDrawerController.view.superview.superview.frame;
    viewFrame.size.height = viewFrame.size.height + diff;

    [_minimizedDrawerController viewWillDisappear:animated];
    [_maximizedDrawerController viewWillAppear:animated];

    [(FFDrawerBackingView*)_maximizedDrawerController.view.superview setFrameLocked:NO];
    [(FFDrawerBackingView*)_minimizedDrawerController.view.superview setFrameLocked:NO];

        [UIView animateWithDuration: animated ? .25f : 0.f
                         animations:^{
                             _maximizedDrawerController.view.superview.frame = CGRectOffset(_maximizedDrawerController.view.superview.frame,
                                                                                   0, diff);
                             _maximizedDrawerController.view.superview.alpha = 1;
                             _minimizedDrawerController.view.superview.frame = CGRectOffset(_minimizedDrawerController.view.superview.frame,
                                                                                            0, diff);
                             _minimizedDrawerController.view.superview.alpha = 0;
                             if (__resizingTableView) {
                                 __resizingTableView.contentInset = UIEdgeInsetsMake(0, 0, DRAWER_HEIGHT, 0);
                             }
                         }
                         completion:^(BOOL finished)
        {
            if (finished) {
                [_minimizedDrawerController viewDidDisappear:animated];
                [_maximizedDrawerController viewDidAppear:animated];
                [(FFDrawerBackingView*)_maximizedDrawerController.view.superview setFrameLocked:YES];
                [(FFDrawerBackingView*)_minimizedDrawerController.view.superview setFrameLocked:YES];
            }
        }];
}

- (void)minimizeDrawerAnimated:(BOOL)animated
{
    if (!_minimizedDrawerController) {
        NSLog(@"tried to minimize drawer but there is no minimized controller");
        return;
    }
    if (_drawerIsMinimized) {
        NSLog(@"tried to minimize the drawer but it is already minimized");
        return;
    }

    _drawerIsMinimized = YES;

    CGFloat diff = DRAWER_HEIGHT - DRAWER_MINIMIZED_HEIGHT;

    CGRect viewFrame = _maximizedDrawerController.view.superview.superview.frame;
    viewFrame.size.height = viewFrame.size.height + diff;

    [_maximizedDrawerController viewWillDisappear:animated];
    [_minimizedDrawerController viewWillAppear:animated];

    [(FFDrawerBackingView*)_maximizedDrawerController.view.superview setFrameLocked:NO];
    [(FFDrawerBackingView*)_minimizedDrawerController.view.superview setFrameLocked:NO];
    [UIView animateWithDuration: animated ? .25f : 0.f
                     animations:^{
                         _maximizedDrawerController.view.superview.frame = CGRectOffset(_maximizedDrawerController.view.superview.frame,
                                                                               0, diff);
                         _maximizedDrawerController.view.superview.alpha = 0;
                         _minimizedDrawerController.view.superview.frame = CGRectOffset(_minimizedDrawerController.view.superview.frame,
                                                                                        0, diff);
                         _minimizedDrawerController.view.superview.alpha = 1;
                         if (__resizingTableView) {
                             __resizingTableView.contentInset = UIEdgeInsetsMake(0, 0, DRAWER_MINIMIZED_HEIGHT, 0);
                         }
                     }
                     completion:^(BOOL finished)
    {
        if (finished) {
            [_maximizedDrawerController viewDidDisappear:animated];
            [_minimizedDrawerController viewDidAppear:animated];
            [(FFDrawerBackingView*)_maximizedDrawerController.view.superview setFrameLocked:YES];
            [(FFDrawerBackingView*)_minimizedDrawerController.view.superview setFrameLocked:YES];
        }
    }];
}

- (void)closeDrawerAnimated:(BOOL)animated
{
    if (!_maximizedDrawerController) {
        NSLog(@"cant close a drawer that isn't showing...");
        return;
    }

    [(FFDrawerBackingView*)_maximizedDrawerController.view.superview setFrameLocked:NO];
    if (self.minimizedDrawerController) {
        [(FFDrawerBackingView*)_minimizedDrawerController.view.superview setFrameLocked:NO];
    }

    FFDrawerViewController* drawer = (_drawerIsMinimized ? self.minimizedDrawerController : self.maximizedDrawerController);
    [drawer viewWillDisappear:animated];

    CGFloat diff = (_drawerIsMinimized ? DRAWER_MINIMIZED_HEIGHT : DRAWER_HEIGHT);

    CGRect viewRect = drawer.view.superview.superview.frame;
    viewRect.size.height += diff;

        [UIView animateWithDuration: animated ? .25f : 0.f
                         animations:^{
                             drawer.view.superview.superview.frame = viewRect;
                             drawer.view.superview.frame = CGRectOffset(drawer.view.superview.frame, 0, diff);
                             drawer.view.superview.alpha = 0;
                             if (__resizingTableView) {
                                 __resizingTableView.contentInset = UIEdgeInsetsZero;
                             }
                         }
                         completion:^(BOOL finished)
        {
            if (finished) {
                [drawer viewDidDisappear:animated];
                [(FFDrawerBackingView*)_maximizedDrawerController.view.superview setFrameLocked:YES];
                [_maximizedDrawerController.view.superview removeFromSuperview];
                if (self.minimizedDrawerController) {
                    [(FFDrawerBackingView*)_minimizedDrawerController.view.superview setFrameLocked:YES];
                    [_minimizedDrawerController.view.superview removeFromSuperview];
                }
                _maximizedDrawerController = nil;
                _minimizedDrawerController = nil;
                _drawerIsMinimized = NO;
            }
        }];
}

- (void)showMenuController
{
    if (_menuController) {
        NSLog(@"already showing a menu controller");
        return;
    }
    _menuController = [FFMenuViewController new];
    _menuController.delegate = self;
    _menuController.session = (FFSession*)self.session;
    _menuController.view.frame = CGRectMake(0, CGRectGetMaxY(self.view.frame),
                                            self.view.frame.size.width, self.view.frame.size.height);
    [_menuController viewDidLoad];
    [_menuController viewWillAppear:YES];
    _menuController.view.alpha = 0;
    [self.view addSubview:_menuController.view];

    CGFloat topOffset = 0;
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        topOffset = self.topLayoutGuide.length;
    }
    [UIView animateWithDuration: .25f
                     animations: ^{
        _menuController.view.alpha = 1;
        _menuController.view.frame = CGRectMake(0, topOffset, self.view.frame.size.width, self.view.frame.size.height);
    }
                     completion: ^(BOOL finished)
    {
        if (finished) {
            [_menuController viewDidAppear:YES];
        }
    }];
}

- (void)hideMenuController
{
    if (!_menuController) {
        NSLog(@"tried to hide the menu controller there's nothing to hide");
        return;
    }
    [_menuController viewWillDisappear:YES];
    [UIView animateWithDuration:.25 animations:^{
        _menuController.view.alpha = 0;
        _menuController.view.frame = CGRectMake(0, CGRectGetMaxY(self.view.frame),
                                                self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished)
    {
        [_menuController viewDidDisappear:YES];
        [_menuController.view removeFromSuperview];
        _menuController = nil;
    }];
}

#pragma mark - FFMenuViewControllerDelegate

- (void)performMenuSegue:(NSString*)ident
{
    if (!self.menuController) {
        WTFLog;
        return;
    }
    [self hideMenuController];
    [self performSegueWithIdentifier:ident
                              sender:self.menuController];
}

#pragma mark - Ticker

- (FFTickerDataSource*)tickerDataSource
{
    if (!_tickerDataSource) {
        _tickerDataSource = [FFTickerDataSource new];
    }
    return _tickerDataSource;
}

- (FFTickerMaximizedDrawerViewController*)maximizedTicker
{
    if (!_maximizedTicker) {
        _maximizedTicker = [FFTickerMaximizedDrawerViewController new];
        _maximizedTicker.view.backgroundColor = [FFStyle darkGreen];
        _maximizedTicker.session = self.session;
        [self.tickerDataSource addDelegate:_maximizedTicker];
    }
    return _maximizedTicker;
}

- (FFTickerMinimizedDrawerViewController*)minimizedTicker
{
    if (!_minimizedTicker) {
        _minimizedTicker = [FFTickerMinimizedDrawerViewController new];
        _minimizedTicker.view.backgroundColor = [FFStyle darkGreen];
        _minimizedTicker.session = self.session;
        [self.tickerDataSource addDelegate:_minimizedTicker];
    }
    return _minimizedTicker;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.navigationController && self.navigationController.viewControllers.count
        && self.navigationController.viewControllers[0] != self) {
        self.navigationItem.leftBarButtonItems = [FFStyle backBarItemsForController:self];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationPortrait;
}

@end

@implementation FFDrawerBackingView

@end