//
//  FFWideReceiverTable.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/19/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFWideReceiverTable.h"
#import "FFWideReceiverCell.h"
#import "FFTeamAddCell.h"
#import "FFAccountHeader.h"

@implementation FFWideReceiverTable

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [FFStyle darkGrey];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;

        [self registerClass:[FFWideReceiverCell class]
     forCellReuseIdentifier:@"ReceiverCell"];
        [self registerClass:[FFTeamAddCell class]
     forCellReuseIdentifier:@"TeamAddCell"];

        // header
        self.tableHeaderView = [[FFAccountHeader alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 90.f)];
    }
    return self;
}

@end
