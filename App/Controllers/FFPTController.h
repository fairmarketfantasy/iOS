//
//  FFPTController.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/21/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFBaseViewController.h"

@class FFPlayer;

@protocol FFEventsProtocol <NSObject>

@property(nonatomic, readonly) NSString* rosterId;
@property(nonatomic, readonly) NSString* marketId;

@property(nonatomic, readonly) NSString *gameStatsId;
@property(nonatomic, readonly) NSString *teamStatsId;

@end

@interface FFPTController : FFBaseViewController

@property(nonatomic, weak) id<FFEventsProtocol> delegate;
@property(nonatomic) FFPlayer* player;

@end
