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
    [self fetchWithParameters:@{}];
}

- (void)fetchWithParameters:(NSDictionary*)parameters
{
    NSAssert(self.query, @"Query shouldn't be nil!");
    NSMutableDictionary* param = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [param addEntriesFromDictionary:@{
                                     @"sport" : [FFSport stringFromSport:self.sport],
                                     @"all" : @"true"
                                     }];
    [self refreshWithParameters:[param copy]];
}

@end
