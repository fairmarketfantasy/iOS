//
//  SBDataObject+RefreshWithParameters.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 2/27/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "SBDataObject.h"
#import "FFSession.h"

@interface FFDataObjectResultSet : SBDataObjectResultSet

@property (nonatomic, readonly) FFSession* session;

- (void)refreshWithParameters:(NSDictionary*)parameters;
- (void)refreshWithParameters:(NSDictionary*)parameters completion:(void(^)(void))block;

@end
