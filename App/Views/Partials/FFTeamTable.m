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
#import "FFNoConnectionCell.h"
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
     forCellReuseIdentifier:kMarketsCellIdentifier];
        [self registerClass:[FFAutoFillCell class]
     forCellReuseIdentifier:kAutoFillCellIdentifier];
        [self registerClass:[FFTeamCell class]
     forCellReuseIdentifier:kTeamCellIdentifier];
        [self registerClass:[FFTeamTradeCell class]
     forCellReuseIdentifier:kTeamTradeCellIdentifier];
        [self registerClass:[FFNoConnectionCell class]
     forCellReuseIdentifier:kNoConnectionCellIdentifier];
    }
    return self;
}

@end
