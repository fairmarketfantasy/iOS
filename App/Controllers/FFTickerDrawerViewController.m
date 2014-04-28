//
//  FFTickerDrawerViewController.m
//  FMF Football
//
//  Created by Samuel Sutch on 9/19/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import "FFTickerDrawerViewController.h"
#import "FFSession.h"

@interface FFTickerDrawerViewController ()

@property(nonatomic) UICollectionViewFlowLayout* flowLayout;
/** block the ticker for a period of time */
@property(nonatomic) NSDate* dontTickUntil;
@property(nonatomic) BOOL doTick;
@property(nonatomic) NSUInteger currentTickItem;

@end

#define TICK_INTERVAL ((NSTimeInterval)2.5f)

@implementation FFTickerDrawerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tickerData = @[];
    _flowLayout = [UICollectionViewFlowLayout new];
    _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 48)];
    self.view.backgroundColor = [FFStyle darkGreen];
    self.view.userInteractionEnabled = YES;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 320, 48)
                                         collectionViewLayout:_flowLayout];
    [self.view addSubview:_collectionView];
    
    _errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 38)];
    _errorLabel.numberOfLines = 0;
    _errorLabel.textColor = [FFStyle white];
    _errorLabel.font = [FFStyle boldFont:14.f];
    _errorLabel.textAlignment = NSTextAlignmentCenter;
    _errorLabel.text = NSLocalizedString(@"Error", nil);
    _errorLabel.backgroundColor = [UIColor clearColor];
    _errorLabel.hidden = YES;
    _errorLabel.userInteractionEnabled = NO;
    [self.view insertSubview:_errorLabel
                belowSubview:_collectionView];
    
    _loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(42, 0, 300, 48)];
    _loadingLabel.textColor = [FFStyle white];
    _loadingLabel.font = [FFStyle regularFont:17.f];
    _loadingLabel.text = NSLocalizedString(@"Loading...", nil);
    _loadingLabel.backgroundColor = [UIColor clearColor];
    _loadingLabel.hidden = YES;
    _loadingLabel.userInteractionEnabled = NO;
    [self.view insertSubview:_loadingLabel
                belowSubview:_collectionView];
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                          UIActivityIndicatorViewStyleWhite];
    _activityIndicator.frame = CGRectMake(18, 19, 10, 10);
    _activityIndicator.hidesWhenStopped = YES;
    _activityIndicator.userInteractionEnabled = NO;
    [self.view insertSubview:_activityIndicator
                belowSubview:_collectionView];
    [_activityIndicator stopAnimating];
    
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.alwaysBounceHorizontal = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    
    _currentTickItem = 0;
    
    [self.collectionView registerClass:[UICollectionViewCell class]
            forCellWithReuseIdentifier:[self cellReuseIdentifier]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.tickerData.count == 0) {
        [self tickerShowLoading:nil];
        return;
    }
    [self.collectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _doTick = YES;
    [self tick];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _doTick = NO;
}

- (void)tick
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(tick)
                                               object:nil];
    if (!_doTick) {
        return;
    }
    // don't scroll if we were recently scrolling or something
    if (self.dontTickUntil) {
        NSDate* now = [NSDate date];
        if ([now compare:self.dontTickUntil] == NSOrderedAscending) {
            DebugLog(@"ignoring ticker tick");
            return [self performSelector:@selector(tick)
                              withObject:nil
                              afterDelay:TICK_INTERVAL];
        } else {
            self.dontTickUntil = nil;
            // we just scrolled, so set tickernext to the first visible cell
            if (self.collectionView.indexPathsForVisibleItems.count > 0) {
                _currentTickItem = [(NSIndexPath*)[self.collectionView indexPathsForVisibleItems][0] item];
            }
        }
    }
    // scroll to the next one if available
    NSArray* visible = [self.collectionView indexPathsForVisibleItems];
    if (visible.count > 1) {
        NSIndexPath* next = [NSIndexPath indexPathForItem:_currentTickItem
                                                inSection:0];
        if (next.item < self.tickerData.count) {
            [self.collectionView scrollToItemAtIndexPath:next
                                        atScrollPosition:UICollectionViewScrollPositionLeft
                                                animated:YES];
        }
    }
    _currentTickItem++;
    [self performSelector:@selector(tick)
               withObject:nil
               afterDelay:TICK_INTERVAL];
}

#pragma mark - TickerDataSourceDelegate

- (void)tickerShowLoading:(FFTickerDataSource*)source
{
    self.errorLabel.hidden = YES;
    self.collectionView.hidden = YES;
    self.loadingLabel.hidden = NO;
    [self.activityIndicator startAnimating];
}

- (void)ticker:(FFTickerDataSource*)ticker
     showError:(NSString*)errStr
{
    self.loadingLabel.hidden = YES;
    [self.activityIndicator stopAnimating];
    self.collectionView.hidden = YES;
    self.errorLabel.hidden = NO;
    if (!errStr) {
        errStr = NSLocalizedString(@"Error retrieving live stream", nil);
    }
    self.errorLabel.text = errStr;
}

- (void)tickerGotData:(FFTickerDataSource*)ticker
{
    self.loadingLabel.hidden = YES;
    [self.activityIndicator stopAnimating];
    self.errorLabel.hidden = YES;
    self.collectionView.hidden = NO;
    [self.collectionView reloadData];
    self.tickerData = [ticker.tickerData copy];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return self.tickerData.count;
}

- (CGSize)collectionView:(UICollectionView*)collectionView
                    layout:(UICollectionViewLayout*)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    NSDictionary* player = [self.tickerData objectAtIndex:indexPath.row];

    NSString* nameValue = [NSString stringWithFormat:@"%@ (%@)", player[@"name"], player[@"position"]];
    CGFloat namw = [nameValue sizeWithFont:[FFStyle regularFont:14.f]
                         constrainedToSize:CGSizeMake(150, 100)].width;
    return CGSizeMake(56 + namw, [self itemHeight]);
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
                 cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self cellReuseIdentifier]
                                                                           forIndexPath:indexPath];

    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    NSDictionary* player = [self.tickerData objectAtIndex:indexPath.row];

    CGFloat itemHeight = [self itemHeight];

    UIImageView* img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, itemHeight, itemHeight)];
    img.contentMode = UIViewContentModeScaleAspectFit;
    [cell.contentView addSubview:img];
    [img setImageWithURL:[NSURL URLWithString:player[@"headshot_url"]]
        placeholderImage:[UIImage imageNamed:@"rosterslotempty"]];

    NSString* nameValue = [NSString stringWithFormat:@"%@ (%@)", player[@"name"], player[@"position"]];
    CGFloat namw = [nameValue sizeWithFont:[FFStyle regularFont:14.f]
                         constrainedToSize:CGSizeMake(150, 100)].width;
    UILabel* nam = [[UILabel alloc] initWithFrame:CGRectMake(itemHeight, 15, namw, 15)];
    nam.font = [FFStyle regularFont:14.f];
    nam.textColor = [FFStyle white];
    nam.backgroundColor = [FFStyle darkGreen];
    nam.text = nameValue;
    [cell.contentView addSubview:nam];

    return cell;
}

- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView
                  willDecelerate:(BOOL)decelerate
{
    self.dontTickUntil = [NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval)5.f];
}

#pragma mark - private

- (NSString*)cellReuseIdentifier
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"This method must be implemented in a subclass."
                                 userInfo:nil];
}

- (CGFloat)itemHeight
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"This method must be implemented in a subclass."
                                 userInfo:nil];
}

@end
