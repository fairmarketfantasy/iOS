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

@end
