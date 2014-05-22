//
//  FFTeam.h
//  FMF Football
//
//  Created by Anton Chuev on 5/21/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FFDate;

@interface FFTeam : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) FFDate *gameDate;
@property (nonatomic, readonly) NSString *gameName;
@property (nonatomic, readonly) NSString *logoURL;
@property (nonatomic, readonly) NSNumber *pt;
@property (nonatomic, readonly) NSString *statsId;
@property (nonatomic, readonly) NSString *gameStatsId;

@property (nonatomic, assign, getter = isSelected) BOOL selected;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
