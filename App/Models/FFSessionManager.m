//
//  FFSessionManager.m
//  FMF Football
//
//  Created by Anton Chuev on 5/20/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFSessionManager.h"
#import "FFCategory.h"

#define kCategoriesKey @"Categories"
#define kCurrentCategoryKey @"CurrentCategory"
#define kCurrentSportKey @"CurrentSport"

@implementation FFSessionManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _categories = [self readCategories];
        _currentCategoryName = [self readCurrentCategoryName];
        _currentSportName = [self readCurrentSportName];
    }
    
    return self;
}

+ (FFSessionManager*)shared
{
    static dispatch_once_t onceToken;
    static FFSessionManager* shared;
    dispatch_once(&onceToken, ^{
        shared = [self new];
    });
    return shared;
}

- (NSArray *)readCategories
{
    NSArray *savedCategories = [[NSUserDefaults standardUserDefaults] objectForKey:kCategoriesKey];
    if (savedCategories.count > 0) {
        return [FFCategory categoriesFromDictionaries:savedCategories];
    }
    
    return [NSArray array];
}

- (void)saveCategoriesFromDictionaries:(NSArray *)categoriesDictionaries
{
    [[NSUserDefaults standardUserDefaults] setObject:categoriesDictionaries forKey:kCategoriesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _categories = [FFCategory categoriesFromDictionaries:categoriesDictionaries];
}

- (void)saveCurrentCategory:(NSString *)category andSport:(NSString *)sport
{
    [[NSUserDefaults standardUserDefaults] setObject:category forKey:kCurrentCategoryKey];
    [[NSUserDefaults standardUserDefaults] setObject:sport forKey:kCurrentSportKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _currentCategoryName = category;
    _currentSportName = sport;
}

- (NSString *)readCurrentCategoryName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentCategory"];
}

- (NSString *)readCurrentSportName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentSport"];
}

@end
