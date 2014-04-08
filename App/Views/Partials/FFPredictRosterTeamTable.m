//
//  FFPredictRosterTeamTable.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/4/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFPredictRosterTeamTable.h"
#import "FFPredictRosterTeamCell.h"
#import "FFTeamTradeCell.h"

@implementation FFPredictRosterTeamTable

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [FFStyle darkGrey];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        // cells
        [self registerClass:[FFTeamTradeCell class]
     forCellReuseIdentifier:@"TeamTradeCell"];
        [self registerClass:[FFPredictRosterTeamCell class]
     forCellReuseIdentifier:@"PredictRosterTeamCell"];
    }
    return self;
}

@end
