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
    if ([_currentCategoryName isEqualToString:category] == NO) {
        [[NSUserDefaults standardUserDefaults] setObject:category forKey:kCurrentCategoryKey];
        _currentCategoryName = [category stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    }
    
    if ([_currentSportName isEqualToString:sport] == NO) {
        [[NSUserDefaults standardUserDefaults] setObject:sport forKey:kCurrentSportKey];
        _currentSportName = sport;
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)readCurrentCategoryName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentCategoryKey];
}

- (NSString *)readCurrentSportName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentSportKey];
}

- (NSString *)categoryNameForNetwork
{
    if ([self.currentCategoryName rangeOfString:@" "].location != NSNotFound) {
        return [self.currentCategoryName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    }
    
    return self.currentCategoryName;
}

@end
