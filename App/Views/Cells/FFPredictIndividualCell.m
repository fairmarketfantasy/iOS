//
//  FFPredictIndividualCell.m
//  FMF Football
//
//  Created by Yuriy Pitomets on 4/3/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFPredictIndividualCell.h"
#import "FFIndividualPrediction.h"
#import "FFSessionManager.h"
#import "FFDate.h"

@implementation FFPredictIndividualCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor colorWithWhite:.94f
                                                             alpha:1.f];

        UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(7.f, 158.f, 306.f, 1.f)];
        separator.backgroundColor = [UIColor colorWithWhite:.8f
                                                      alpha:.5f];
        [self.contentView addSubview:separator];

        UIView* separator2 = [[UIView alloc] initWithFrame:CGRectMake(7.f, 159.f, 306.f, 1.f)];
        separator2.backgroundColor = [UIColor colorWithWhite:1.f
                                                       alpha:.5f];
        [self.contentView addSubview:separator2];
        // labels
        _choiceLabel = [[UILabel alloc] initWithFrame:
                      CGRectMake(10.f, 10.f, 190.f, 25.f)];
        self.choiceLabel.backgroundColor = [UIColor clearColor];
        self.choiceLabel.font = [FFStyle regularFont:19.f];
        self.choiceLabel.textColor = [FFStyle darkGreyTextColor];
        [self.contentView addSubview:self.choiceLabel];
        _eventLabel = [[UILabel alloc] initWithFrame:
                      CGRectMake(10.f, 30.f, 190.f, 25.f)];
        self.eventLabel.backgroundColor = [UIColor clearColor];
        self.eventLabel.font = [FFStyle regularFont:19.f];
        self.eventLabel.textColor = [FFStyle darkGreyTextColor];
        [self.contentView addSubview:self.eventLabel];
        _dayLabel = [[UILabel alloc] initWithFrame:
                     CGRectMake(90.f, 60.f, 80.f, 20.f)];
        self.dayLabel.backgroundColor = [UIColor clearColor];
        self.dayLabel.font = [FFStyle regularFont:12.f];
        self.dayLabel.textColor = [FFStyle darkGreyTextColor];
        [self.contentView addSubview:self.dayLabel];
        _ptLabel = [[UILabel alloc] initWithFrame:
                    CGRectMake(90.f, 90.f, 80.f, 20.f)];
        self.ptLabel.backgroundColor = [UIColor clearColor];
        self.ptLabel.font = [FFStyle regularFont:12.f];
        self.ptLabel.textColor = [FFStyle darkGreyTextColor];
        [self.contentView addSubview:self.ptLabel];
        _predictLabel = [[UILabel alloc] initWithFrame:
                         CGRectMake(90.f, 120.f, 80.f, 30.f)];
        self.predictLabel.adjustsFontSizeToFitWidth = YES;
        self.predictLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.predictLabel.minimumScaleFactor = .8f;
        self.predictLabel.numberOfLines = 2;
        self.predictLabel.backgroundColor = [UIColor clearColor];
        self.predictLabel.font = [FFStyle regularFont:12.f];
        self.predictLabel.textColor = [FFStyle darkGreyTextColor];
        [self.contentView addSubview:self.predictLabel];
        _timeLabel = [[UILabel alloc] initWithFrame:
                      CGRectMake(260.f, 60.f, 60.f, 20.f)];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.font = [FFStyle regularFont:12.f];
        self.timeLabel.textColor = [FFStyle darkGreyTextColor];
        [self.contentView addSubview:self.timeLabel];
        _awaidLabel = [[UILabel alloc] initWithFrame:
                       CGRectMake(260.f, 90.f, 60.f, 20.f)];
        self.awaidLabel.backgroundColor = [UIColor clearColor];
        self.awaidLabel.font = [FFStyle regularFont:12.f];
        self.awaidLabel.textColor = [FFStyle darkGreyTextColor];
        [self.contentView addSubview:self.awaidLabel];
        _resultLabel = [[UILabel alloc] initWithFrame:
                       CGRectMake(260.f, 120.f, 60.f, 20.f)];
        self.resultLabel.backgroundColor = [UIColor clearColor];
        self.resultLabel.font = [FFStyle regularFont:12.f];
        self.resultLabel.textColor = [FFStyle darkGreyTextColor];
        [self.contentView addSubview:self.resultLabel];
        // titles
        UILabel* captionDayLabel = [[UILabel alloc] initWithFrame:
                                    CGRectMake(10.f, 60.f, 70.f, 20.f)];
        captionDayLabel.backgroundColor = [UIColor clearColor];
        captionDayLabel.text = @"○ Day";
        captionDayLabel.font = [FFStyle regularFont:12.f];
        captionDayLabel.textColor = [FFStyle greyTextColor];
        [self.contentView addSubview:captionDayLabel];
        UILabel* captionPTLabel = [[UILabel alloc] initWithFrame:
                                   CGRectMake(10.f, 90.f, 70.f, 20.f)];
        captionPTLabel.backgroundColor = [UIColor clearColor];
        captionPTLabel.text = @"○ PT";
        captionPTLabel.font = [FFStyle regularFont:12.f];
        captionPTLabel.textColor = [FFStyle greyTextColor];
        [self.contentView addSubview:captionPTLabel];
        UILabel* captionPredictLabel = [[UILabel alloc] initWithFrame:
                                        CGRectMake(10.f, 120.f, 70.f, 20.f)];
        captionPredictLabel.backgroundColor = [UIColor clearColor];
        captionPredictLabel.text = @"○ Prediction";
        captionPredictLabel.font = [FFStyle regularFont:12.f];
        captionPredictLabel.textColor = [FFStyle greyTextColor];
        [self.contentView addSubview:captionPredictLabel];
        UILabel* captionTimeLabel = [[UILabel alloc] initWithFrame:
                                     CGRectMake(180.f, 60.f, 80.f, 20.f)];
        captionTimeLabel.backgroundColor = [UIColor clearColor];
        captionTimeLabel.text = @"○ Game Time";
        captionTimeLabel.font = [FFStyle regularFont:12.f];
        captionTimeLabel.textColor = [FFStyle greyTextColor];
        [self.contentView addSubview:captionTimeLabel];
        UILabel* captionAwaidLabel = [[UILabel alloc] initWithFrame:
                                      CGRectMake(180.f, 90.f, 80.f, 20.f)];
        captionAwaidLabel.backgroundColor = [UIColor clearColor];
        captionAwaidLabel.text = @"○ Award";
        captionAwaidLabel.font = [FFStyle regularFont:12.f];
        captionAwaidLabel.textColor = [FFStyle greyTextColor];
        [self.contentView addSubview:captionAwaidLabel];
        UILabel* captionResultLabel = [[UILabel alloc] initWithFrame:
                                      CGRectMake(180.f, 120.f, 80.f, 20.f)];
        captionResultLabel.backgroundColor = [UIColor clearColor];
        captionResultLabel.text = @"○ Result";
        captionResultLabel.font = [FFStyle regularFont:12.f];
        captionResultLabel.textColor = [FFStyle greyTextColor];
        [self.contentView addSubview:captionResultLabel];
    }
    return self;
}

