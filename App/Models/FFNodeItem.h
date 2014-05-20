//
//  FFNodeItem.h
//  FMF Football
//
//  Created by Yuriy Pitomets on 2/24/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FFCategory;

typedef NS_ENUM(NSInteger, FFNodeItemType) {
    FFNodeItemTypeLeaf,
    FFNodeItemTypeParent
};

@interface FFNodeItem : NSObject

@property(nonatomic, assign) FFNodeItemType type;
@property(nonatomic, copy) NSString* title;
@property(nonatomic, copy) NSString* categoryTitle;
@property(nonatomic, readonly) BOOL comingSoon;
@property(nonatomic) NSArray* children;
@property(nonatomic, copy) void (^action)();

+ (NSArray*)nodesFromStrings:(NSArray*)strings;
+ (instancetype)nodeFromCategory:(FFCategory *)category;

@end
