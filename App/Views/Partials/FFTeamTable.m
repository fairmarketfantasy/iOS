//
//  FFTeamTable.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/14/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFTeamTable.h"
#import "FFTeamCell.h"
#import "FFTeamTradeCell.h"
#import "FFMarketsCell.h"
#import "FFAutoFillCell.h"
#import "FFAccountHeader.h"
#import "FFStyle.h"

@implementation FFTeamTable

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [FFStyle darkGrey];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;

        [self registerClass:[FFMarketsCell class]
     forCellReuseIdentifier:@"MarketsCell"];
        [self registerClass:[FFAutoFillCell class]
     forCellReuseIdentifier:@"AutoFillCell"];
        [self registerClass:[FFTeamCell class]
     forCellReuseIdentifier:@"TeamCell"];
        [self registerClass:[FFTeamTradeCell class]
     forCellReuseIdentifier:@"TeamTradeCell"];

        // header
        self.tableHeaderView = [[FFAccountHeader alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 90.f)];
    }
    return self;
}

@end
