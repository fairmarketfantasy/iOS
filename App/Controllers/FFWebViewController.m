//
//  FFWebViewController.m
//  FMF Football
//
//  Created by Samuel Sutch on 10/3/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import "FFWebViewController.h"
#import "FFLogo.h"
#import "FFAlertView.h"

#define ALERT_TAG 0xCCCC

@interface FFWebViewController () <UIWebViewDelegate>

@property(strong, nonatomic) UIWebView* webView;
@property(strong, nonatomic) UIBarButtonItem* stopLoadingButton;
@property(strong, nonatomic) UIBarButtonItem* reloadButton;

@end

@implementation FFWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = [[FFLogo alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 44.f)];
    self.stopLoadingButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                           target:self.webView
                                                                           action:@selector(stopLoading)];
    self.reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                      target:self.webView
                                                                      action:@selector(reload)];
    self.navigationItem.rightBarButtonItems = [FFStyle clearNavigationBarButtonWithText:NSLocalizedString(@"Close", nil)
                                                                            borderColor:[FFStyle white]
                                                                                 target:self
                                                                               selector:@selector(close:)
                                                                          leftElseRight:YES];
//    [self updateState];

    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.backgroundColor = [FFStyle darkGreen];
    self.webView.scalesPageToFit = YES;
    [self.view addSubview:self.webView];

    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        [_webView setTranslatesAutoresizingMaskIntoConstraints:NO];
        id topGuide = self.topLayoutGuide;
        id bottomGuide = self.bottomLayoutGuide;
        NSDictionary* viewsDictionary = NSDictionaryOfVariableBindings(_webView, topGuide, bottomGuide);
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide][_webView][bottomGuide]"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:viewsDictionary]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_webView]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:viewsDictionary]];
    } else {
        _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.webView.delegate = self;
    if (self.URL) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.URL]];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.webView stopLoading];
    self.webView.delegate = nil;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - Helpers

- (UIImage*)leftTriangleImage
{
    static UIImage* image;

    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        CGSize size = CGSizeMake(14.0f, 16.0f);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [[UIColor whiteColor] set];
        [path moveToPoint:CGPointMake(0.0f, 8.0f)];
        [path addLineToPoint:CGPointMake(14.0f, 0.0f)];
        [path addLineToPoint:CGPointMake(14.0f, 16.0f)];
        [path closePath];
        [path fill];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });

    return image;
}

- (UIImage*)rightTriangleImage
{
    UIImage* image = [self leftTriangleImage];
    return [UIImage imageWithCGImage:image.CGImage
                               scale:image.scale
                         orientation:UIImageOrientationDown];
}

- (void)updateState
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.navigationItem.leftBarButtonItems = @[
                                                   self.webView.loading ? self.stopLoadingButton : self.reloadButton,
                                                   ];
    } else {
        self.navigationItem.leftBarButtonItem = self.webView.loading ? self.stopLoadingButton : self.reloadButton;
    }
}

- (void)finishLoad
{
//    [self updateState];
    FFAlertView *alert = (FFAlertView *)[self.view viewWithTag:ALERT_TAG];
    [alert hide];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - button actions

- (void)action:(id)sender
{
    NSArray* activityItems;
    if (self.activityItems) {
        activityItems = [self.activityItems arrayByAddingObject:self.URL];
    } else {
        activityItems = @[
            self.URL
        ];
    }

    UIActivityViewController* vc = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                     applicationActivities:self.applicationActivities];
    if (self.excludedActivityTypes) {
        vc.excludedActivityTypes = self.excludedActivityTypes;
    }

    [self presentViewController:vc
                       animated:YES
                     completion:NULL];
}

#pragma mark - Web view delegate

- (void)webViewDidStartLoad:(UIWebView*)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    FFAlertView *alert = [[FFAlertView alloc] initWithTitle:nil
                                                   messsage:@"Loading..."
                                               loadingStyle:FFAlertViewLoadingStylePlain];
    alert.tag = ALERT_TAG;
    [alert showInView:self.view];
//    [self updateState];
}

- (void)webViewDidFinishLoad:(UIWebView*)webView
{
    [self finishLoad];
    self.URL = self.webView.request.URL;
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error
{
    [self finishLoad];
}

- (void)close:(id)sender
{
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES
                                                                           completion:nil];
}

- (void)done:(id)sender
{
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES
                                                                           completion:nil];
}

@end
