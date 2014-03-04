//
//  FFContestViewController.m
//  FMF Football
//
//  Created by Samuel Sutch on 9/25/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import "FFContestViewController.h"
#import <FormatterKit/TTTOrdinalNumberFormatter.h>
#import "FFContestView.h"
#import <QuartzCore/QuartzCore.h>
#import "FFRoster.h"
#import "FFSessionViewController.h"
#import "FFAlertView.h"
#import "FFRosterSlotCell.h"
#import "FFPlayerSelectCell.h"
#import "FFContestEntrantsViewController.h"
#import "FFInviteViewController.h"

@interface FFContestViewController () <UITableViewDataSource,
                                       UITableViewDelegate,
                                       FFRosterSlotCellDelegate,
                                       FFPlayerSelectCellDelegate> {
    BOOL _filterBenchPlayers;
}

@property(nonatomic) UITableView* tableView;
@property(nonatomic) FFContestViewControllerState state; /** current state of the FSM */
@property(nonatomic) NSMutableArray* rosterPlayers; /** the players in the current roster */
@property(nonatomic) NSArray* availablePlayers; /** shown in PickPlayer */
@property(nonatomic) UIView* submitButtonView;
@property(nonatomic) UILabel* remainingSalaryLabel;
@property(nonatomic) UILabel* numEntrantsLabel;
@property(nonatomic) UIView* playerFilterView;

- (void)transitionToState:(FFContestViewControllerState)newState
              withContext:(id)context;

@end

@implementation FFContestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_tableView];
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        [_tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
        id topGuide = self.topLayoutGuide;
        NSDictionary* viewsDictionary = NSDictionaryOfVariableBindings(_tableView, topGuide);
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide][_tableView]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:viewsDictionary]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:viewsDictionary]];
    } else {
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[UITableViewCell class]
        forCellReuseIdentifier:@"BannerCell"];
    [_tableView registerClass:[UITableViewCell class]
        forCellReuseIdentifier:@"ContestCell"];
    [_tableView registerClass:[UITableViewCell class]
        forCellReuseIdentifier:@"EnterCell"];
    [_tableView registerClass:[FFRosterSlotCell class]
        forCellReuseIdentifier:@"RosterPlayer"];
    [_tableView registerClass:[FFPlayerSelectCell class]
        forCellReuseIdentifier:@"PlayerSelect"];
    [_tableView registerClass:[UITableViewCell class]
        forCellReuseIdentifier:@"EntrantsCell"];

    UIButton* balanceView = [self.sessionController balanceView];
    [balanceView addTarget:self
                    action:@selector(showBalance:)
          forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:balanceView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (!_market || !_contest) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"showing the contest view controller but don't have a "
            @"contest or a market, dying now..."
                                     userInfo:@{}];
    }
    if (!_roster) {
        [self transitionToState:FFContestViewControllerStateViewContest
                    withContext:nil];
        return;
    }
    if (self.currentPickPlayer) {
        [self transitionToState:FFContestViewControllerStatePickPlayer
                    withContext:self.currentPickPlayer];
    } else if (_notMine) { // it's someone's else roster
        [self transitionToState:FFContestViewControllerStateShowFriendRoster
                    withContext:nil];
    } else if ([_roster.state isEqualToString:@"in_progress"]) {
        [self transitionToState:FFContestViewControllerStateShowRoster
                    withContext:nil];
    } else if ([_roster.state isEqualToString:@"submitted"]) {
        [self transitionToState:FFContestViewControllerStateContestEntered
                    withContext:nil];
    } else if ([_roster.market.state isEqualToString:@"complete"]) { // NOTE: switch on market state vs roster state
        [self transitionToState:FFContestViewControllerStateContestCompleted
                    withContext:nil];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self transitionToState:FFContestViewControllerStateNone
                withContext:nil];
}

- (void)showBalance:(UIButton*)seder
{
    [self performSegueWithIdentifier:@"GotoTokenPurchase"
                              sender:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setRoster:(FFRoster*)roster
{
    _roster = roster;
    _market = roster.market;
    _contest = roster.contestType;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1 + (_state != FFContestViewControllerStateViewContest ? 1 : 0);
}

- (NSInteger)tableView:(UITableView*)tableView
    numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if (_state == FFContestViewControllerStatePickPlayer) {
            return 0;
        }
        if (_state == FFContestViewControllerStateShowFriendRoster) {
            return 1;
        }
        int rows = 2;
        if (_state == FFContestViewControllerStateViewContest
            || _state == FFContestViewControllerStateShowRoster
            || _state == FFContestViewControllerStateContestEntered) {
            rows++;
        }
        if (_state == FFContestViewControllerStateContestEntered) {
            rows++;
        }
        return rows;
    } else {
        switch (_state) {
        case FFContestViewControllerStateShowRoster:
        case FFContestViewControllerStateContestEntered:
        case FFContestViewControllerStateShowFriendRoster:
        case FFContestViewControllerStateContestCompleted:
            return _rosterPlayers != nil ? _rosterPlayers.count : 0;
        case FFContestViewControllerStatePickPlayer:
            return _availablePlayers != nil ? _availablePlayers.count : 0;
        default:
            return 0;
        }
    }
}