- (void)setupWithPrediction:(FFIndividualPrediction *)prediction
{
    //title
    self.choiceLabel.text = prediction.playerName;
    self.eventLabel.text = prediction.marketName;
    //day
    NSString *dayString = nil;
    NSString *timeString = nil;
    if ([[FFSessionManager shared].currentCategoryName isEqualToString:FANTASY_SPORTS]) {
        dayString = [[FFStyle dayFormatter] stringFromDate:prediction.gameDay];
        timeString = [[FFStyle timeFormatter] stringFromDate:prediction.gameTime];
    } else {
        NSDate *defaultDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
        if ([prediction.gameTime isEqualToDate:defaultDate]) {
            dayString = timeString = @"N/A";
        } else {
            dayString = timeString = [[FFStyle timeFormatter] stringFromDate:prediction.gameTime];
        }
    }
    self.dayLabel.text = dayString;
    //time
    self.timeLabel.text = timeString;
    //pt
    self.ptLabel.text = prediction.predictThat;
    if (prediction.eventPredictions.count > 0) {
        NSDictionary* eventPrediction = prediction.eventPredictions.firstObject;
        if (eventPrediction) {
            self.predictLabel.text = [NSString stringWithFormat:@"%@: %@ %@",
                                      [eventPrediction[@"diff"] isEqualToString:@"less"]
                                      ? @"Under": @"Over", // TODO: refactor it and move to model
                                      eventPrediction[@"value"],
                                      eventPrediction[@"event_type"]];
        }
    }
    
    //award
    self.awaidLabel.text = prediction.award ? prediction.award : @"N/A";
    //result
    NSString *resultString = nil;
    //TODO:field gameResult in fantasy and anon-fantasy has different type
    if ([prediction.state isEqualToString:@"cancelled"]) {
        resultString = @"Didn't play";
    } else if ([prediction.gameResult isKindOfClass:[NSNumber class]]) {
        if (prediction.gameResult)
            resultString = [prediction.gameResult stringValue];
        else
            resultString = @"N/A";
    } else if ([prediction.gameResult isKindOfClass:[NSString class]]) {
        resultString = ((NSString *)prediction.gameResult && [(NSString *)prediction.gameResult isEqualToString:@""] == NO) ?
        (NSString *)prediction.gameResult : @"N/A";
    } else {
        resultString = @"N/A";
    }
    
    self.resultLabel.text = resultString;
}

@end
