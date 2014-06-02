//
//  FFWCController.m
//  FMF Football
//
//  Created by Anton on 6/1/14.
//  Copyright (c) 2014 FairMarketFantasy. All rights reserved.
//

#import "FFWCController.h"
#import "FFWCManager.h"
#import "FFWCCell.h"
#import "FFWCGameCell.h"
#import "FFPathImageView.h"
#import "FFRosterTableHeader.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "FFWCGame.h"
#import "FFWCTeam.h"
#import "FFWCGroup.h"
#import "FFWCPlayer.h"

@interface FFWCController () <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) UIPickerView *picker;
@property (nonatomic, strong) NSString *selectedGroup;

@end

@implementation FFWCController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.backgroundColor = [FFStyle darkGrey];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    //custom picker
    if (self.category == FFWCGroupWinners) {
        self.picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 162.f)];
        self.picker.delegate = self;
        self.picker.dataSource = self;
        self.picker.showsSelectionIndicator = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? NO : YES;
        
        CGAffineTransform t0 = CGAffineTransformMakeTranslation(self.picker.bounds.size.width/2, self.picker.bounds.size.height/2);
        CGAffineTransform s0 = CGAffineTransformMakeScale(1.0, 0.47);
        CGAffineTransform t1 = CGAffineTransformMakeTranslation(-self.picker.bounds.size.width/2, -self.picker.bounds.size.height/2);
        self.picker.transform = CGAffineTransformConcat(t0, CGAffineTransformConcat(s0, t1));
        self.picker.backgroundColor = [FFStyle darkGrey];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.category == FFWCGroupWinners ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.elements.count == 0)
        return 1;
    
    if (self.category == FFWCGroupWinners) {
        if (section == 0) {
            return 1;
        } else {
            FFWCGroup *group = [self.elements objectAtIndex:self.selectedCroupIndex];
            return group.teams.count;
        }
    } else {
        return self.elements.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.category == FFWCGroupWinners) {
        return indexPath.section == 0 ? 76.f : 80.f;
    } else if (self.category == FFWCDailyWins) {
        return 100.f;
    } else {
        return 80.f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        switch (self.category) {
            case FFWCCupWinner: {
                FFWCTeam *team = (FFWCTeam *)[self.elements objectAtIndex:indexPath.row];
                
                FFWCCell *cell = [[FFWCCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WCCell"];
                [cell setupWithTeam:team];
                [cell.PTButton setAction:kUIButtonBlockTouchUpInside
                               withBlock:^{
                                   
                               }];
                return cell;
            }
                
            case FFWCGroupWinners: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PickerCell"];
                [cell addSubview:self.picker];
                return cell;
            }
             
            case FFWCDailyWins: {
                FFWCGameCell *cell = [[FFWCGameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WCGameCell"];
                [cell setupWithGame:[self.elements objectAtIndex:indexPath.row]];
                
                [cell.homePTButton setAction:kUIButtonBlockTouchUpInside
                                   withBlock:^{
                                       
                                   }];
                [cell.guestPTButton setAction:kUIButtonBlockTouchUpInside
                                    withBlock:^{
                                        
                                    }];
                
                return cell;
            }
                
            case FFWCMvp: {
                FFWCPlayer *player = (FFWCPlayer *)[self.elements objectAtIndex:indexPath.row];
                
                FFWCCell *cell = [[FFWCCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WCCell"];
                [cell setupWithPlayer:player];
                
                [cell.PTButton setAction:kUIButtonBlockTouchUpInside
                               withBlock:^{
                                   
                               }];
                return cell;
            }
                
            default:
                return nil;
        }
    } else {
        FFWCGroup *group = [self.elements objectAtIndex:self.selectedCroupIndex];
        FFWCTeam *team = [group.teams objectAtIndex:indexPath.row];
        
        FFWCCell *cell = [[FFWCCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WCCell"];
        [cell setupWithTeam:team];
        
        [cell.PTButton setAction:kUIButtonBlockTouchUpInside
                       withBlock:^{
                           
                       }];
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ((self.category == FFWCGroupWinners && section == 1) || (self.category != FFWCGroupWinners && section == 0)) {
        return 40.f;
    }
    return 0.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ((self.category == FFWCGroupWinners && section == 1) || (self.category != FFWCGroupWinners && section == 0)) {
        FFRosterTableHeader* view = [FFRosterTableHeader new];
        NSString *title = nil;
        switch (self.category) {
            case FFWCCupWinner:
                title = @"Win the Cup";
                break;
            case FFWCGroupWinners:
                title = @"Win the Group";
                break;
            case FFWCDailyWins:
                title = @"Daily Wins";
                break;
            case FFWCMvp:
                title = @"MVP";
                break;
                
            default:
                break;
        }
        view.titleLabel.text = title;
        return view;
    }
    return nil;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.elements.count;
}

#pragma mark - UIPickerViewDelegate

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 54.0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *pickerLabel = (UILabel *)view;
    
    if (pickerLabel == nil) {
        pickerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 54.f)];
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        pickerLabel.textColor = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? [UIColor clearColor] : [FFStyle darkGrey];
        pickerLabel.font = [FFStyle blockFont:30.0f];
        pickerLabel.textColor = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? [UIColor whiteColor] : [UIColor blackColor];
    }
    
    FFWCGroup *group = (FFWCGroup *)[self.elements objectAtIndex:row];
    pickerLabel.text = group.title;
    
    return pickerLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedCroupIndex = row;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