- (CGFloat)tableView:(UITableView*)tableView
    heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 35;
        } else if (indexPath.row == 1
                   && ([_roster.live integerValue] || [_roster.market.state isEqualToString:@"complete"])) {
            return 195;
        } else if (indexPath.row == 1) {
            return 150;
        } else if (indexPath.row == 2) {
            return 52;
        } else if (indexPath.row == 3) {
            return 44;
        }
    }
    return 80;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = nil;

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"BannerCell"
                                                   forIndexPath:indexPath];
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            if ([_roster.live integerValue]) {
                cell.contentView.backgroundColor = [FFStyle brightGreen];
                cell.textLabel.font = [FFStyle regularFont:17.f];
                cell.textLabel.textColor = [FFStyle white];
                cell.textLabel.backgroundColor = cell.contentView.backgroundColor;
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.text = NSLocalizedString(@"Game has started!", nil);
            } else {
                cell.contentView.backgroundColor = [UIColor colorWithWhite:.95f
                                                                     alpha:1.f];
                cell.textLabel.font = [FFStyle regularFont:14.f];
                cell.textLabel.textColor = [FFStyle darkGreyTextColor];
                cell.textLabel.backgroundColor = cell.contentView.backgroundColor;
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                cell.textLabel.adjustsLetterSpacingToFitWidth = YES;
                TTTOrdinalNumberFormatter* ordinalNumberFormatter = [[TTTOrdinalNumberFormatter alloc] init];
                [ordinalNumberFormatter setLocale:[NSLocale currentLocale]];
                [ordinalNumberFormatter setGrammaticalGender:TTTOrdinalNumberFormatterMaleGender];
                NSDateFormatter* mformatter = [[NSDateFormatter alloc] init];
                mformatter.dateFormat = @"eeee MMMM";
                NSDateFormatter* tformatter = [[NSDateFormatter alloc] init];
                [tformatter setLocale:[NSLocale currentLocale]];
                [tformatter setTimeZone:[NSTimeZone systemTimeZone]];
                tformatter.dateFormat = @"ha";
                NSDateComponents* components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit
                                                                                        | NSMonthCalendarUnit
                                                                                        | NSYearCalendarUnit
                                                                               fromDate:_market.startedAt];
                NSString* startsOrStarted = NSLocalizedString(@"Game starts", nil);
                if ([_market.startedAt compare:[NSDate date]] == NSOrderedAscending) {
                    startsOrStarted = NSLocalizedString(@"Game started", nil);
                }

                NSString* str = [NSString stringWithFormat:@"%@ %@ %@ at %@",
                                                           startsOrStarted,
                                                           [mformatter stringFromDate:_market.startedAt],
                                                           [ordinalNumberFormatter stringFromNumber:@(components.day)],
                                                           [tformatter stringFromDate:_market.startedAt]];
                cell.textLabel.text = str;
            }
            UIView* sep = [[UIView alloc] initWithFrame:CGRectMake(0.f, CGRectGetMaxY(cell.contentView.frame),
                                                                   cell.contentView.frame.size.width, 1.f)];
            sep.backgroundColor = [UIColor colorWithWhite:.8f
                                                    alpha:1.f];
            [cell.contentView addSubview:sep];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ContestCell"
                                                   forIndexPath:indexPath];
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            FFContestView* view = [[FFContestView alloc] initWithFrame:CGRectMake(0, 0, 320, 150)];
            view.market = _market;
            view.contest = _contest;
            view.roster = _roster;
            [cell.contentView addSubview:view];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else if (indexPath.row == 2) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"EnterCell"];
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            FFCustomButton* butt;
            if (_state == FFContestViewControllerStateViewContest) {
                NSString* txt;
                if (_contest.buyIn.integerValue < 1) {
                    txt = [NSString stringWithFormat:@"%@ %@ %@",
                                                     NSLocalizedString(@"Enter", nil),
                                                     _contest.name,
                                                     NSLocalizedString(@"For Free!", nil)];
                } else {
                    txt = [NSString stringWithFormat:@"%@ %@ with %@ %@",
                                                     NSLocalizedString(@"Enter", nil),
                                                     _contest.name,
                                                     [_contest.buyIn description],
                                                     NSLocalizedString(@"FanFrees", nil)];
                }
                butt = [FFStyle coloredButtonWithText:txt
                                                color:[FFStyle brightOrange]
                                          borderColor:[FFStyle brightOrange]];
                [butt addTarget:self
                              action:@selector(enterGame:)
                    forControlEvents:UIControlEventTouchUpInside];
            } else if (_state == FFContestViewControllerStateShowRoster) {
                butt = [FFStyle coloredButtonWithText:NSLocalizedString(@"Cancel Entry", nil)
                                                color:[FFStyle darkGreyTextColor]
                                          borderColor:[FFStyle lightGrey]];
                [butt addTarget:self
                              action:@selector(leaveGame:)
                    forControlEvents:UIControlEventTouchUpInside];
            } else if (_state == FFContestViewControllerStateContestEntered) {
                butt = [FFStyle coloredButtonWithText:NSLocalizedString(@"Invite Friends", nil)
                                                color:[FFStyle brightOrange]
                                          borderColor:[FFStyle brightOrange]];
                [butt addTarget:self
                              action:@selector(inviteToGame:)
                    forControlEvents:UIControlEventTouchUpInside];
            }
            butt.titleLabel.font = [FFStyle blockFont:19.f];
            butt.frame = CGRectMake(15, 3, 290, 38);
            [cell.contentView addSubview:butt];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else if (indexPath.row == 3) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"EntrantsCell"
                                                   forIndexPath:indexPath];
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

            UIImageView* disclosure = [[UIImageView alloc] initWithFrame:CGRectMake(295, 14.5, 10, 15)];
            disclosure.image = [UIImage imageNamed:@"accessory_disclosure"];
            disclosure.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:disclosure];

            UILabel* lab = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 250, 44)];
            lab.backgroundColor = [UIColor clearColor];
            lab.font = [FFStyle regularFont:17];
            lab.textColor = [FFStyle greyTextColor];
            NSString* text = [NSString stringWithFormat:@"%@ %@",
                                                        _roster.contest[@"num_rosters"],
                                                        NSLocalizedString(@"Contest Entrants", nil)];
            lab.text = text;
            [cell.contentView addSubview:lab];

            _numEntrantsLabel = lab;

            UIView* sep = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                   cell.contentView.frame.size.width, 1)];
            sep.backgroundColor = [UIColor colorWithWhite:.8
                                                    alpha:1];
            [cell.contentView addSubview:sep];
        }
    } else if (indexPath.section == 1) {
        if (_state == FFContestViewControllerStateShowRoster
            || _state == FFContestViewControllerStateContestEntered
            || _state == FFContestViewControllerStateShowFriendRoster
            || _state == FFContestViewControllerStateContestCompleted) {
            id player = [_rosterPlayers objectAtIndex:indexPath.row];
            cell = [tableView dequeueReusableCellWithIdentifier:@"RosterPlayer"
                                                   forIndexPath:indexPath];
            FFRosterSlotCell* rosterCell = (FFRosterSlotCell*)cell;
            [rosterCell setPlayer:player
                        andRoster:_roster
                        andMarket:_market];
            rosterCell.delegate = self;
            if (_state == FFContestViewControllerStateShowFriendRoster || _state == FFContestViewControllerStateContestCompleted) {
                rosterCell.showButtons = NO;
            } else {
                rosterCell.showButtons = YES;
            }
        } else if (_state == FFContestViewControllerStatePickPlayer) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"PlayerSelect"
                                                   forIndexPath:indexPath];
            FFPlayerSelectCell* s_cell = (FFPlayerSelectCell*)cell;
            s_cell.player = _availablePlayers[indexPath.row];
            s_cell.delegate = self;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (!cell) {
        NSLog(@"fart");
    }
    return cell;
}

