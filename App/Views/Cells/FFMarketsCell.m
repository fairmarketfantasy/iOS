//
//  FFMarketsCell.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/14/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFMarketsCell.h"
#import "FFMarketSelector.h"

@interface FFMarketsCell()

@property(nonatomic) UILabel *noGamesLabel;

@end

@implementation FFMarketsCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [FFStyle white];
        UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(10.f, CGRectGetMaxY(self.contentView.frame) - 1.f,
                                                                     300.f, 1.f)];
        separator.backgroundColor = [FFStyle tableViewSeparatorColor];
        separator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        // market selector
        self.marketSelector = [[FFMarketSelector alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 60.f)];
        self.marketSelector.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.marketSelector];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.noGamesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 18.f, self.contentView.frame.size.width, 30.f)];
//        self.noGamesLabel.center = self.contentView.center;
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
