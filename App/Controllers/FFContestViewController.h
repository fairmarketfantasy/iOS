//
//  FFContestViewController.h
//  FMF Football
//
//  Created by Samuel Sutch on 9/25/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import "FFBaseViewController.h"
#import "FFContestType.h"
#import "FFMarket.h"
#import "FFRoster.h"

typedef NS_ENUM(NSInteger, FFContestViewControllerState) {
    FFContestViewControllerStateNone,
    FFContestViewControllerStateViewContest,
    FFContestViewControllerStateShowRoster,
    FFContestViewControllerStatePickPlayer,
    FFContestViewControllerStateContestEntered,
    FFContestViewControllerStateShowFriendRoster,
    FFContestViewControllerStateContestCompleted
};

@protocol FFContestViewControllerDelegate <NSObject>

- (void)contestController:(id)cont
            didPickPlayer:(NSDictionary*)player;

@end

@interface FFContestViewController : FFBaseViewController <FFContestViewControllerDelegate>

@property(nonatomic) FFContestType* contest;
@property(nonatomic) FFMarket* market;
@property(nonatomic) FFRoster* roster;
@property(nonatomic) id currentPickPlayer; // the current position we are picking or trading
@property(nonatomic, weak) id<FFContestViewControllerDelegate> delegate;
@property(nonatomic) BOOL notMine; // are we looking at what is supposed to be someone elses roster?

- (void)showPickPlayer:(id)player;

@end
