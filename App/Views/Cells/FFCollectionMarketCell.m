//
//  FFCollectionMarketCell.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/26/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFCollectionMarketCell.h"

@interface FFCollectionMarketCell()

@property(nonatomic) UILabel *noGamesLabel;

@end

@implementation FFCollectionMarketCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _marketLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f,
                                                                 0.f,
                                                                 self.contentView.frame.size.width,
                                                                 30.f)];
        self.marketLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.marketLabel.font = [FFStyle boldFont:17.f];
        self.marketLabel.textColor = [FFStyle darkGreyTextColor];
        self.marketLabel.backgroundColor = [UIColor clearColor];
        self.marketLabel.textAlignment = NSTextAlignmentCenter;
        self.marketLabel.text = NSLocalizedString(@"Market", nil);
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f,
                                                               30.f,
                                                               self.contentView.frame.size.width,
                                                               25.f)];
        self.timeLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        self.timeLabel.font = [FFStyle regularFont:17.f];
        self.timeLabel.textColor = [FFStyle black];
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.text = @"";
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.marketLabel];
        
        self.marketLabel.hidden = YES;//TODO: where this label is used?
        
        self.noGamesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, self.contentView.frame.size.width, 30.f)];
        self.noGamesLabel.center = self.contentView.center;
        self.noGamesLabel.font = [FFStyle blockFont:20.f];
        self.noGamesLabel.textColor = [FFStyle lightGrey];
        self.noGamesLabel.backgroundColor = [UIColor clearColor];
        self.noGamesLabel.textAlignment = NSTextAlignmentCenter;
        self.noGamesLabel.text = NSLocalizedString(@"NO GAMES SCHEDULED", nil);
        [self.contentView addSubview:self.noGamesLabel];
        self.noGamesLabel.hidden = YES;
    }
    return self;
}

- (void)showNoGamesMessage
{
    self.noGamesLabel.hidden = NO;
}

@end
