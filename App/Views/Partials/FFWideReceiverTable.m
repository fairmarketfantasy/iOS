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
#import "FFNoConnectionCell.h"
#import "FFMarketsCell.h"

@implementation FFWideReceiverTable

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [FFStyle darkGrey];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        // cells
        [self registerClass:[FFWideReceiverCell class]
     forCellReuseIdentifier:kWideRecieverCellIdentifier];
        [self registerClass:[FFMarketsCell class]
     forCellReuseIdentifier:kMarketsCellIdentifier];
        [self registerClass:[FFTeamAddCell class]
     forCellReuseIdentifier:kTeamAddCellIdentifier];
        [self registerClass:[FFNoConnectionCell class]
     forCellReuseIdentifier:kNoConnectionCellIdentifier];
        [self registerClass:[UITableViewCell class]
     forCellReuseIdentifier:kPickerCellIdentifier];
    }
    return self;
}

@end
