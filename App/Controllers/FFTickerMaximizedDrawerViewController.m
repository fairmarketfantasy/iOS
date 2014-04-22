//
//  FFTickerMaximizedDrawerViewController.m
//  FMF Football
//
//  Created by Samuel Sutch on 9/19/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import "FFTickerMaximizedDrawerViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

@implementation FFTickerMaximizedDrawerViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.view.frame = CGRectMake(0, 0, 320, 95);

        CGFloat offset = 10.f;
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2 * offset,
                                                                        offset,
                                                                        self.view.frame.size.width - 4 * offset,
                                                                        15.f)];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.text = NSLocalizedString(@"Real-Time Market Rates", nil);
        titleLabel.font = [FFStyle lightFont:17.f];
        titleLabel.textColor = [FFStyle white];
        titleLabel.backgroundColor = [UIColor clearColor];

        self.errorLabel.frame = CGRectMake(10, 10, 300, 85);
        self.loadingLabel.frame = CGRectMake(42, 0, 300, 95);
        self.activityIndicator.frame = CGRectMake(18, 43, 10, 10);

        [self.view addSubview:titleLabel];

        self.collectionView.frame = CGRectMake(0, 30, 320, 65);
    }
    return self;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
                 cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    UICollectionViewCell* cell = [super collectionView:collectionView
                                cellForItemAtIndexPath:indexPath];

    NSDictionary* player = [self.tickerData objectAtIndex:indexPath.row];
    
    CGFloat xCoord = [self itemHeight];

    NSString* ppgValue = [NSString stringWithFormat:@"%@ PPG", (![player[@"ppg"] isEqual:[NSNull null]]
                                                                        ? [NSString stringWithFormat:@"%.2f", [player[@"ppg"] floatValue]]
                                                                        : @"0")];
    UILabel* ppg = [[UILabel alloc] initWithFrame:CGRectMake(xCoord, 33, 80, 15)];
    ppg.textColor = [FFStyle white];
    ppg.backgroundColor = [FFStyle darkGreen];
    ppg.font = [FFStyle regularFont:14];
    ppg.text = ppgValue;
    [cell.contentView addSubview:ppg];

    double currency = [player[@"buy_price"] doubleValue];
    static NSNumberFormatter* formatter = nil;
    if (!formatter) {
        formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    }
    NSString* costValue = [formatter stringFromNumber:[NSNumber numberWithDouble:currency]];
    UILabel* cost = [[UILabel alloc] initWithFrame:CGRectMake(xCoord, 48, 80, 15)];
    cost.textColor = [FFStyle white];
    cost.backgroundColor = [FFStyle darkGreen];
    cost.font = [FFStyle regularFont:14];
    cost.text = costValue;
    [cell.contentView addSubview:cost];

    return cell;
}

#pragma mark - private

- (NSString*)cellReuseIdentifier
{
    return @"MaxCell";
}

- (CGFloat)itemHeight
{
    return 65.f;
}

@end
