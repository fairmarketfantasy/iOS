//
//  FFContest.h
//  FMF Football
//
//  Created by Samuel Sutch on 9/24/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import "FFDataObject.h"
#import <SBData/SBTypes.h>

@class FFDate;

@interface FFGame : FFDataObject

@property (nonatomic) NSString*  awayTeam;
@property (nonatomic) NSString*  gameDay;
@property (nonatomic) FFDate*    gameTime;
@property (nonatomic) NSString*  homeTeam;
@property (nonatomic) NSString*  network;
@property (nonatomic) NSString*  seasonType;
@property (nonatomic) SBInteger* seasonWeek;
@property (nonatomic) SBInteger* seasonYear;
@property (nonatomic) NSString*  statsId;
@property (nonatomic) NSString*  scheduled;

@end
