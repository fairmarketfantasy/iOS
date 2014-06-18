//
//  FFSportManager.m
//  FMF Football
//
//  Created by Anton Chuev on 6/12/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFSportManager.h"

@implementation FFSportManager

- (id)initWithSession:(FFSession *)session
{
    self = [super init];
    if (self) {
        self.session = session;
    }
    return self;
}

- (NSArray *)getViewControllers
{
    return @[];
}

- (void)handleError:(NSError *)error
{
    
}

- (void)start
{
    
}

#pragma mark - FFErrorHandlingDelegate

- (BOOL)isError
{
    return self.errorType != FFErrorTypeNoError;
}

- (BOOL)isUnpaid
{
    return self.unpaidSubscription;
}

- (NSString *)unpaidErrorMessage
{
    return @"Your free trial has ended. We hope you have enjoyed playing. To continue please visit our site: https//:predictthat.com";
}

- (NSString *)errorMessage
{
    switch (self.errorType) {
        case FFErrorTypeTimeOut:
            return @"Time Out Error";
        case FFErrorTypeUnknownServerError:
            return @"Unknown Error";
            
        default:
            break;
    }
    
    return nil;
}

@end
