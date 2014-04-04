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
#import "FFLogo.h"
#import "TransitionDelegate.h"
#import "FFNavigationBarItemView.h"
#import <libextobjc/EXTScope.h>
#import "FFAlertView.h"
#import "FFSport.h"

@interface FFMenuViewController () <RATreeViewDataSource, RATreeViewDelegate>

@property(nonatomic) RATreeView* treeView;
@property(nonatomic, readonly) NSArray* nodes;
@property(nonatomic, readonly) NSDictionary* segueByTitle;
@property(nonatomic) TransitionDelegate* customTransitioningDelegate;

@end

#define MENU_CELL_ID (@"MenuCell")

@implementation FFMenuViewController

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 504)];

        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            self.modalPresentationStyle = UIModalPresentationCustom; // transparency fix
            self.customTransitioningDelegate = [TransitionDelegate new];
            self.transitioningDelegate = self.customTransitioningDelegate;
        } else {
            self.modalPresentationStyle = UIModalPresentationCurrentContext;
        }

        _nodes = [FFNodeItem nodesFromStrings:
                                 @[
                                     @{
                                         @"Sports" : @[
                                             @"NFL",
                                             @"NBA"
                                         ]
                                     },
                                     @{
                                         @"Enternainment" : @[
                                         ]
                                     },
                                     @{
                                         @"Politics" : @[
                                         ]
                                     },
                                     @"Predictions",
                                     @"Rules",
                                     @"How it works  |  Support",
                                     @"Subscription Terms",
                                     @"Settings",
                                     @"Sign Out"
                                 ]];
        _segueByTitle = @{
            @"Predictions" : @"GotoPredictions",
            @"Rules" : @"GotoRules",
            @"How it works  |  Support" : @"GotoSupport",
            @"Subscription Terms" : @"GotoTerms",
            @"Settings" : @"GotoAccount",
        };

        // left bar item
        FFNavigationBarItemView* leftItem = [[FFNavigationBarItemView alloc] initWithFrame:[FFStyle itemRect]];
        UIButton* globalMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [globalMenuButton setImage:[UIImage imageNamed:@"globalmenu"]
                          forState:UIControlStateNormal];
        [globalMenuButton addTarget:self
                             action:@selector(globalMenuButton:)
                   forControlEvents:UIControlEventTouchUpInside];
        [globalMenuButton setImage:[UIImage imageNamed:@"globalmenu-highlighted"]
                          forState:UIControlStateHighlighted];
        globalMenuButton.contentMode = UIViewContentModeScaleAspectFit;
        globalMenuButton.frame = [FFStyle itemRect];
        [leftItem addSubview:globalMenuButton];
        // status bar fix for iOS 7
        CGFloat navBarOffset = 0.f;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            navBarOffset = 20.f;
            UIImageView* fixbar = [[UIImageView alloc] initWithImage:
                                   [[UINavigationBar appearance] backgroundImageForBarMetrics:UIBarMetricsDefault]];
            fixbar.frame = CGRectMake(0.f, 0.f, 320.f, navBarOffset);
            fixbar.backgroundColor = [UINavigationBar appearance].backgroundColor;
            [self.view addSubview:fixbar];
        }

        // navigation bar
        UINavigationItem* buttonCarrier = [[UINavigationItem alloc] initWithTitle:@""];
        UINavigationBar* navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.f, navBarOffset,
                                                                                           320.f, 44.f)];
        navigationBar.items = @[buttonCarrier];
        [self.view addSubview:navigationBar];

        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            UIBarButtonItem* spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                       target:nil
                                                                                       action:NULL];
            spaceItem.width = -16.f;
            buttonCarrier.leftBarButtonItems = @[
                                                 spaceItem,
                                                 [[UIBarButtonItem alloc] initWithCustomView:leftItem]
                                                 ];
        } else {
            buttonCarrier.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftItem];
        }
        // title
        buttonCarrier.titleView = [[FFLogo alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 44.f)];
        // tree view
        CGFloat offset = navigationBar.frame.size.height + navigationBar.frame.origin.y;
        CGRect treeFrame = self.view.bounds;
        treeFrame.origin.y += offset;
        treeFrame.size.height -= offset;
        self.treeView = [[RATreeView alloc] initWithFrame:treeFrame
                                                    style:RATreeViewStylePlain];
        [self.view addSubview:self.treeView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // TODO: make proper MVC in whole project!!!
    self.view.backgroundColor = [UIColor colorWithWhite:0.f
                                                  alpha:.9f];
    self.treeView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.treeView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.treeView.separatorColor = [FFStyle lightGrey];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.f) {
        self.treeView.separatorInset = UIEdgeInsetsZero;
    }
    self.treeView.dataSource = self;
    self.treeView.delegate = self;
    [self.treeView registerClass:[FFMenuCell class]
          forCellReuseIdentifier:MENU_CELL_ID];
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
        FFNodeItem* parent = self.nodes[index];
        [self declareOnTouchCellActionsForItem:parent];
        return parent;
    }
    if (![item isKindOfClass:[FFNodeItem class]]) {
        WTFLog;
        return nil;
    }
    NSParameterAssert([item isKindOfClass:[FFNodeItem class]]);
    FFNodeItem* nodeItem = (FFNodeItem*)item;
    FFNodeItem* child = nodeItem.children[index];
    [self declareOnTouchCellActionsForItem:child];
    return child;
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
            if ([self.delegate respondsToSelector:@selector(currentMarketSport)]
                    &&
                [[FFSport stringFromSport:[self.delegate currentMarketSport]]
                    isEqualToString:nodeItem.title]) {
                accessoryName = @"accessory_check";
            } else {
                accessoryName = @"accessory_uncheck";
            }
        } else {
            accessoryName = @"accessory_disclosure";
        }
    }
    [cell setAccessoryNamed:accessoryName];
    // set background color
    if (nodeItem.type == FFNodeItemTypeParent) {
        cell.backgroundView.backgroundColor = [FFStyle brightBlue];
        cell.separator.backgroundColor = [UIColor colorWithRed:36.f / 255.f
                                                         green:79.f / 255.f
                                                          blue:113.f / 255.f
                                                         alpha:1.f];
    } else if (treeNodeInfo.treeDepthLevel > 0) {
        cell.backgroundView.backgroundColor = [UIColor colorWithRed:36.f / 255.f
                                                              green:79.f / 255.f
                                                               blue:113.f / 255.f
                                                              alpha:1.f];
        cell.separator.backgroundColor = [UIColor clearColor];
    } else {
        cell.backgroundView.backgroundColor = [UIColor clearColor];
        cell.separator.backgroundColor = [FFStyle darkGrey];
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
    if (nodeItem.action) {
        nodeItem.action();
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

#pragma mark - private

- (void)declareOnTouchCellActionsForItem:(FFNodeItem*)item
{
    NSParameterAssert([item isKindOfClass:[FFNodeItem class]]);
    @weakify(self)
    if (item.type != FFNodeItemTypeLeaf || item.action) {
        if ([item.title isEqualToString:@"Enternainment"] ||
            [item.title isEqualToString:@"Politics"]) {
            item.action = ^{
                @strongify(self)
                [[[FFAlertView alloc] initWithTitle:nil
                                            message:NSLocalizedString(@"Coming soon!", nil)
                                  cancelButtonTitle:nil
                                    okayButtonTitle:NSLocalizedString(@"Ok", nil)
                                           autoHide:YES] showInView:self.view];
            };
        }
        return;
    }
    if ([item.title isEqualToString:@"NBA"]) {
        item.action = ^{
            @strongify(self)
            if ([self.delegate respondsToSelector:@selector(didUpdateToNewSport:)]) {
                [self.delegate didUpdateToNewSport:FFMarketSportNBA];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        };
    } else if ([item.title isEqualToString:@"NFL"]) {
        item.action = ^{
            @strongify(self)
            if ([self.delegate respondsToSelector:@selector(didUpdateToNewSport:)]) {
                [self.delegate didUpdateToNewSport:FFMarketSportNFL];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        };
    } else if ([item.title isEqualToString:@"Sign Out"]) {
        item.action = ^{
            @strongify(self)
            [self dismissViewControllerAnimated:YES completion:^{
                if ([self.delegate respondsToSelector:@selector(logout)]) {
                    [self.delegate logout];
                }
            }];
        };
    } else {
        __block FFNodeItem* blockItem = item;
        item.action = ^{
            @strongify(self)
            [self dismissViewControllerAnimated:YES completion:^{
                if (self.delegate) {
                    [self.delegate performMenuSegue:self.segueByTitle[blockItem.title]];
                }
            }];
        };
    }
}

#pragma mark - button actions

- (void)globalMenuButton:(UIButton*)button
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

@end
