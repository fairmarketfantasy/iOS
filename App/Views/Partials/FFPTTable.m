//
//  FFPTTable.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/21/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFPTTable.h"
#import "FFPTCell.h"
#import "FFStyle.h"

@implementation FFPTTable

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [FFStyle darkGrey];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [self registerClass:[FFPTCell class]
     forCellReuseIdentifier:@"PTCell"];
    }
    return self;
}

@end
