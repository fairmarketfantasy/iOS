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
#import "FFLogo.h"

@interface FFDrawerBackingView : UIView

@property(nonatomic) BOOL frameLocked;

@end

@implementation FFDrawerBackingView

@end

@interface FFBaseViewController () <UIGestureRecognizerDelegate>

@property(nonatomic) UITableView* _resizingTableView;
@property(nonatomic) FFDrawerBackingView* minBackingView;
@property(nonatomic) FFDrawerBackingView* maxBackingView;

@end

#define DRAWER_HEIGHT (95.f)
#define DRAWER_MINIMIZED_HEIGHT (48.f)

@implementation FFBaseViewController

- (void)showBanner:(NSString*)text
            target:(id)target
          selector:(SEL)selector
          animated:(BOOL)animated
{
    if (_banner) {
        WTFLog;
        NSLog(@"trying to show a banner when there already is one %@ %@ -> %@",
              text, target, NSStringFromSelector(selector));
        return;
    }
    FFCustomButton* banner = [FFCustomButton buttonWithType:UIButtonTypeCustom];
    banner.frame = CGRectMake(0.f, self.view.frame.origin.y - 44.f,
                              self.view.frame.size.width, 44.f);
    [banner setBackgroundColor:[FFStyle brightGreen]
                      forState:UIControlStateNormal];
    [banner setBackgroundColor:[FFStyle darkerColorForColor:[FFStyle brightGreen]]
                      forState:UIControlStateHighlighted];
    if (target != nil && selector != NULL) {
        [banner addTarget:target
                      action:selector
            forControlEvents:UIControlEventTouchUpInside];
    }
    [banner addTarget:self
                  action:@selector(closeBanner:)
        forControlEvents:UIControlEventTouchUpInside];

    _banner = banner;

    [self.view.superview addSubview:banner];

    UILabel* bannerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.f, 0.f,
                                                                     self.view.frame.size.width - 30.f, 44.f)];
    bannerLabel.backgroundColor = [UIColor clearColor];
    bannerLabel.font = [FFStyle regularFont:14.f];
    bannerLabel.textColor = [FFStyle white];
    bannerLabel.text = text;
    bannerLabel.numberOfLines = 2;
    bannerLabel.userInteractionEnabled = NO;

    [banner addSubview:bannerLabel];
    banner.alpha = 0.f;

    UIImageView* close = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bannerclose.png"]];
    close.frame = CGRectMake(banner.frame.size.width - 16.f,
                             banner.frame.size.height - 16.f, 8.f, 16.f);
    close.contentMode = UIViewContentModeCenter;
    [banner addSubview:close];

    [UIView animateWithDuration:animated ? .25f : 0.f
                     animations:^{
                         banner.alpha = 1.f;
                         banner.frame = CGRectOffset(banner.frame, 0.f, 44.f);
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
        banner.frame = CGRectOffset(banner.frame, 0.f, -44.f);
    } completion:^(BOOL finished)
    {
        if (!finished) {
            return;
        }
        [banner removeFromSuperview];
        _banner = nil;
    }];
}

- (void)showInDrawerMaximizedController:(FFDrawerViewController*)maximizedController
            withMinimizedViewController:(FFDrawerViewController*)minimizedController
                        resizeTableView:(UITableView*)tableView
                               animated:(BOOL)animated
{
    __resizingTableView = tableView;
    [self showInDrawerMaximizedController:maximizedController
              withMinimizedViewController:minimizedController
                                 animated:animated];
}

