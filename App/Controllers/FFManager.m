//
//  FFManager.m
//  FMF Football
//
//  Created by Anton Chuev on 6/12/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFManager.h"

@implementation FFManager

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

#pragma mark - FFErrorHandlingDelegate

- (BOOL)isError
{
    return self.errorType != FFErrorTypeNoError;
}

- (NSString *)errorMessage
{
    switch (self.errorType) {
        case FFErrorTypeTimeOut:
            return @"Time Out Error";
        case FFErrorTypeUnknownServerError:
            return @"Unknown Server Error";
        case FFErrorTypeUnpaid:
            return @"Your free trial has ended. We hope you have enjoyed playing. To continue please visit our site: https//:predictthat.com";
            
        default:
            break;
    }
    
    return nil;
}

@end