- (CGFloat)tableView:(UITableView*)tableView
    heightForHeaderInSection:(NSInteger)section
{
    return section == 1 ? 40.f : 0.f;
}

- (UIView*)tableView:(UITableView*)tableView
    viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        header.backgroundColor = [UIColor colorWithWhite:.9
                                                   alpha:1];

        UIView* sep = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
        sep.backgroundColor = [UIColor colorWithWhite:.8
                                                alpha:1];
        [header addSubview:sep];

        sep = [[UIView alloc] initWithFrame:CGRectMake(0, 38, 320, 1)];
        sep.backgroundColor = [UIColor colorWithWhite:.8
                                                alpha:1];
        [header addSubview:sep];

        sep = [[UIView alloc] initWithFrame:CGRectMake(0, 39, 320, 1)];
        sep.backgroundColor = [UIColor colorWithWhite:1
                                                alpha:.5];
        [header addSubview:sep];

        UILabel* price = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 305, 38)];
        price.backgroundColor = [UIColor clearColor];
        price.textColor = [FFStyle brightGreen];
        price.font = [FFStyle blockFont:26];
        price.textAlignment = NSTextAlignmentRight;
        price.text = [NSString stringWithFormat:@"$%d", [[_roster.remainingSalary description] integerValue]];
        _remainingSalaryLabel = price;
        [header addSubview:price];

        if (_state == FFContestViewControllerStateShowRoster) {
            UILabel* lab = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 320, 40)];
            lab.font = [FFStyle lightFont:26];
            lab.backgroundColor = [UIColor clearColor];
            lab.textColor = [UIColor colorWithWhite:.15
                                              alpha:1];
            lab.text = NSLocalizedString(@"Pick Your Team", nil);
            [header addSubview:lab];
        } else if (_state == FFContestViewControllerStatePickPlayer) {
            NSString* pos;
            if ([_currentPickPlayer isKindOfClass:[NSString class]]) {
                pos = _currentPickPlayer;
            } else {
                pos = _currentPickPlayer[@"position"];
            }
            NSDictionary* names = @{
                @"QB" : NSLocalizedString(@"Quarterback", nil),
                @"RB" : NSLocalizedString(@"Running Back", nil),
                @"WR" : NSLocalizedString(@"Wide Receiver", nil),
                @"DEF" : NSLocalizedString(@"Defense", nil),
                @"K" : NSLocalizedString(@"Kicker", nil),
                @"TE" : NSLocalizedString(@"Tight End", nil)
            };

            UILabel* lab = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 320, 40)];
            lab.font = [FFStyle lightFont:26];
            lab.backgroundColor = [UIColor clearColor];
            lab.textColor = [UIColor colorWithWhite:.15
                                              alpha:1];
            lab.text = names[pos];
            [header addSubview:lab];
        } else if (_state == FFContestViewControllerStateContestEntered || _state == FFContestViewControllerStateContestCompleted) {
            UILabel* lab = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 320, 40)];
            lab.font = [FFStyle lightFont:26];
            lab.backgroundColor = [UIColor clearColor];
            lab.textColor = [UIColor colorWithWhite:.15
                                              alpha:1];
            lab.text = NSLocalizedString(@"My Team", nil);
            [header addSubview:lab];
        } else if (_state == FFContestViewControllerStateShowFriendRoster) {
            UILabel* lab = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 320, 40)];
            lab.font = [FFStyle lightFont:26];
            lab.backgroundColor = [UIColor clearColor];
            lab.textColor = [UIColor colorWithWhite:.15
                                              alpha:1];
            lab.text = [NSString stringWithFormat:@"%@'s Team", _roster.ownerName];
            [header addSubview:lab];
        }
        return header;
    }
    return nil;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    if (_state == FFContestViewControllerStateContestEntered && indexPath.row == 3) {
        [self performSegueWithIdentifier:@"GotoContestEntrants"
                                  sender:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GotoContestEntrants"]) {
        ((FFContestEntrantsViewController*)segue.destinationViewController).contest = _roster.contest;
    }
    if ([segue.identifier isEqualToString:@"GotoInvite"]) {
        ((FFInviteViewController*)[segue.destinationViewController viewControllers][0]).roster = _roster;
    }
    if ([segue.identifier isEqualToString:@"GotoPickPlayer"]) {
        FFContestViewController* next = segue.destinationViewController;
        next.roster = _roster;
        next.market = _market;
        next.contest = _contest;
        next.delegate = self;
        [next showPickPlayer:segue.context];
    }
}

