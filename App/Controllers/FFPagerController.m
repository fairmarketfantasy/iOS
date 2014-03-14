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
//#import "StyledPageControl.h"
//#import "FFHomeViewController.h"

@interface FFPagerController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property(nonatomic) FFYourTeamController* teamController;

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
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.teamController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                     bundle:[NSBundle mainBundle]]
                           instantiateViewControllerWithIdentifier:@"TeamController"];

    [self setViewControllers:@[
                               self.teamController
                               ]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
     viewControllerBeforeViewController:(UIViewController*)viewController
{
    return self.teamController;
}

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
      viewControllerAfterViewController:(UIViewController*)viewController
{
    return self.teamController;
}

#pragma mark - inheritance

- (NSInteger)presentationCountForPageViewController:(UIPageViewController*)pageViewController
{
    return 2;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController*)pageViewController
{
    return 0;
}

@end
