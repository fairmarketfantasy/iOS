//
//  FFPredictionSet.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/3/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFDataObjectResultSet.h"
#import "FFSportHelper.h"

@class FFSession;

@interface FFPredictionSet : FFDataObjectResultSet

- (void)fetch;
- (void)fetchWithCompletion:(void(^)(void))block;
- (void)fetchWithParameters:(NSDictionary*)parameters;
- (void)fetchWithParameters:(NSDictionary*)parameters completion:(void(^)(void))block;
- (void)fetchWithParameters:(NSDictionary*)parameters session:(FFSession *)session completion:(void(^)(void))block;

@end
