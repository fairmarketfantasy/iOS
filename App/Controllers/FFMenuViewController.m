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

@interface FFMenuViewController () <RATreeViewDataSource, RATreeViewDelegate>

@property(nonatomic) RATreeView* tableView;
@property(nonatomic) RATreeView* treeView;
@property(nonatomic, readonly) NSArray* nodes;
@property(nonatomic, readonly) NSDictionary* segueByTitle;

@end

@implementation FFMenuViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 504)];
        self.view.backgroundColor = [UIColor colorWithWhite:0
                                                      alpha:.9];

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

        self.treeView = [[RATreeView alloc] initWithFrame:self.view.bounds];
        self.treeView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.treeView.backgroundColor = [UIColor clearColor];
        self.treeView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.treeView.dataSource = self;
        self.treeView.delegate = self;

        [self.treeView registerClass:[UITableViewCell class]
              forCellReuseIdentifier:@"MenuCell"];
        [self.view addSubview:self.treeView];
    }
    return self;
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
    UITableViewCell* cell = [treeView dequeueReusableCellWithIdentifier:@"MenuCell"];
    FFNodeItem* nodeItem = [item isKindOfClass:[FFNodeItem class]] ? (FFNodeItem*)item : nil;
    if (!nodeItem) {
        WTFLog;
        NSAssert(FALSE, @"Wrong type of item for cell!");
    }
    cell.textLabel.text = NSLocalizedString(nodeItem.title, @"Cell title");
    cell.textLabel.textColor = [FFStyle lightGrey];

    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    cell.selectedBackgroundView.backgroundColor = [FFStyle darkGreen];
    CGFloat fontSize = 18.f;
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
        accessoryName = @"accessory_disclosure";
    }

    [self updateCell:cell
        withAccessoryName:accessoryName];

    // add separator to bottom
    UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(0, 59, cell.contentView.frame.size.width, 1)];
    separator.backgroundColor = [UIColor colorWithWhite:1.f
                                                  alpha:.1f];
    [cell.contentView addSubview:separator];

    cell.backgroundColor = nodeItem.type == FFNodeItemTypeParent ? [FFStyle darkBlue] : [UIColor clearColor];

    return cell;
}

#pragma mark - RATreeViewDelegate

- (CGFloat)treeView:(RATreeView*)treeView
    heightForRowForItem:(id)item
           treeNodeInfo:(RATreeNodeInfo*)treeNodeInfo
{
    return 44;
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
    [self updateCell:[treeView cellForItem:item]
        withAccessoryName:@"accessory_uncollapse"];
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
    [self updateCell:[treeView cellForItem:item]
        withAccessoryName:nodeItem.children.count > 0 ? @"accessory_collapse"
                                                      : @"accessory_uncollapse"];
}

#pragma mark - private

- (void)updateCell:(UITableViewCell*)cell
    withAccessoryName:(NSString*)accessoryName
{
    UIImage* accessoryImage = [UIImage imageNamed:accessoryName];
    UIImageView* accessory = [[UIImageView alloc] initWithFrame:
                                                      CGRectMake(0, 0,
                                                                 accessoryImage.size.width,
                                                                 accessoryImage.size.height)];
    accessory.image = accessoryImage;
    accessory.backgroundColor = [UIColor clearColor];
    cell.accessoryView = accessory;
}

@end