- (void)enterGame:(UIButton*)button
{
    FFAlertView* alert = [[FFAlertView alloc] initWithTitle:NSLocalizedString(@"Starting Roster", nil)
                                                   messsage:nil
                                               loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.navigationController.view];
    [FFRoster createRosterWithContestTypeId:[_contest.objId integerValue]
                                    session:self.session success:
     ^(id successObj)
    {
        [alert hide];
        _roster = successObj;
        [self transitionToState:FFContestViewControllerStateShowRoster
                    withContext:nil];
    }
failure:
    ^(NSError * error)
    {
        [alert hide];
        FFAlertView* alert = [[FFAlertView alloc] initWithError:error
                                                          title:nil
                                              cancelButtonTitle:nil
                                                okayButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                       autoHide:YES];
        [alert showInView:self.navigationController.view];
    }];
}

- (void)leaveGame:(UIButton*)button
{
    FFAlertView* alert = [[FFAlertView alloc] initWithTitle:NSLocalizedString(@"Loading", nil)
                                                   messsage:nil
                                               loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.navigationController.view];
    [_roster removeInBackgroundWithBlock:^(id successObj)
    {
        [alert hide];
        if ([_contest.isPrivate integerValue]) {
            // we just left the contest we created, so don't show it anymore
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self transitionToState:FFContestViewControllerStateViewContest
                        withContext:nil];
        }
    }
failure:
    ^(NSError * error)
    {
        [alert hide];
        FFAlertView* eAlert = [[FFAlertView alloc] initWithError:error
                                                           title:nil
                                               cancelButtonTitle:nil
                                                 okayButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                        autoHide:YES];
        [eAlert showInView:self.navigationController.view];
    }];
}

