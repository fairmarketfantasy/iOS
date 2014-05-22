//
//  FFTeam.h
//  FMF Football
//
//  Created by Anton Chuev on 5/21/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFTeam : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *gameDate;
@property (nonatomic, readonly) NSString *gameName;
@property (nonatomic, readonly) NSString *logoURL;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
