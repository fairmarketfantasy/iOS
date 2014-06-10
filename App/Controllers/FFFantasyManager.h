//
//  FFFantasyManager.h
//  FMF Football
//
//  Created by Anton Chuev on 6/10/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FFPagerController.h"

@class FFSession;

@interface FFFantasyManager : NSObject <FFPagerDelegate>

+ (FFFantasyManager*)shared;

- (void)setupWithSession:(FFSession *)session andPagerController:(UIPageViewController *)pager;

@end
