//
//  FFControllerProtocol.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/24/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FFSession;

@protocol FFControllerProtocol <NSObject>

@property(nonatomic) FFSession* session;

@end
