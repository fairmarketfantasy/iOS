//
//  FFEvent.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/2/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "SBDataObject.h"

@interface FFEvent : SBDataObject

@property(nonatomic) BOOL bidMore;
@property(nonatomic) BOOL bidLess;
@property(nonatomic) NSString* value;
@property(nonatomic) NSString* name;

+ (void)fetchEventsForMarket:(NSString*)marketId
                      player:(NSString*)statId
                     session:(SBSession*)session
                     success:(SBSuccessBlock)success
                     failure:(SBErrorBlock)failure;

@end
