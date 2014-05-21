//
//  FFNonFantasyGame.h
//  FMF Football
//
//  Created by Anton Chuev on 5/21/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFGame.h"

@class FFTeam;

@interface FFNonFantasyGame : FFGame

@property (nonatomic) NSString *homeTeamStatsId;
@property (nonatomic) NSString *awayTeamStatsId;
@property (nonatomic) NSString *homeTeamName;
@property (nonatomic) NSString *awayTeamName;
@property (nonatomic) NSString *homeTeamLogoURL;
@property (nonatomic) NSString *awayTeamLogoURL;
@property (nonatomic) NSString *homeTeamPT;
@property (nonatomic) NSString *awayTeamPT;
@property (nonatomic) NSString *gameStatsId;

@property (nonatomic, readonly, getter = homeTeam) FFTeam *homeTeam;
@property (nonatomic, readonly) FFTeam *awayTeam;

+ (void)fetchGamesSession:(SBSession*)session success:(SBSuccessBlock)success failure:(SBErrorBlock)failure;

@end