- (void)inviteToGame:(UIButton*)button
{
    [self performSegueWithIdentifier:@"GotoInvite"
                              sender:nil];
}

- (void)backFromPlayerSelect:(UIButton*)button
{
    BOOL isSubmitted = [self.roster.state isEqualToString:@"submitted"];
    [self transitionToState:isSubmitted ? FFContestViewControllerStateContestEntered
                                        : FFContestViewControllerStateShowRoster
                withContext:nil];
}

- (void)rosterCellSelectPlayer:(FFRosterSlotCell*)cell
{
    [self performSegueWithIdentifier:@"GotoPickPlayer"
                              sender:nil
                             context:cell.player];
}

- (void)rosterCellReplacePlayer:(FFRosterSlotCell*)cell
{
    FFAlertView* alert = [[FFAlertView alloc] initWithTitle:@"Removing Player"
                                                   messsage:nil
                                               loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.navigationController.view];
    [_roster removePlayer:cell.player success:^(id successObj)
    {
        [alert hide];
        [cell setPlayer:cell.player[@"position"]
              andRoster:_roster
              andMarket:_market];
        [self showRosterPlayers];
    }
failure:
    ^(NSError * error)
    {
        [alert hide];
        FFAlertView* eAlert = [[FFAlertView alloc] initWithError:error
                                                           title:nil
                                               cancelButtonTitle:nil
                                                 okayButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                        autoHide:YES];
        [eAlert showInView:self.navigationController.view];
    }];
}

- (void)playerSelectCellDidBuy:(FFPlayerSelectCell*)cell
{
    FFAlertView* alert = [[FFAlertView alloc] initWithTitle:NSLocalizedString(@"Buying Player", nil)
                                                   messsage:nil
                                               loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.navigationController.view];
    __block FFContestViewController* blockSelf = self;
    [_roster addPlayer:cell.player
            toPosition:self.currentPickPlayer
               success:^(id successObj)
    {
        [alert hide];
        if (blockSelf->_delegate
            && [blockSelf->_delegate respondsToSelector:@selector(contestController:
                                                                      didPickPlayer:)]) {
            [blockSelf->_delegate contestController:blockSelf
                                      didPickPlayer:cell.player];
        }
    }
failure:
    ^(NSError * error)
    {
        [alert hide];
        FFAlertView* eAlert = [[FFAlertView alloc] initWithError:error
                                                           title:nil
                                               cancelButtonTitle:nil
                                                 okayButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                        autoHide:YES];
        [eAlert showInView:blockSelf.view];
    }];
}

