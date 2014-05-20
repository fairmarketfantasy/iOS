//
//  FFSessionManager.h
//  FMF Football
//
//  Created by Anton Chuev on 5/20/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFSessionManager : NSObject

@property (nonatomic, readonly) NSArray *categories;
@property (nonatomic, readonly) NSString *currentCategoryName;
@property (nonatomic, readonly) NSString *currentSportName;

+ (FFSessionManager*)shared;

- (NSArray *)readCategories;
- (void)saveCategoriesFromDictionaries:(NSArray *)categories;

- (void)saveCurrentCategory:(NSString *)category andSport:(NSString *)sport;

@end
