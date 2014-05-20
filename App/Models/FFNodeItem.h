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
@property(nonatomic) NSArray* children;
@property(nonatomic, copy) void (^action)();

+ (FFNodeItem*)nodeWithTitle:(NSString*)title
                    children:(NSArray*)children;
+ (FFNodeItem*)nodeWithTitle:(NSString*)title;
+ (NSArray*)nodesFromStrings:(NSArray*)strings;
+ (instancetype)nodeFromCategory:(FFCategory *)category;

@end
