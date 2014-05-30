//
//  FFCategory.h
//  FMF Football
//
//  Created by Anton Chuev on 5/19/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFDataObject.h"

@interface FFCategory : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *title;//for showing in menu
@property (nonatomic, readonly) NSString *note;
@property (nonatomic, readonly) NSArray *sports;//should cantain FFSport objects

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionary;

+ (NSArray *)categoriesFromDictionaries:(NSArray *)categoriesDictionaries;

@end
