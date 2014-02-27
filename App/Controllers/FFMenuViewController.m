//
//  FFMenuViewController.m
//  FMF Football
//
//  Created by Samuel Sutch on 9/25/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import "FFMenuViewController.h"
#import "FFSessionViewController.h"
#import <RATreeView.h>
#import "FFNodeItem.h"
#import "FFMenuCell.h"

@interface FFMenuViewController () <RATreeViewDataSource, RATreeViewDelegate>

@property(nonatomic) RATreeView* treeView;
@property(nonatomic, readonly) NSArray* nodes;
@property(nonatomic, readonly) NSDictionary* segueByTitle;

@end

#define MENU_CELL_ID (@"MenuCell")

@implementation FFMenuViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 504)];

        _nodes = [FFNodeItem nodesFromStrings:
                                 @[
                                     @{
                                         @"Sports" : @[
                                             @"NFL",
                                             @"NBA"
                                         ]
                                     },
                                     @{
                                         @"Fantasy Enternainment" : @[
                                         ]
                                     },
                                     @{
                                         @"Politics" : @[
                                         ]
                                     },
                                     @"My Games",
                                     @"Create Game",
                                     @"Rules",
                                     @"Legal Stuff",
                                     @"Support",
                                     @"Settings"
                                 ]];
        _segueByTitle = @{
            @"My Games" : @"GotoMyGames",
            @"Create Game" : @"GotoCreateGame",
            @"Rules" : @"GotoRules",
            @"Legal Stuff" : @"GotoTerms",
            @"Support" : @"GotoSupport",
            @"Settings" : @"GotoAccount"
        };

        self.treeView = [[RATreeView alloc] initWithFrame:self.view.bounds
                                                    style:RATreeViewStylePlain];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // TODO: make proper MVC in whole project!!!
    self.view.backgroundColor = [UIColor colorWithWhite:0
                                                  alpha:.9];
    self.treeView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.treeView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.treeView.separatorColor = [FFStyle lightGrey];
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7) {
        self.treeView.separatorInset = UIEdgeInsetsZero;
    }
    self.treeView.dataSource = self;
    self.treeView.delegate = self;
    [self.treeView registerClass:[FFMenuCell class]
          forCellReuseIdentifier:MENU_CELL_ID];
    [self.view addSubview:self.treeView];
}

#pragma mark - RATreeViewDataSource

- (NSInteger)treeView:(RATreeView*)treeView
    numberOfChildrenOfItem:(id)item
{
    if (!item) {
        return self.nodes.count;
    }
    if (![item isKindOfClass:[FFNodeItem class]]) {
        WTFLog;
        return 0;
    }
    FFNodeItem* nodeItem = (FFNodeItem*)item;
    return nodeItem.children.count;
}

- (id)treeView:(RATreeView*)treeView
         child:(NSInteger)index
        ofItem:(id)item
{
    if (!item) {
        return self.nodes[index];
    }
    if (![item isKindOfClass:[FFNodeItem class]]) {
        WTFLog;
        return nil;
    }
    FFNodeItem* nodeItem = (FFNodeItem*)item;
    return nodeItem.children[index];
}

