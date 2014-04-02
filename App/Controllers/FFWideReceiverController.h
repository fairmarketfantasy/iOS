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

@property(nonatomic, readonly) NSString* rosterId;
@property(nonatomic, readonly) NSArray* positions;
@property(nonatomic, readonly) BOOL autoRemovedBenched;

@end

@interface FFWideReceiverController : FFBaseViewController

@property(nonatomic) NSArray* players; // should contain FFPlayer*
@property(nonatomic, weak) id<FFPlayersProtocol> delegate;
@property(nonatomic) UITableView* tableView;
- (void)updateHeader;

@end