- (void)contestController:(id)cont
            didPickPlayer:(NSDictionary*)player
{
    FFContestViewControllerState next;
    if ([_roster.state isEqualToString:@"submitted"]) {
        next = FFContestViewControllerStateContestEntered;
    } else {
        next = FFContestViewControllerStateShowRoster;
    }
    [self hidePlayerFilterBanner];
    [self transitionToState:next
                withContext:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rosterCellStatsForPlayer:(FFRosterSlotCell*)cell
{
}

- (void)submitRoster:(UIButton*)sender
{
    FFAlertView* alert = [[FFAlertView alloc] initWithTitle:NSLocalizedString(@"Submitting", nil)
                                                   messsage:nil
                                               loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.navigationController.view];
    [_roster submitSuccess:^(id successObj)
    {
        [alert hide];
        _roster = successObj;
        [self transitionToState:FFContestViewControllerStateContestEntered
                    withContext:nil];
    }
failure:
    ^(NSError * error)
    {
        [alert hide];
        FFAlertView* eAlert = [[FFAlertView alloc] initWithError:error
                                                           title:nil
                                               cancelButtonTitle:nil
                                                 okayButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                        autoHide:YES];
        //        [eAlert showInView:self.navigationController.view];
    }];
}

- (void)showPickPlayer:(id)player
{
    _currentPickPlayer = player;
}

- (void)transitionToState:(FFContestViewControllerState)newState
              withContext:(id)context
{
    if (newState == _state) {
        NSLog(@"tried to transition to the current state... ignoring");
        return;
    }
    FFContestViewControllerState previousState = _state;
    _state = newState;
    switch (_state) {
    case FFContestViewControllerStateViewContest:
        [self hideSubmitRosterBanner];
        if (previousState == FFContestViewControllerStateNone) {
            [self.tableView reloadData];
        } else {
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[
                                                       [NSIndexPath indexPathForRow:2
                                                                          inSection:0]
                                                   ]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }
        break;
    case FFContestViewControllerStateShowRoster:
        [self.tableView beginUpdates];
        if (previousState == FFContestViewControllerStateViewContest) {
            [self.tableView reloadRowsAtIndexPaths:@[
                                                       [NSIndexPath indexPathForRow:2
                                                                          inSection:0]
                                                   ]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
        } else if (previousState == FFContestViewControllerStatePickPlayer) {
            [self.tableView insertRowsAtIndexPaths:@[
                                                       [NSIndexPath indexPathForRow:2
                                                                          inSection:0]
                                                   ]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [self showRosterPlayers];
        [self.tableView endUpdates];
        break;
    case FFContestViewControllerStatePickPlayer:
        _currentPickPlayer = context;
        [self showPlayersForPosition:[context isKindOfClass:[NSString class]] ? context : context[@"position"]
                                poll:YES];
        [self showPlayerFilterBanner];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[
                                                   [NSIndexPath indexPathForRow:2
                                                                      inSection:0]
                                               ]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        if (previousState == FFContestViewControllerStateContestEntered) {
            // need to get rid of the "contest entrants" row
            [self.tableView deleteRowsAtIndexPaths:@[
                                                       [NSIndexPath indexPathForRow:3
                                                                          inSection:0]
                                                   ]
                                  withRowAnimation:UITableViewRowAnimationNone];
        }
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        break;
    case FFContestViewControllerStateContestEntered:
        [self showRosterPlayers];
        if (previousState == FFContestViewControllerStateNone) {
            [self.tableView reloadData];
        } else {
            [self.tableView beginUpdates];
            if (previousState == FFContestViewControllerStatePickPlayer) {
                [self.tableView insertRowsAtIndexPaths:@[
                                                           [NSIndexPath indexPathForItem:2
                                                                               inSection:0]
                                                       ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
            } else {
                [self.tableView reloadRowsAtIndexPaths:@[
                                                           [NSIndexPath indexPathForRow:2
                                                                              inSection:0]
                                                       ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            [self.tableView insertRowsAtIndexPaths:@[
                                                       [NSIndexPath indexPathForRow:3
                                                                          inSection:0]
                                                   ]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }
        if (previousState == FFContestViewControllerStateShowRoster) {
            [self hideSubmitRosterBanner];
        }
        break;
    case FFContestViewControllerStateShowFriendRoster:
        // previous state should always be none
        [self showRosterPlayers];
        [self.tableView reloadData];
        break;
    case FFContestViewControllerStateContestCompleted:
        [self showRosterPlayers];
        [self.tableView reloadData];
        break;
    default:
        break;
    }
}

- (void)showRosterPlayers
{
    if (!(_state == FFContestViewControllerStateShowRoster
          || _state == FFContestViewControllerStateContestEntered
          || _state == FFContestViewControllerStateShowFriendRoster
          || _state == FFContestViewControllerStateContestCompleted)) {
        NSLog(@"attempting to show roster players, but in the wrong state");
        return;
    }

    [self reloadRosterPlayers];

    [_roster refreshInBackgroundWithBlock:^(id successObj)
    {
        if (!(_state == FFContestViewControllerStateShowRoster
              || _state == FFContestViewControllerStateContestEntered)) {
            return;
        }
        _roster = successObj;

        [self reloadRosterPlayers];

        NSMutableArray* paths = [NSMutableArray arrayWithCapacity:_rosterPlayers.count];
        for (int i = 0; i < _rosterPlayers.count; i++) {
            [paths addObject:[NSIndexPath indexPathForRow:i
                                                inSection:1]];
        }
        [_tableView reloadRowsAtIndexPaths:paths
                          withRowAnimation:UITableViewRowAnimationNone];

        double delayInSeconds = 10.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            // only poll if we're viewing this screen
            [self showRosterPlayers];
        });
    }
failure:
    ^(NSError * error)
    {
        if (_state == FFContestViewControllerStateViewContest
            || _state == FFContestViewControllerStatePickPlayer) {
            return;
        }
        FFAlertView* alert = [[FFAlertView alloc] initWithError:error
                                                          title:nil
                                              cancelButtonTitle:nil
                                                okayButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                       autoHide:YES];
        [alert showInView:self.navigationController.view];
    }];
}

- (void)showPlayersForPosition:(NSString*)pos poll:(BOOL)shouldContinuePolling
{
    if (_state != FFContestViewControllerStatePickPlayer) {
        NSLog(@"attempting to show players but in the wrong state");
        return;
    }
    NSDictionary* params = @{
        @"position" : pos, @"roster_id" : _roster.objId
    };
    [self.session authorizedJSONRequestWithMethod:@"GET" path:@"/players/" paramters:params success:
     ^(NSURLRequest *request, NSHTTPURLResponse *httpResponse, id JSON)
    {
        if (_state != FFContestViewControllerStatePickPlayer) {
            return;
        }

        NSMutableArray* sorted = [JSON mutableCopy];
         [sorted sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
         {
             NSString* str1 = [obj1 objectForKey:@"buy_price"];
             NSString* str2 = [obj2 objectForKey:@"buy_price"];
             return [str2 compare:str1
                          options:NSNumericSearch];
         }];

         if (_filterBenchPlayers && sorted.count > 3) {
             [sorted filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings)
             {
                 if (evaluatedObject[@"benched_games"] && [evaluatedObject[@"benched_games"] integerValue] > 2) {
                     return NO;
                 }
                 return YES;
             }]];
         }

         _availablePlayers = sorted;
         [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                       withRowAnimation:UITableViewRowAnimationNone];

         if (!shouldContinuePolling) { // we're done if there is no more polling to do
             return;
         }

         __strong FFContestViewController* strongSelf = self;

         double delayInSeconds = 10.0;
         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
         dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
             NSString *lastPos = ((strongSelf->_currentPickPlayer
                                   && [strongSelf->_currentPickPlayer isKindOfClass:[NSDictionary class]])
                                  ? strongSelf->_currentPickPlayer[@"position"]
                                  : strongSelf->_currentPickPlayer);
             // only poll again if we are still picking a player and picking the correct one
             if (strongSelf->_state == FFContestViewControllerStatePickPlayer && [pos isEqualToString:lastPos]) {
                 [strongSelf showPlayersForPosition:lastPos poll:YES];
             }
         });
    }
failure:
    ^(NSURLRequest * request, NSHTTPURLResponse * httpResponse, NSError * error, id JSON)
    {
        if (_state != FFContestViewControllerStatePickPlayer) {
            return;
        }
        FFAlertView* alert = [[FFAlertView alloc] initWithError:error
                                                          title:nil
                                              cancelButtonTitle:nil
                                                okayButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                       autoHide:YES];
        [alert showInView:self.navigationController.view];
    }];
}

- (void)showPlayerFilterBanner
{
    if (_state != FFContestViewControllerStatePickPlayer) {
        return;
    }
    if (!_playerFilterView) {
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame),
                                                                self.view.frame.size.width, 80)];
        view.backgroundColor = [UIColor colorWithWhite:.25
                                                 alpha:1];

        UILabel* lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, 30)];
        lab.backgroundColor = view.backgroundColor;
        lab.font = [FFStyle regularFont:14];
        lab.textColor = [UIColor colorWithWhite:.95
                                          alpha:1];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.text = NSLocalizedString(@"Filters", nil);
        [view addSubview:lab];

        UILabel* benchLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 35, 60, 30)];
        benchLab.text = NSLocalizedString(@"Hide Bench Players", nil);
        benchLab.font = [FFStyle regularFont:14];
        CGRect bf = benchLab.frame;
        bf.size.width = [benchLab.text sizeWithFont:benchLab.font].width + 2;
        benchLab.frame = bf;
        benchLab.textColor = [UIColor colorWithWhite:.9
                                               alpha:1];
        benchLab.backgroundColor = [UIColor clearColor];
        [view addSubview:benchLab];

        UISwitch* benchSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetMaxX(bf) + 15, 35, 90, 30)];
        [benchSwitch setOn:NO];
        [benchSwitch addTarget:self
                        action:@selector(benchSwitch:)
              forControlEvents:UIControlEventValueChanged];
        [view addSubview:benchSwitch];

        _playerFilterView = view;
        [self.view addSubview:view];

        [UIView animateWithDuration:.25
                         animations:^{
            view.frame = CGRectOffset(view.frame, 0, -view.frame.size.height);
            _tableView.contentInset = UIEdgeInsetsMake(0, 0, view.frame.size.height, 0);
                         }];
    }
}

