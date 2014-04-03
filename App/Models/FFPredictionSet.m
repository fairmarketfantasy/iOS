//
//  FFPredictionSet.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/3/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFPredictionSet.h"

@implementation FFPredictionSet

- (id)initWithDataObjectClass:(Class)klass
                      session:(SBSession*)session
                   authorized:(BOOL)makeAuthroizedRequests
{
    self = [super initWithDataObjectClass:klass
                                  session:session
                               authorized:makeAuthroizedRequests];
    if (self) {
        self.clearsCollectionBeforeSaving = YES;
        self.sport = FFMarketSportNBA;
    }
    return self;
}

- (void)fetch
{
    NSAssert(self.query, @"Query shouldn't be nil!");
    [self refreshWithParameters:@{
                                  @"sport" : [FFSport stringFromSport:self.sport],
                                  @"all" : @"true"
                                  }];
}

@end