- (void)showInDrawerMaximizedController:(FFDrawerViewController*)maximizedController
            withMinimizedViewController:(FFDrawerViewController*)minimizedController
                               animated:(BOOL)animated
{
    if (_minimizedDrawerController || _maximizedDrawerController) {
        NSLog(@"trying to show a drawer when there already is one %@ %@", maximizedController, minimizedController);
        return;
    }
    NSParameterAssert(maximizedController != nil);

    _drawerIsMinimized = NO;

    _maximizedDrawerController = maximizedController;
    maximizedController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, DRAWER_HEIGHT);

    CGRect viewFrame = self.view.frame;
    viewFrame.size.height -= DRAWER_HEIGHT;

    UISwipeGestureRecognizer* minSwipeRecognizer = [[UISwipeGestureRecognizer alloc]
        initWithTarget:self
                action:@selector(swipeDrawer:)];
    minSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    minSwipeRecognizer.delegate = self;
    [maximizedController.view addGestureRecognizer:minSwipeRecognizer];

    if (minimizedController) {
        _minimizedDrawerController = minimizedController;
        self.minBackingView = [[FFDrawerBackingView alloc] initWithFrame:
                                                               CGRectMake(0.f,
                                                                          viewFrame.size.height,
                                                                          viewFrame.size.width,
                                                                          DRAWER_MINIMIZED_HEIGHT)];
        self.minBackingView.frameLocked = YES;
        self.minBackingView.alpha = 0;
        [self.minBackingView addSubview:minimizedController.view];
        [self.view addSubview:self.minBackingView];

        minimizedController.view.frame = CGRectMake(0.f, 0.f,
                                                    viewFrame.size.width, DRAWER_MINIMIZED_HEIGHT);
        UISwipeGestureRecognizer* maxSwipeRecognizer = [[UISwipeGestureRecognizer alloc]
            initWithTarget:self
                    action:@selector(swipeMinimizedDrawer:)];
        maxSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
        maxSwipeRecognizer.delegate = self;
        [minimizedController.view addGestureRecognizer:maxSwipeRecognizer];
    }

    [maximizedController viewWillAppear:YES];

    self.maxBackingView = [[FFDrawerBackingView alloc] initWithFrame:
                                                           CGRectMake(0,
                                                                      viewFrame.size.height + DRAWER_HEIGHT,
                                                                      viewFrame.size.width,
                                                                      DRAWER_HEIGHT)];
    [self.maxBackingView addSubview:maximizedController.view];
    [self.view addSubview:self.maxBackingView];

    [UIView animateWithDuration:.25f
                     animations:^{
                         self.maxBackingView.frame = CGRectMake(0,
                                                                viewFrame.size.height,
                                                                viewFrame.size.width,
                                                                DRAWER_HEIGHT);
                         self.maxBackingView.frameLocked = YES; // TODO: remove this hackity hack
                         if (__resizingTableView) {
                             __resizingTableView.contentInset = UIEdgeInsetsMake(0.f, 0.f,
                                                                                 DRAWER_HEIGHT, 0.f);
                         }
                     }
                     completion:^(BOOL finished)
    {
        if (finished) {
            [maximizedController viewDidAppear:YES];
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

    _maximizedDrawerController.view.superview.alpha = 1.f;

    [self.view sendSubviewToBack:self.minBackingView];
    [self.view bringSubviewToFront:self.maxBackingView];

    [UIView animateWithDuration: animated ? .25f : 0.f
                     animations:^{
                         CGRect maxFrame = CGRectOffset(_maximizedDrawerController.view.superview.frame,
                                                        0.f, diff);
                         CGRect minFrame = CGRectOffset(_minimizedDrawerController.view.superview.frame,
                                                        0.f, diff);
                         _maximizedDrawerController.view.superview.frame = maxFrame;
                         _minimizedDrawerController.view.superview.frame = minFrame;

                         _minimizedDrawerController.view.superview.alpha = 0.f;
                         if (__resizingTableView) {
                             __resizingTableView.contentInset = UIEdgeInsetsMake(0.f, 0.f,
                                                                                 DRAWER_HEIGHT, 0.f);
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
                         CGRect maxFrame = CGRectOffset(_maximizedDrawerController.view.superview.frame,
                                                        0.f, diff);
                         CGRect minFrame = CGRectOffset(_minimizedDrawerController.view.superview.frame,
                                                        0.f, diff);
                         _maximizedDrawerController.view.superview.frame = maxFrame;
                         _minimizedDrawerController.view.superview.frame = minFrame;

                         _minimizedDrawerController.view.superview.alpha = 1.f;

                         if (__resizingTableView) {
                             __resizingTableView.contentInset = UIEdgeInsetsMake(0.f, 0.f,
                                                                                 DRAWER_MINIMIZED_HEIGHT, 0.f);
                         }
                     }
                     completion:^(BOOL finished)
    {
        [self.view sendSubviewToBack:self.maxBackingView];
        [self.view bringSubviewToFront:self.minBackingView];

        _maximizedDrawerController.view.superview.alpha = 0.f;

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

    FFDrawerViewController* drawer = _drawerIsMinimized ? self.minimizedDrawerController
                                                        : self.maximizedDrawerController;
    [drawer viewWillDisappear:animated];

    CGFloat diff = _drawerIsMinimized ? DRAWER_MINIMIZED_HEIGHT : DRAWER_HEIGHT;

    CGRect viewRect = drawer.view.superview.superview.frame;
    viewRect.size.height += diff;

    [UIView animateWithDuration: animated ? .25f : 0.f
                     animations:^{
                         drawer.view.superview.superview.frame = viewRect;
                         drawer.view.superview.frame = CGRectOffset(drawer.view.superview.frame, 0.f, diff);
                         drawer.view.superview.alpha = 0.f;
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
    _menuController.view.frame = CGRectMake(0.f, CGRectGetMaxY(self.view.frame),
                                            self.view.frame.size.width, self.view.frame.size.height);
    [_menuController viewDidLoad];
    [_menuController viewWillAppear:YES];
    _menuController.view.alpha = 0.f;
    [self.view addSubview:_menuController.view];

    CGFloat topOffset = 0;
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        topOffset = self.topLayoutGuide.length;
    }
    [UIView animateWithDuration: .25f
                     animations: ^{
        _menuController.view.alpha = 1.f;
        _menuController.view.frame = CGRectMake(0.f, topOffset, self.view.frame.size.width, self.view.frame.size.height);
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
    [UIView animateWithDuration:.25f
                     animations:^{
        _menuController.view.alpha = 0.f;
        _menuController.view.frame = CGRectMake(0.f, CGRectGetMaxY(self.view.frame),
                                                self.view.frame.size.width, self.view.frame.size.height);
    }
                     completion:^(BOOL finished)
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
    self.navigationItem.titleView = [[FFLogo alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 44.f)];
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
