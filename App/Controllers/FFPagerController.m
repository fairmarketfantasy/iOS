//
//  FFPagerController.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/13/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFPagerController.h"
#import "FFStyle.h"
#import "FFYourTeamController.h"
#import "FFWideReceiverController.h"
#import "StyledPageControl.h"

@interface FFPagerController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property(nonatomic) StyledPageControl* pager;
@property(nonatomic) FFYourTeamController* teamController;
@property(nonatomic) FFWideReceiverController* receiverController;

@end

@implementation FFPagerController

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.view.backgroundColor = [FFStyle darkGreen];
        self.dataSource = self;
        self.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pager = [StyledPageControl new];
    self.pager.frame = CGRectMake(0.f,
                                  self.view.bounds.size.height - 44.f,
                                  self.view.bounds.size.width,
                                  44.f);
    [self.pager setPageControlStyle:PageControlStyleDefault];
    [self.view addSubview:self.pager];
    [self.view bringSubviewToFront:self.pager];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.teamController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                     bundle:[NSBundle mainBundle]]
        instantiateViewControllerWithIdentifier:@"TeamController"];
    self.receiverController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                         bundle:[NSBundle mainBundle]]
                               instantiateViewControllerWithIdentifier:@"ReceiverController"];

    [self setViewControllers:@[[self getViewControllers].firstObject]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];
    self.pager.numberOfPages = (int)[self getViewControllers].count;
    [self.view bringSubviewToFront:self.pager];
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
     viewControllerBeforeViewController:(UIViewController*)viewController
{
    NSUInteger index = [[self getViewControllers] indexOfObject:viewController];
    if (index == NSNotFound) {
        WTFLog;
        return nil;
    }
//    self.pager.currentPage = (int)index;
    if (index == 0) {
        return nil;
    }
    return [self getViewControllers][--index];
}

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
      viewControllerAfterViewController:(UIViewController*)viewController
{
    NSUInteger index = [[self getViewControllers] indexOfObject:viewController];
    if (index == NSNotFound) {
        WTFLog;
        return nil;
    }
//    self.pager.currentPage = (int)index;
    if (index == [self getViewControllers].count - 1) {
        return nil;
    }
    return [self getViewControllers][++index];
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed
{
    if (!completed) {
        return;
    }
    self.pager.currentPage = (int)[[self getViewControllers] indexOfObject:
                                   self.viewControllers.firstObject];
}

#pragma mark - inheritance

//- (NSInteger)presentationCountForPageViewController:(UIPageViewController*)pageViewController
//{
//    return 2;
//}
//
//- (NSInteger)presentationIndexForPageViewController:(UIPageViewController*)pageViewController
//{
//    return 0;
//}

#pragma mark - private

- (NSArray*)getViewControllers
{
    return @[
             self.teamController,
             self.receiverController
             ];
}

@end
