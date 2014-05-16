//
//  FFValueEntryController.m
//  FMF Football
//
//  Created by Samuel Sutch on 9/30/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import "FFValueEntryController.h"
#import "FFTextField.h"

@interface FFValueEntryController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property(nonatomic) UITableView* tableView;
@property(nonatomic) UITextField* textField;

@end

@implementation FFValueEntryController

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
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerClass:[UITableViewCell class]
       forCellReuseIdentifier:@"Cell"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.delegate respondsToSelector:@selector(valueEntryController:didEnterValue:)]) {
        [self.delegate valueEntryController:self
                              didEnterValue:_textField.text];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView
heightForHeaderInSection:(NSInteger)section
{
    return 50.f;
}

- (UIView*)tableView:(UITableView*)tableView
viewForHeaderInSection:(NSInteger)section
{
    UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 50.f)];
    header.backgroundColor = [FFStyle white];
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.f, 0.f, 290.f, 50.f)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [FFStyle lightFont:26.f];
    titleLabel.textColor = [FFStyle tableViewSectionHeaderColor];
    titleLabel.text = self.sectionTitle;
    [header addSubview:titleLabel];
    return header;
}

- (void)tableView:(UITableView*)tableView
  willDisplayCell:(UITableViewCell*)cell
forRowAtIndexPath:(NSIndexPath*)indexPath
{
    [cell.contentView.subviews.firstObject becomeFirstResponder];
}

- (void)done:(UIControl*)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                            forIndexPath:indexPath];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    // tool bar
    UIToolbar* toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 44.f)];
    toolBar.items = @[
                      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                    target:nil
                                                                    action:NULL],
                      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                    target:self
                                                                    action:@selector(done:)]
                      ];
    // text field
    UITextField* field = _textField = [[FFTextField alloc] initWithFrame:CGRectMake(15.f, 4.f, 290.f, 38.f)];
    field.borderStyle = UITextBorderStyleNone;
    field.font = [FFStyle regularFont:17];
    field.textColor = [FFStyle darkGreyTextColor];
    field.delegate = self;
    field.keyboardType = self.keyboardType;
    field.autocapitalizationType = self.autocapitalizationType;
    [cell.contentView addSubview:field];
    field.inputAccessoryView = toolBar;
    // separator
    UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 1.f)];
    separator.backgroundColor = [UIColor colorWithWhite:.8f
                                            alpha:1.f];
    [cell.contentView addSubview:separator];
    // separator 2
    UIView* separator2 = [[UIView alloc] initWithFrame:CGRectMake(0.f,
                                                                  cell.contentView.frame.size.height - 1.f,
                                                                  320.f, 1.f)];
    separator2.backgroundColor = [UIColor colorWithWhite:.8f
                                                   alpha:1.f];
    [cell.contentView addSubview:separator2];
    return cell;
}

@end
