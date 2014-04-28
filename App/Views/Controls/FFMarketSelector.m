//
//  FFMarketSelector.m
//  FMF Football
//
//  Created by Samuel Sutch on 9/24/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import "FFMarketSelector.h"
#import "FFCollectionMarketCell.h"

@interface FFMarketSelector () <UICollectionViewDelegateFlowLayout>

@property(nonatomic) UICollectionView* collectionView;
@property(nonatomic) UICollectionViewFlowLayout* flowLayout;

@end

@implementation FFMarketSelector

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // flow layout
        _flowLayout = UICollectionViewFlowLayout.new;
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.sectionInset = UIEdgeInsetsZero;
        _flowLayout.minimumInteritemSpacing = 0.f;
        _flowLayout.minimumLineSpacing = 0.f;
        // collectin view
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(45.f,
                                                                             0.f,
                                                                             frame.size.width - 90.f,
                                                                             frame.size.height)
                                             collectionViewLayout:_flowLayout];
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.backgroundColor = [FFStyle white];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[FFCollectionMarketCell class]
            forCellWithReuseIdentifier:@"MarketCell"];
        [self addSubview:_collectionView];
        // left button
        _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.leftButton setImage:[UIImage imageNamed:@"leftshuttle.png"]
                         forState:UIControlStateNormal];
        self.leftButton.frame = CGRectMake(10.f,
                                           0.f,
                                           35.f,
                                           frame.size.height);
        self.leftButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.leftButton.alpha = 0.f;
        [self.leftButton addTarget:self
                            action:@selector(onLeft:)
                  forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.leftButton];
        // right button
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.rightButton setImage:[UIImage imageNamed:@"rightshuttle.png"]
                          forState:UIControlStateNormal];
        self.rightButton.frame = CGRectMake(frame.size.width - 45.f,
                                            0.f,
                                            35.f,
                                            frame.size.height);
        self.rightButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.rightButton.alpha = 0.f;
        [self.rightButton addTarget:self
                             action:@selector(onRight:)
                   forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.rightButton];
    }
    return self;
}

- (void)onLeft:(UIButton*)sender
{
    NSArray* selected = [self.collectionView indexPathsForVisibleItems];
    if (selected && selected.count > 0) {
        NSIndexPath* path = selected.firstObject;
        if (path.item <= 0) {
            return;
        }
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:path.item - 1
                                                                         inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                            animated:YES];
        self.selectedMarket = path.item - 1;
    }
}

- (void)onRight:(UIButton*)sender
{
    NSArray* selected = [self.collectionView indexPathsForVisibleItems];
    if (selected && selected.count > 0) {
        NSIndexPath* path = selected.lastObject;
        if (path.item >= (self.dataSource.markets.count - 1)) {
            return;
        }
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:path.item + 1
                                                                         inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                            animated:YES];
       self.selectedMarket = path.item + 1;
    }
}

- (BOOL)updateSelectedMarket:(NSUInteger)selectedMarket
                    animated:(BOOL)animated
{
    if (self.selectedMarket == selectedMarket) {
        return NO;
    }
    if (self.dataSource &&
        self.dataSource.markets.count <= selectedMarket) {
        return NO;
    }

    _selectedMarket = selectedMarket;
    [self updateButtons];

    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedMarket
                                                                     inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:animated];
    return YES;
}

- (void)setSelectedMarket:(NSUInteger)selectedMarket
{
    if (![self updateSelectedMarket:selectedMarket
                           animated:YES]) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(marketSelected:)]) {
        [self.delegate marketSelected:self.dataSource.markets[self.selectedMarket]];
    }
}

- (void)setDataSource:(id<FFMarketSelectorDataSource>)dataSource
{
    if (self.dataSource == dataSource) {
        return;
    }
    _dataSource = dataSource;
    self.collectionView.dataSource = dataSource;
}

- (void)reloadData
{
    self.leftButton.alpha = 0.f;
    self.rightButton.alpha = 0.f;
    [self updateButtons];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView*)collectionView
                    layout:(UICollectionViewLayout*)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    return CGSizeMake(self.collectionView.frame.size.width,
                      self.collectionView.frame.size.height);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    CGFloat fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    self.selectedMarket = page;
}

#pragma mark - private

- (void)updateButtons
{
    BOOL hideLeft = self.dataSource.markets.count == 0 || _selectedMarket == 0;
    BOOL hideRight =  self.dataSource.markets.count == 0 || _selectedMarket >= self.dataSource.markets.count - 1;

    self.leftButton.alpha = hideLeft ? 0.f : 1.f;
    self.rightButton.alpha = hideRight ? 0.f : 1.f;
}

@end
