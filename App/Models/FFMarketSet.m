//
//  FFMarketSet.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 2/27/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFMarketSet.h"

@implementation FFMarketSet

+ (NSString*)stringFromSport:(FFMarketSport)sport
{
    return [self sportKey:sport];
}

+ (NSString*)sportKey:(FFMarketSport)key
{
    switch (key) {
    case FFMarketSportNBA:
        return @"NBA";
    case FFMarketSportNFL:
        return @"NFL";
    default:
        NSAssert(FALSE, @"Wrong FFMarketSport key argument!");
    }
}

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
        self.sport = FFMarketSportNBA;
    }
    return self;
}
- (void)setSport:(FFMarketSport)sport
{
    self->_sport = sport;
}

- (void)fetchType:(FFMarketType)type
{
    NSAssert(self.query, @"Query shouldn't be nil!");
    [self refreshWithParameters:@{
                                    @"sport" : [FFMarketSet sportKey:self.sport],
                                    @"type" : [FFMarketSet typeKey:type]
                                }];
}

@end