- (UITableViewCell*)treeView:(RATreeView*)treeView
                 cellForItem:(id)item
                treeNodeInfo:(RATreeNodeInfo*)treeNodeInfo
{
    FFMenuCell* cell = [treeView dequeueReusableCellWithIdentifier:MENU_CELL_ID];
    FFNodeItem* nodeItem = [item isKindOfClass:[FFNodeItem class]] ? (FFNodeItem*)item : nil;
    if (!nodeItem) {
        WTFLog;
        NSAssert(FALSE, @"Wrong type of item for cell!");
    }
    cell.textLabel.text = NSLocalizedString(nodeItem.title, @"Cell title");
    // set font
    CGFloat fontSize = 17.f;
    cell.textLabel.font = nodeItem.type == FFNodeItemTypeParent ? [FFStyle blockFont:fontSize]
                                                                : [FFStyle regularFont:fontSize];
    // add disclosure indicator
    NSString* accessoryName = @"";
    if (nodeItem.type == FFNodeItemTypeParent) {
        accessoryName = treeNodeInfo.expanded ? @"accessory_uncollapse"
                                              : @"accessory_collapse";
        if (treeNodeInfo.expanded) {
            accessoryName = @"accessory_uncollapse";
        } else {
            accessoryName = nodeItem.children.count > 0 ? @"accessory_collapse"
                                                        : @"accessory_uncollapse";
        }
    } else {
        if (treeNodeInfo.treeDepthLevel > 0) {
            accessoryName = @"accessory_uncheck";
        } else {
            accessoryName = @"accessory_disclosure";
        }
    }
    [cell setAccessoryNamed:accessoryName];
    // set background color
    if (nodeItem.type == FFNodeItemTypeParent) {
        cell.backgroundView.backgroundColor = [FFStyle darkBlue];
    } else if (treeNodeInfo.treeDepthLevel > 0) {
        cell.backgroundView.backgroundColor = [FFStyle darkerColorForColor:[FFStyle darkBlue]];
    } else {
        cell.backgroundView.backgroundColor = [UIColor clearColor];
    }
    return cell;
}

#pragma mark - RATreeViewDelegate

- (CGFloat)treeView:(RATreeView*)treeView
    heightForRowForItem:(id)item
           treeNodeInfo:(RATreeNodeInfo*)treeNodeInfo
{
    return 44.f;
}

- (UITableViewCellEditingStyle)treeView:(RATreeView*)treeView
              editingStyleForRowForItem:(id)item
                           treeNodeInfo:(RATreeNodeInfo*)treeNodeInfo
{
    return UITableViewCellEditingStyleNone;
}

- (void)treeView:(RATreeView*)treeView
    didSelectRowForItem:(id)item
           treeNodeInfo:(RATreeNodeInfo*)treeNodeInfo
{
    if (!self.delegate) {
        NSLog(@"all dressed up with no delegate and no where to go");
        WTFLog;
        return;
    }
    FFNodeItem* nodeItem = [item isKindOfClass:[FFNodeItem class]] ? (FFNodeItem*)item : nil;
    if (!nodeItem) {
        WTFLog;
        NSAssert(FALSE, @"Wrong type of item for cell!");
    }
    if (nodeItem.type == FFNodeItemTypeLeaf) {
        NSString* segueTitle = self.segueByTitle[nodeItem.title];
        if (segueTitle) {
            [self.delegate performMenuSegue:segueTitle];
        }
    }
    [treeView deselectRowForItem:item
                        animated:YES];
}

- (void)treeView:(RATreeView*)treeView
    willExpandRowForItem:(id)item
            treeNodeInfo:(RATreeNodeInfo*)treeNodeInfo
{
    FFMenuCell* currentCell = (FFMenuCell*)[treeView cellForItem:item];
    NSAssert([currentCell isKindOfClass:[FFMenuCell class]], @"wrong cell type, expected FFMenuCell");
    [currentCell setAccessoryNamed:@"accessory_uncollapse"];
}

- (void)treeView:(RATreeView*)treeView
    willCollapseRowForItem:(id)item
              treeNodeInfo:(RATreeNodeInfo*)treeNodeInfo
{
    FFNodeItem* nodeItem = [item isKindOfClass:[FFNodeItem class]] ? (FFNodeItem*)item : nil;
    if (!nodeItem) {
        WTFLog;
        NSAssert(FALSE, @"Wrong type of item for cell!");
    }
    FFMenuCell* currentCell = (FFMenuCell*)[treeView cellForItem:item];
    NSAssert([currentCell isKindOfClass:[FFMenuCell class]], @"wrong cell type, expected FFMenuCell");
    [currentCell setAccessoryNamed:nodeItem.children.count > 0 ? @"accessory_collapse"
                                                               : @"accessory_uncollapse"];
}

@end
