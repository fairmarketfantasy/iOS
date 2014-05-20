//
//  FFNodeItem.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 2/24/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFNodeItem.h"
#import "FFCategory.h"
#import "FFSport.h"

@implementation FFNodeItem

+ (FFNodeItem*)nodeWithTitle:(NSString*)title
{
    return [self nodeWithTitle:title
                      children:@[
                               ]
                          type:FFNodeItemTypeLeaf];
}

+ (FFNodeItem*)nodeWithTitle:(NSString*)title children:(NSArray*)children
{
    return [self nodeWithTitle:title
                      children:children
                          type:FFNodeItemTypeParent];
}

+ (NSArray*)nodesFromStrings:(NSArray*)strings
{
    NSArray* nodes = [self nodesFromItems:strings];
    NSMutableArray* children = [nodes mutableCopy];
    while (children.count > 0) {
        NSArray* currentChildren = [children copy];
        [children removeAllObjects];
        for (FFNodeItem* node in currentChildren) {
            [node convertChildren];
            [children addObjectsFromArray:node.children];
        }
    }
    return nodes;
}

#pragma mark - private

+ (FFNodeItem*)nodeWithTitle:(NSString*)title
                    children:(NSArray*)children
                        type:(FFNodeItemType)type
{
    return [[FFNodeItem alloc] initWithTitle:title
                                    children:children
                                        type:type];
}

- (id)initWithTitle:(NSString*)title
           children:(NSArray*)children
               type:(FFNodeItemType)type
{
    self = [super init];
    if (self) {
        self.title = title;
        self.children = children;
        self.type = type;
    }
    return self;
}

/**
 *  Convert children NSArray from NSStrings or NSDictionaries to FFNodeItems.
 *  other types ignored.
 */
- (void)convertChildren
{
    if (self.children.count) {
        self.children = [FFNodeItem nodesFromItems:self.children];
    }
}

/**
 *  Convert NSArray of NSStrings or NSDictionaries to NSArray of FFNodeItems.
 *
 *  @param items NSArray of one of NSString or NSDictionary.
 *
 *  @return NSArray of FFNodeItem.
 */
+ (NSArray*)nodesFromItems:(NSArray*)items
{
    NSMutableArray* nodes = [NSMutableArray arrayWithCapacity:items.count];
    for (id item in items) {
        NSArray* subNodes = [self nodesFromItem:item];
        [nodes addObjectsFromArray:subNodes];
    }
    return [nodes copy];
}

/**
 *  Try convert NSString or NSDictionary to NSArray of FFNodeItems if possible.
 *
 *  @param item SString or NSDictionary.
 *  other types ignored.
 *
 *  @return NSArray of FFNodeItems.
  */
+ (NSArray*)nodesFromItem:(id)item
{
    NSMutableArray* nodes = [NSMutableArray arrayWithCapacity:9];
    if ([item isKindOfClass:[NSString class]]) {
        NSString* string = (NSString*)item;
        FFNodeItem* node = [FFNodeItem nodeWithTitle:string];
        [nodes addObject:node];
    } else if ([item isKindOfClass:[NSDictionary class]]) {
        NSDictionary* hash = (NSDictionary*)item;
        for (NSString* key in hash.allKeys) {
            NSArray* childItems = hash[key];
            FFNodeItem* node = [FFNodeItem nodeWithTitle:key
                                                children:childItems];
            [nodes addObject:node];
        }
    }
    return [nodes copy];
}

/**
 *  Create node from category object
 *
 *  @param category FFCategory.
 *
 *  @return FFNodeItem.
 */
+ (instancetype)nodeFromCategory:(FFCategory *)category
{
    if ([category.note isEqualToString:@"COMING SOON"]) {
        return [self nodeWithTitle:category.name children:@[]];
    }
    
    NSMutableArray *children = [NSMutableArray arrayWithCapacity:category.sports.count];
    for (FFSport *sport in category.sports) {
        if (sport.isActive == YES) {
            FFNodeItem *childNode = [FFNodeItem nodeWithTitle:sport.name children:@[] type:FFNodeItemTypeLeaf];
            [children addObject:childNode];
        }
    }
    
    return [self nodeWithTitle:category.name children:children];
}

@end
