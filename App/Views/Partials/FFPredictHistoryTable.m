//
//  FFPredictHistoryTable.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/28/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFPredictHistoryTable.h"
#import "FFPredictHistoryCell.h"
#import "FFPredictHeader.h"

@implementation FFPredictHistoryTable

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [FFStyle darkGrey];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;

        [self registerClass:[FFPredictHistoryCell class]
     forCellReuseIdentifier:@"PredictCell"];

        // header
        [self setPredictionType:FFPredictionsTypeRoster];
    }
    return self;
}

- (void)setPredictionType:(FFPredictionsType)type
{
    switch (type) {
        case FFPredictionsTypeIndividual:
            self.tableHeaderView = nil;
            break;
        case FFPredictionsTypeRoster:
            self.tableHeaderView = [[FFPredictHeader alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 60.f)];
            break;
        default:
            break;
    }
}

@end