- (void)benchSwitch:(UISwitch*)swit
{
    _filterBenchPlayers = swit.isOn;
    NSString* lastPos = ((_currentPickPlayer
                          && [_currentPickPlayer isKindOfClass:[NSDictionary class]])
                             ? _currentPickPlayer[@"position"]
                             : _currentPickPlayer);
    [self showPlayersForPosition:lastPos
                            poll:NO]; // immediately refresh
}

- (void)hidePlayerFilterBanner
{
    if (_playerFilterView) {
        UIView* view = _playerFilterView;
        _playerFilterView = nil;
        [UIView animateWithDuration:.25 animations:^{
            view.frame = CGRectOffset(view.frame, 0, view.frame.size.height);
            _tableView.contentInset = UIEdgeInsetsZero;
        } completion:^(BOOL finished)
        {
            if (finished) {
                [view removeFromSuperview];
            }
        }];
    }
}

- (void)showSubmitRosterBanner:(NSString*)text
{
    if (_state != FFContestViewControllerStateShowRoster) {
        return;
    }
    _filterBenchPlayers = NO;
    if (!_submitButtonView) {
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame),
                                                                self.view.frame.size.width, 80)];
        view.backgroundColor = [UIColor colorWithWhite:.25
                                                 alpha:1];

        UILabel* lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, 30)];
        lab.backgroundColor = view.backgroundColor;
        lab.font = [FFStyle regularFont:14];
        lab.textColor = [UIColor colorWithWhite:.95
                                          alpha:1];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.text = text; //NSLocalizedString(@"All slots are filled!", nil);
        [view addSubview:lab];

        UIButton* butt = [FFStyle coloredButtonWithText:NSLocalizedString(@"Submit Roster!", nil)
                                                  color:[FFStyle brightOrange]
                                            borderColor:[FFStyle brightOrange]];
        butt.frame = CGRectMake(15, 30, 290, 38);
        butt.titleLabel.font = [FFStyle blockFont:19.f];
        [butt addTarget:self
                      action:@selector(submitRoster:)
            forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:butt];

        _submitButtonView = view;
        [self.view addSubview:view];

        [UIView animateWithDuration:.25f
                         animations:^{
            view.frame = CGRectOffset(view.frame, 0, -view.frame.size.height);
            _tableView.contentInset = UIEdgeInsetsMake(0, 0, view.frame.size.height, 0);
                         }];
    }
}

