//
//  FFRosterTable.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/5/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFRosterTable.h"
#import "FFRosterCell.h"

@implementation FFRosterTable

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;

        [self registerClass:[FFRosterCell class]
            forCellReuseIdentifier:@"RosterCell"];
    }
    return self;
}

@end
