//
//  FFWCGame.h
//  FMF Football
//
//  Created by Anton on 5/31/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FFDate;
@class FFWCTeam;

@interface FFWCGame : NSObject

@property (nonatomic, readonly) NSString *statsId;
@property (nonatomic, readonly) FFWCTeam *homeTeam;
@property (nonatomic, readonly) FFWCTeam *guestTeam;
@property (nonatomic, readonly) FFDate *date;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
