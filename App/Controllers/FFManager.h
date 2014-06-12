//
//  FFManager.h
//  FMF Football
//
//  Created by Anton Chuev on 6/12/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FFSession;

@protocol FFManagerDelegate <NSObject>

- (void)updatePagerView;
- (void)shouldSetViewController;
- (void)shouldSetViewController:(UIViewController *)controller
                      direction:(UIPageViewControllerNavigationDirection)direction
                       animated:(BOOL)animated
                     completion:(void(^)(BOOL))block;

@end

@interface FFManager : NSObject

- (id)initWithSession:(FFSession *)session;
- (NSArray *)getViewControllers;

@property (nonatomic, strong) FFSession *session;
@property (nonatomic, weak) id <FFManagerDelegate> delegate;

@end
