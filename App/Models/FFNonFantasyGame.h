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

@property (nonatomic, readonly) NSString *homeTeamName;
@property (nonatomic, readonly) NSString *awayTeamName;
@property (nonatomic, readonly) NSString *homeTeamLogoURL;
@property (nonatomic, readonly) NSString *awayTeamLogoURL;
@property (nonatomic, readonly) NSString *homeTeamStatsId;
@property (nonatomic, readonly) NSString *awayTeamStatsId;
@property (nonatomic, readonly) NSString *gameStatsId;
@property (nonatomic, readonly) NSNumber *homeTeamPT;
@property (nonatomic, readonly) NSNumber *awayTeamPT;
@property (nonatomic, assign) NSNumber *homeTeamDisablePt;
@property (nonatomic, assign) NSNumber *awayTeamDisablePt;

@property (nonatomic, readonly) FFTeam *homeTeam;
@property (nonatomic, readonly) FFTeam *awayTeam;

+ (void)fetchGamesSession:(SBSession*)session success:(SBSuccessBlock)success failure:(SBErrorBlock)failure;
- (void)setupTeams;

@end
