//
//  FFWideReceiverController.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/19/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFBaseViewController.h"

@class FFRoster;

@protocol FFPlayersProtocol <NSObject>

@property(nonatomic, readonly) FFRoster* roster;
@property(nonatomic, readonly) NSArray* positions;

@end

@interface FFWideReceiverController : FFBaseViewController

@property(nonatomic, weak) id<FFPlayersProtocol> delegate;
@property(nonatomic) UITableView* tableView;
- (void)updateHeader;

@end
