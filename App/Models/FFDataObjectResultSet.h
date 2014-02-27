//
//  SBDataObject+RefreshWithParameters.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 2/27/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "SBDataObject.h"

@interface FFDataObjectResultSet : SBDataObjectResultSet

- (void)refreshWithParameters:(NSDictionary*)parameters;

@end
