//
//  FFManager.h
//  FMF Football
//
//  Created by Anton Chuev on 6/12/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FFErrorType)
{
    FFErrorTypeUnknownServerError,
    FFErrorTypeUnpaid,
    FFErrorTypeTimeOut,
    FFErrorTypeNoError
};

@class FFSession;
@class FFPlayer;

@protocol FFManagerDelegate <NSObject>

- (void)openIndividualPredictionsForPlayer:(FFPlayer *)player;
- (void)updatePagerView;
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
@property (nonatomic, assign) FFErrorType errorType;

@end
