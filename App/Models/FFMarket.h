//
//  FFMarket.h
//  FMF Football
//
//  Created by Samuel Sutch on 9/23/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import "FFDataObject.h"
#import <SBData/SBTypes.h>

@class FFMarketSet;
@class FFGame;
@class FFDate;

@interface FFMarket : FFDataObject

@property(nonatomic) FFDate* closedAt;
@property(nonatomic) NSString* marketDuration;
@property(nonatomic) NSString* name;
@property(nonatomic) FFDate* openedAt;
@property(nonatomic) SBFloat* shadowBetRate;
@property(nonatomic) SBFloat* shadowBets;
@property(nonatomic) SBInteger* sportId;
@property(nonatomic) FFDate* startedAt;
@property(nonatomic) NSString* state;
@property(nonatomic) SBFloat* totalBets;
@property(nonatomic) NSArray* games; // FFGame*

+ (FFMarketSet*)getBulkWithSession:(SBSession*)session
                        authorized:(BOOL)isAuthorizedRequest;

@end
