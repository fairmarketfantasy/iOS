//
//  FFPlayer.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/1/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "SBDataObject.h"

@class FFDataObjectResultSet;

@interface FFPlayer : SBDataObject

@property(nonatomic) NSString* swappedPlayerName;
@property(nonatomic) NSString* benched;
@property(nonatomic) NSString* nextGameAt;
@property(nonatomic) NSString* benchedGames;
@property(nonatomic) NSString* isEliminated;
@property(nonatomic) NSString* headshotURL;
@property(nonatomic) NSString* locked;
@property(nonatomic) NSString* score;
@property(nonatomic) NSString* sellPrice;
@property(nonatomic) NSString* buyPrice;
@property(nonatomic) NSString* purchasePrice;
@property(nonatomic) NSString* ppg;
@property(nonatomic) NSString* status ;
@property(nonatomic) NSString* jerseyNumber;
@property(nonatomic) NSString* position;
@property(nonatomic) NSString* college;
@property(nonatomic) NSString* weight ;
@property(nonatomic) NSString* height;
@property(nonatomic) NSString* birthdate;
@property(nonatomic) NSString* nameAbbr;
@property(nonatomic) NSString* name;
@property(nonatomic) NSString* sportId;
@property(nonatomic) NSString* team;
@property(nonatomic) NSString* statsId;

+ (void)fetchPlayersForRoster:(NSString*)rosterId
                     position:(NSString*)position
               removedBenched:(BOOL)removedBenched
                      session:(SBSession*)session
                      success:(SBSuccessBlock)success
                      failure:(SBErrorBlock)failure;

@end
