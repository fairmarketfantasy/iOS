//
//  FFMenuViewController.h
//  FMF Football
//
//  Created by Samuel Sutch on 9/25/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import "FFSession.h"
#import "FFMarketSet.h"

@protocol FFMenuViewControllerDelegate <NSObject>

- (void)performMenuSegue:(NSString*)ident;
@optional
- (void)didUpdateToNewSport:(FFMarketSport)sport;
- (FFMarketSport)currentMarketSport;
- (void)logout;

@end

@interface FFMenuViewController : UIViewController

@property(nonatomic, weak) id<FFMenuViewControllerDelegate> delegate;
@property(nonatomic) FFSession* session;

@end
