//
//  FFMenuViewController.h
//  FMF Football
//
//  Created by Samuel Sutch on 9/25/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import "FFSession.h"
#import "FFMarketSet.h"
#import "FFBaseViewController.h"

@protocol FFMenuViewControllerDelegate <NSObject>

- (void)performMenuSegue:(NSString*)ident;
@optional
- (void)didUpdateToCategory:(NSString *)category sport:(NSString *)sport;
- (void)logout;

@end

@interface FFMenuViewController : FFBaseViewController

@property(nonatomic, weak) id<FFMenuViewControllerDelegate> delegate;

@end
