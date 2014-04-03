//
//  FFMarketSet.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 2/27/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFDataObjectResultSet.h"
#import "FFSport.h"

typedef NS_ENUM(NSInteger, FFMarketType) {
    FFMarketTypeSingleElimination,
    FFMarketTypeRegularSeason
};

@interface FFMarketSet : FFDataObjectResultSet

@property(nonatomic, assign) FFMarketSport sport;
- (void)fetchType:(FFMarketType)type;

@end
