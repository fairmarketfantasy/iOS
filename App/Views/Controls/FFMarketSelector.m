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
        self.leftButton.autoresizingMask = UIViewAutoresizingNone;
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
        if (path.item >= (self.delegate.markets.count - 1)) {
            return;
        }
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:path.item + 1
                                                                         inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                            animated:YES];
       self.selectedMarket = path.item + 1;
    }
}

- (void)setSelectedMarket:(NSUInteger)selectedMarket
{
    if (self.selectedMarket == selectedMarket) {
        return;
    }
    if (self.delegate &&
        self.delegate.markets.count <= selectedMarket) {
        return;
    }
    _selectedMarket = selectedMarket;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedMarket
                                                                     inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:YES];
    if ([self.delegate respondsToSelector:@selector(marketSelected:)]) {
        [self.delegate marketSelected:self.delegate.markets[self.selectedMarket]];
    }
}

- (void)setDelegate:(id<FFMarketSelectorDelegate>)delegate
{
    if (self.delegate == delegate) {
        return;
    }
    _delegate = delegate;
    self.collectionView.dataSource = delegate;
}

- (void)reloadData
{
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
    NSArray* visible = [self.collectionView indexPathsForVisibleItems];
    if (visible.count > 0) {
        NSIndexPath* path = visible.firstObject;
        self.selectedMarket = path.item;
    }
}

@end
