//
//  FFSportManager.h
//  FMF Football
//
//  Created by Anton Chuev on 6/12/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FFErrorType)
{
    FFErrorTypeUnknownServerError,
    FFErrorTypeTimeOut,
    FFErrorTypeNoError
};

@class FFSession;
@class FFPlayer;

@protocol FFSportManagerDelegate <NSObject>

- (UIViewController *)selectedController;
- (void)openIndividualPredictionsForPlayer:(FFPlayer *)player;
- (void)updatePagerView;
- (void)shouldSetViewController:(UIViewController *)controller
                      direction:(UIPageViewControllerNavigationDirection)direction
                       animated:(BOOL)animated
                     completion:(void(^)(BOOL))block;

@end

@protocol FFErrorHandlingDelegate <NSObject>

- (BOOL)isError;
- (BOOL)isUnpaid;
- (NSString *)unpaidErrorMessage;
- (NSString *)errorMessage;

@end

@interface FFSportManager : NSObject <FFErrorHandlingDelegate>

- (id)initWithSession:(FFSession *)session;
- (NSArray *)getViewControllers;
- (void)handleError:(NSError *)error;

@property (nonatomic, strong) FFSession *session;
@property (nonatomic, weak) id <FFSportManagerDelegate> delegate;
@property (nonatomic, assign) FFErrorType errorType;
@property (nonatomic, assign) BOOL unpaidSubscription;

@end
