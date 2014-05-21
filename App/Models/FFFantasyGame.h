//
//  FFFantasyGame.h
//  FMF Football
//
//  Created by Anton Chuev on 5/21/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFGame.h"
#import "FFDataObject.h"
#import <SBData/SBTypes.h>

@interface FFFantasyGame : FFGame

@property (nonatomic) NSString*  awayTeam;
@property (nonatomic) NSString*  gameDay;
@property (nonatomic) NSString*  homeTeam;
@property (nonatomic) NSString*  network;
@property (nonatomic) NSString*  seasonType;
@property (nonatomic) SBInteger* seasonWeek;
@property (nonatomic) SBInteger* seasonYear;
@property (nonatomic) NSString*  statsId;
@property (nonatomic) NSString*  scheduled;

@end

