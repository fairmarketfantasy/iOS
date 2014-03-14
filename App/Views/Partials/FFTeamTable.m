//
//  FFTeamTable.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/14/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFTeamTable.h"
#import "FFTeamCell.h"
#import "FFMarketsCell.h"
#import "FFUserBitCell.h"

@implementation FFTeamTable

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [FFStyle white];
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;

        [self registerClass:[FFUserBitCell class]
            forCellReuseIdentifier:@"UserBitCell"];
        [self registerClass:[FFMarketsCell class]
            forCellReuseIdentifier:@"MarketsCell"];
        [self registerClass:[FFTeamCell class]
            forCellReuseIdentifier:@"TeamCell"];
    }
    return self;
}

@end
