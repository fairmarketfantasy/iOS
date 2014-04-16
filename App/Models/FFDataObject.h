//
//  FFDataObject.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/9/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <SBDataObject.h>

@class FFSession;

@interface FFDataObject : SBDataObject

@property (nonatomic, readonly) FFSession* session;
@property (nonatomic) NSString *sportKey; /** all objects are tied to some sport */

@end
