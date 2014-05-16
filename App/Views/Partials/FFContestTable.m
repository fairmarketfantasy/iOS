//
//  FFContestTable.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/11/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFContestTable.h"
#import "FFRosterSlotCell.h"
#import "FFPlayerSelectCell.h"
#import "FFBannerCell.h"
#import "FFContestCell.h"
#import "FFEnterCell.h"
#import "FFEntrantsCell.h"

@implementation FFContestTable

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;

        [self registerClass:[FFBannerCell class]
            forCellReuseIdentifier:@"BannerCell"];
        [self registerClass:[FFContestCell class]
            forCellReuseIdentifier:@"ContestCell"];
        [self registerClass:[FFEnterCell class]
            forCellReuseIdentifier:@"EnterCell"];
        [self registerClass:[FFRosterSlotCell class]
            forCellReuseIdentifier:@"RosterPlayer"];
        [self registerClass:[FFPlayerSelectCell class]
            forCellReuseIdentifier:@"PlayerSelect"];
        [self registerClass:[FFEntrantsCell class]
            forCellReuseIdentifier:@"EntrantsCell"];
    }
    return self;
}

@end
