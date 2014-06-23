//
//  FFMarketSet.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 2/27/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFMarketSet.h"
#import "FFSession.h"

@implementation FFMarketSet

+ (NSString*)typeKey:(FFMarketType)key
{
    switch (key) {
        case FFMarketTypeRegularSeason:
            return @"regular_season";
        case FFMarketTypeSingleElimination:
            return @"single_elimination";
        default:
            NSAssert(FALSE, @"Wrong FFMarketType key argument!");
    }
}

- (id)initWithDataObjectClass:(Class)klass
                      session:(SBSession*)session
                   authorized:(BOOL)makeAuthroizedRequests
{
    self = [super initWithDataObjectClass:klass
                                  session:session
                               authorized:makeAuthroizedRequests];
    if (self) {
        self.clearsCollectionBeforeSaving = YES;
    }
    return self;
}

- (void)fetchType:(FFMarketType)type
{
    NSAssert(self.query, @"Query shouldn't be nil!");
    [self refreshWithParameters:@{
                                    @"sport" : [FFSport stringFromSport:self.session.sport],
                                    @"type" : [FFMarketSet typeKey:type]
                                }];
}

- (void)fetchType:(FFMarketType)type completion:(void(^)(void))block
{
    NSAssert(self.query, @"Query shouldn't be nil!");
    [self refreshWithParameters:@{
                                  @"sport" : [FFSport stringFromSport:self.session.sport],
                                  @"type" : [FFMarketSet typeKey:type]
                                  }
                     completion:^{
                         if (block)
                             block();
                     }];
}

@end
