//
//  FFPTHeader.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 3/6/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFPTHeader.h"
#import "FFStyle.h"

@interface FFPTHeader ()

@property(nonatomic, readonly) UILabel* titleLabel;

@end

@implementation FFPTHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [FFStyle white];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.f, 0.f, 320.f, 50.f)];
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [FFStyle lightFont:26.f];
        self.titleLabel.textColor = [FFStyle greyTextColor];
        [self addSubview:self.titleLabel];
        // background
        self.backgroundColor = [UIColor colorWithWhite:.9f
                                                 alpha:1.f];
        UIView* topSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f,
                                                                        320.f, 1.f)];
        topSeparator.backgroundColor = [UIColor colorWithWhite:.8f
                                                         alpha:1.f];
        [self addSubview:topSeparator];
        UIView* bottomSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.f, 39.f,
                                                                            320.f, 1.f)];
        bottomSeparator.backgroundColor = [UIColor colorWithWhite:.8f
                                                             alpha:1.f];
        [self addSubview:bottomSeparator];
    }
    return self;
}

- (NSString*)title
{
    return self.titleLabel.text;
}

- (void)setTitle:(NSString*)title
{
    NSMutableAttributedString* attributedTitle = [[NSMutableAttributedString alloc]
                                                  initWithString: [NSString stringWithFormat:@"%@ %@", title,
                                                                   NSLocalizedString(@"PT25", nil)]
                                                  attributes:@{
                                                               NSFontAttributeName : self.titleLabel.font,
                                                               NSForegroundColorAttributeName : self.titleLabel.textColor
                                                               }];
    NSRange lastWord = [attributedTitle.string rangeOfString:@" "
                                                     options:NSBackwardsSearch];
    lastWord.location++;
    lastWord.length = attributedTitle.length - lastWord.location;

    [attributedTitle beginEditing];
    [attributedTitle addAttribute:NSForegroundColorAttributeName
                            value:[FFStyle brightRed]
                            range:lastWord];
    [attributedTitle endEditing];
    
    self.titleLabel.attributedText = attributedTitle;
}

@end
