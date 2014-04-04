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
#import "FFStyle.h"

@implementation FFTeamTable

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [FFStyle darkGrey];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        // cells
        [self registerClass:[FFMarketsCell class]
     forCellReuseIdentifier:@"MarketsCell"];
        [self registerClass:[FFAutoFillCell class]
     forCellReuseIdentifier:@"AutoFillCell"];
        [self registerClass:[FFTeamCell class]
     forCellReuseIdentifier:@"TeamCell"];
        [self registerClass:[FFTeamTradeCell class]
     forCellReuseIdentifier:@"TeamTradeCell"];
    }
    return self;
}

@end
