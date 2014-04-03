//
//  FFIndividualPrediction.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/3/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "SBDataObject.h"

@interface FFIndividualPrediction : SBDataObject

@property(nonatomic) NSString* playerId;
@property(nonatomic) NSString* playerStatId;
@property(nonatomic) NSString* marketName;
@property(nonatomic) NSArray* eventPredictions;
@property(nonatomic) NSString* playerName;
@property(nonatomic) NSString* predictThat;
@property(nonatomic) NSString* award;
@property(nonatomic) NSString* state;
@property(nonatomic) SBDate* gameTime;
@property(nonatomic) SBDate* gameDay;
@property(nonatomic) NSString* gameResult;

@end
