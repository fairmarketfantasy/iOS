//
//  FFPredictHistoryTable.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/28/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFPredictHistoryTable.h"
#import "FFPredictHistoryCell.h"
#import "FFPredictIndividualCell.h"
#import "FFNoConnectionCell.h"
#import "FFPredictHeader.h"
#import "Reachability.h"
#import <FlatUIKit.h>

@implementation FFPredictHistoryTable

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [FFStyle darkGrey];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;

        [self registerClass:[FFPredictHistoryCell class] forCellReuseIdentifier:@"PredictCell"];
        [self registerClass:[FFPredictIndividualCell class] forCellReuseIdentifier:@"PredictIndividualCell"];
        [self registerClass:[FFNoConnectionCell class] forCellReuseIdentifier:kNoConnectionCellIdentifier];

        // header
        [self setPredictionType:FFPredictionsTypeRoster
           rosterPredictionType:FFRosterPredictionTypeSubmitted];
    }
    return self;
}

- (void)setPredictionType:(FFPredictionsType)type
     rosterPredictionType:(FFRosterPredictionType)rosterType
{
    if ([self networkStatus] == NotReachable) {
        self.tableHeaderView = nil;
        return;
    }
    
    switch (type) {
        case FFPredictionsTypeIndividual:
            self.tableHeaderView = nil;
            break;
        case FFPredictionsTypeRoster:
        {
            FFPredictHeader* header = [[FFPredictHeader alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 60.f)];
            switch (rosterType) {
                case FFRosterPredictionTypeSubmitted:
                    header.segments.selectedSegmentIndex = 0;
                    break;
                case FFRosterPredictionTypeFinished:
                    header.segments.selectedSegmentIndex = 1;
                    break;
                default:
                    break;
            }
            self.tableHeaderView = header;
            [header.segments addTarget:self
                                action:@selector(segments:)
                      forControlEvents:UIControlEventValueChanged];

        }
            break;
        default:
            break;
    }
}

#pragma mark - button actions

- (void)segments:(FUISegmentedControl*)segments
{
    if (self.historyDelegate) {
        [self.historyDelegate changeHistory:segments];
    }
}

#pragma mark

- (NetworkStatus)networkStatus
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    return [reachability currentReachabilityStatus];
}

@end
