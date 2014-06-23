//
//  FFPagerController.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/13/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Reachability;

@protocol FFActiveMarketProtocol <NSObject>



@end

@interface FFPagerController : UIPageViewController {
        Reachability* internetReachability;
}

@end
