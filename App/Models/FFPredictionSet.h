//
//  FFPredictionSet.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/3/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFDataObjectResultSet.h"
#import "FFSport.h"

@interface FFPredictionSet : FFDataObjectResultSet

- (void)fetch;
- (void)fetchWithParameters:(NSDictionary*)parameters;

@end
