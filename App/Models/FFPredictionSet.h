//
//  FFPredictionSet.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/3/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFDataObjectResultSet.h"

@class FFSession;

@interface FFPredictionSet : FFDataObjectResultSet

- (void)fetch;
- (void)fetchWithCompletion:(void(^)(void))block;
- (void)fetchWithParameters:(NSDictionary*)parameters;
- (void)fetchWithParameters:(NSDictionary*)parameters completion:(void(^)(void))block;

@end
