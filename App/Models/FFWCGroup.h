//
//  FFWCGroup.h
//  FMF Football
//
//  Created by Anton on 5/31/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFWCGroup : NSObject

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSMutableArray *teams;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
