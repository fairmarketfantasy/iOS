//
//  FFEvent.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/2/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFDataObject.h"

@interface FFEvent : FFDataObject

@property(nonatomic) SBInteger* bidMore;
@property(nonatomic) SBInteger* bidLess;
@property(nonatomic) NSString* value;
@property(nonatomic) NSString* name;

+ (void)fetchEventsForMarket:(NSString*)marketId
                      player:(NSString*)statId
                     session:(SBSession*)session
                     success:(SBSuccessBlock)success
                     failure:(SBErrorBlock)failure;

- (void)individualPredictionsForMarket:(NSString*)marketId
                                player:(NSString*)statId
                                roster:(NSString*)rosterId
                                  diff:(NSString*)diff
                               success:(SBSuccessBlock)success
                               failure:(SBErrorBlock)failure;

+ (void)fetchEventsForTeam:(NSString *)teamId
                    inGame:(NSString *)gameId
                   session:(SBSession*)session
                   success:(SBSuccessBlock)success
                   failure:(SBErrorBlock)failure;

@end
