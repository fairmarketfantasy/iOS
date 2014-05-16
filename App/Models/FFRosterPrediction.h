//
//  FFRosterPrediction.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/3/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFRoster.h"

@interface FFRosterPrediction : FFRoster

- (void)loadRosterSuccess:(SBSuccessBlock)success
                  failure:(SBErrorBlock)failure;

@end
