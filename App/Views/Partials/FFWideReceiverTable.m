//
//  FFWideReceiverTable.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/19/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFWideReceiverTable.h"
#import "FFWideReceiverCell.h"

@implementation FFWideReceiverTable

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;

        [self registerClass:[FFWideReceiverCell class]
     forCellReuseIdentifier:@"ReceiverCell"];
    }
    return self;
}

@end