- (void)hideSubmitRosterBanner
{
    if (!_submitButtonView) {
        return;
    }
    UIView* view = _submitButtonView;
    _submitButtonView = nil;
    [UIView animateWithDuration:.25f
                     animations:^{
                         view.frame = CGRectOffset(view.frame, 0, view.frame.size.height);
                         _tableView.contentInset = UIEdgeInsetsZero;
                     } completion:^(BOOL finished)
    {
        if (finished) {
            [view removeFromSuperview];
        }
    }];
}

#pragma mark - private

- (void)reloadRosterPlayers
{
    NSArray* positions = [self.roster.positions componentsSeparatedByString:@","];
    NSMutableArray* slots = [NSMutableArray arrayWithCapacity:positions.count];
    NSMutableSet* alreadyAssigned = [NSMutableSet set];
    NSDictionary* chosenPlayer = nil;
    for (NSString* position in positions) {
        for (NSDictionary* player in self.roster.players) {
            if ([player[@"position"] isEqualToString:position]
                    && ![alreadyAssigned containsObject:player[@"id"]]) {
                chosenPlayer = player;
                [alreadyAssigned addObject:player[@"id"]];
                break;
            }
        }
        [slots addObject:chosenPlayer ? chosenPlayer : position];
    }
    self.rosterPlayers = slots;
    if (_remainingSalaryLabel) {
        _remainingSalaryLabel.text = [NSString stringWithFormat:@"$%1.0f",
                                                                [self.roster.remainingSalary floatValue]];
    }
    if (_numEntrantsLabel) {
        _numEntrantsLabel.text = [NSString stringWithFormat:@"%@ %@",
                                                            self.roster.contest[@"num_rosters"],
                                                            NSLocalizedString(@"Contest Entrants", nil)];
    }
    if (chosenPlayer && _state == FFContestViewControllerStateShowRoster) {
        NSString* text = slots.count > 1 ? NSLocalizedString(@"Enter now and finish later.", nil)
                                         : NSLocalizedString(@"All Slots are Filled!", nil);
        [self showSubmitRosterBanner:text];
    } else {
        [self hideSubmitRosterBanner];
    }
}

@end
