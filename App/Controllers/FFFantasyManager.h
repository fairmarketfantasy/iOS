//
//  FFFantasyManager.h
//  FMF Football
//
//  Created by Anton Chuev on 6/10/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FFPagerController.h"
#import "FFPTController.h"
#import "FFManager.h"

@class FFSession;

@interface FFFantasyManager : FFManager <FFPagerDelegate, FFEventsProtocol>

@end
