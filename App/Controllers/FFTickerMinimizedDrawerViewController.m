//
//  FFTickerMinimizedDrawerViewController.m
//  FMF Football
//
//  Created by Samuel Sutch on 9/19/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import "FFTickerMinimizedDrawerViewController.h"

@implementation FFTickerMinimizedDrawerViewController

#pragma mark - private

- (NSString*)cellReuseIdentifier
{
    return @"MinCell";
}

- (CGFloat)itemHeight
{
    return 48.f;
}

@end
