//
//  FFMyAccountViewController.m
//  FMF Football
//
//  Created by Samuel Sutch on 10/3/13.
//  Copyright (c) 2013 FairMarketFantasy. All rights reserved.
//

#import "FFMyAccountViewController.h"
#import "FFSessionViewController.h"
#import "FFValueEntryController.h"
#import "FFAlertView.h"
#import "FFControllerProtocol.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface FFMyAccountViewController ()
    <UITableViewDataSource, UITableViewDelegate, FFValueEntryControllerDelegate,
     UIImagePickerControllerDelegate, UINavigationControllerDelegate, FFControllerProtocol>

@property(nonatomic) UITableView* tableView;
@property(nonatomic) FFAlertView* alert;
@property(nonatomic) BOOL shouldSave;

@end

@implementation FFMyAccountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.backgroundColor = [FFStyle darkGreen];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClass:[UITableViewCell class]
       forCellReuseIdentifier:@"Cell"];
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // TODO: fill content
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_shouldSave) {
        FFAlertView* alert = [[FFAlertView alloc] initWithTitle:NSLocalizedString(@"Saving", nil)
                                                       messsage:nil
                                                   loadingStyle:FFAlertViewLoadingStylePlain];
        [alert showInView:self.navigationController.view];
        FFUser* user = (FFUser*)self.session.user;
        [user updateInBackgroundWithBlock:^(id successObj)
         {
             [alert hide];
         }
                                  failure:
         ^(NSError * error)
         {
             [alert hide];
             FFAlertView* ealert = [[FFAlertView alloc] initWithError:error
                                                                title:nil
                                                    cancelButtonTitle:nil
                                                      okayButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                             autoHide:YES];
             [ealert showInView:self.navigationController.view];
         }];
        _shouldSave = NO;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue
                 sender:(id)sender
{
    FFUser* user = (FFUser*)self.session.user;
    if ([segue.identifier isEqualToString:@"GotoName"]) {
        FFValueEntryController* vc = segue.destinationViewController;
        vc.keyboardType = UIKeyboardTypeDefault;
        vc.autocapitalizationType = UITextAutocapitalizationTypeWords;
        vc.value = user.name;
        vc.name = segue.identifier;
        vc.delegate = self;
        vc.sectionTitle = NSLocalizedString(@"Set Name", nil);
    } else if ([segue.identifier isEqualToString:@"GotoEmail"]) {
        FFValueEntryController* vc = segue.destinationViewController;
        vc.keyboardType = UIKeyboardTypeEmailAddress;
        vc.autocapitalizationType = UITextAutocapitalizationTypeNone;
        vc.value = user.email;
        vc.name = segue.identifier;
        vc.delegate = self;
        vc.sectionTitle = NSLocalizedString(@"Set Email", nil);
    }
    _shouldSave = YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView*)tableView
 numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    return 1;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                            forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor colorWithWhite:.94f
                                                         alpha:1.f];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    UIImageView* disclosure = [[UIImageView alloc] initWithFrame:CGRectMake(295, 14.5, 10, 15)];
    disclosure.image = [UIImage imageNamed:@"accessory_disclosure_dark"];
    disclosure.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:disclosure];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;

    FFUser* user = (FFUser*)self.session.user;

    if (indexPath.section == 1) {
        UIImageView* avatar = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 40, 40)];
        avatar.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:avatar];

        [avatar setImageWithURL: [NSURL URLWithString:user.imageUrl]
                      placeholderImage: [UIImage imageNamed:@"defaultuser"]
           usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];

    } else if (indexPath.section == 2) {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 320,
                                                                   cell.contentView.frame.size.height)];
        label.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        label.font = [FFStyle regularFont:17];
        label.textColor = [FFStyle greyTextColor];
        [cell.contentView addSubview:label];
        if (user.name != nil && user.name.length) {
            label.text = user.name;
        } else {
            label.text = NSLocalizedString(@"No Name Set", nil);
        }
    } else if (indexPath.section == 3) {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 320,
                                                                   cell.contentView.frame.size.height)];
        label.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        label.font = [FFStyle regularFont:17];
        label.textColor = [FFStyle greyTextColor];
        [cell.contentView addSubview:label];
        label.text = user.email;
    } else if (indexPath.section == 4) {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 320,
                                                                   cell.contentView.frame.size.height)];
        label.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        label.font = [FFStyle regularFont:17];
        label.textColor = [FFStyle greyTextColor];
        [cell.contentView addSubview:label];

        if (indexPath.row == 0) {
            label.text = NSLocalizedString(@"Change", nil);
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView
heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 1) {
        return 50;
    }
    return 60;
}

- (CGFloat)tableView:(UITableView*)tableView
heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 50;
    }
    return 35;
}

- (UIView*)tableView:(UITableView*)tableView
 viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        header.backgroundColor = [UIColor colorWithWhite:.9f
                                                   alpha:1.f];
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 290, 50)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [FFStyle lightFont:26.f];
        titleLabel.textColor = [FFStyle tableViewSectionHeaderColor];
        titleLabel.text = NSLocalizedString(@"Settings", nil);
        [header addSubview:titleLabel];
        return header;
    } else {
        UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 35)];
        header.backgroundColor = [UIColor colorWithWhite:.9f
                                                   alpha:1.f];
        UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
        separator.backgroundColor = [UIColor colorWithWhite:.8
                                                      alpha:1];
        [header addSubview:separator];

        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 290, 35)];
        titleLabel.font = [FFStyle regularFont:17.f];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [FFStyle darkGreyTextColor];
        if (section == 1) {
            titleLabel.text = NSLocalizedString(@"Avatar", nil);
        } else if (section == 2) {
            titleLabel.text = NSLocalizedString(@"Name", nil);
        } else if (section == 3) {
            titleLabel.text = NSLocalizedString(@"Email", nil);
        } else if (section == 4) {
            titleLabel.text = NSLocalizedString(@"Password", nil);
        }
        [header addSubview:titleLabel];
        return header;
    }
}

- (void)tableView:(UITableView*)tableView
 didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    if (indexPath.section == 1) {
        UIButton* camera = [FFAlertView blueButtonTitled:NSLocalizedString(@"Take Photo", nil)];
        [camera addTarget:self
                      action:@selector(takePhoto:)
            forControlEvents:UIControlEventTouchUpInside];
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            camera.enabled = NO;
            camera.alpha = .3;
        }

        UIButton* roll = [FFAlertView blueButtonTitled:NSLocalizedString(@"Choose Photo", nil)];
        [roll addTarget:self
                      action:@selector(choosePhoto:)
            forControlEvents:UIControlEventTouchUpInside];

        UIButton* cancel = [FFAlertView greyButtonTitled:NSLocalizedString(@"Cancel", nil)];
        [cancel addTarget:self
                      action:@selector(cancelPhoto:)
            forControlEvents:UIControlEventTouchUpInside];

        _alert = [[FFAlertView alloc] initWithTitle:nil
                                            message:nil
                                            buttons:@[
                                                        camera,
                                                        roll,
                                                        cancel
                                                    ]];
        [_alert showInView:self.navigationController.view];
    } else if (indexPath.section == 2) {
        [self performSegueWithIdentifier:@"GotoName"
                                  sender:nil];
    } else if (indexPath.section == 3) {
        [self performSegueWithIdentifier:@"GotoEmail"
                                  sender:nil];
    }
}

#pragma mark - button actions

- (void)takePhoto:(id)sender
{
    UIImagePickerController* picker = UIImagePickerController.new;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.mediaTypes = [NSArray arrayWithObject:(id)kUTTypeImage];
    picker.delegate = self;
    [self presentViewController:picker
                       animated:YES
                     completion:nil];
}

- (void)choosePhoto:(id)sender
{
    UIImagePickerController* picker = UIImagePickerController.new;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = [NSArray arrayWithObject:(id)kUTTypeImage];
    picker.delegate = self;
    [self presentViewController:picker
                       animated:YES
                     completion:nil];
}

- (void)cancelPhoto:(id)sender
{
    [_alert hide];
    _alert = nil;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController*)picker
didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    //    UIImage *img = info[UIImagePickerControllerOriginalImage];

    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark - FFValueEntryControllerDelegate

- (void)valueEntryController:(FFValueEntryController*)cont
               didEnterValue:(NSString*)value
{
    FFUser* user = (FFUser*)self.session.user;
    if ([cont.name isEqualToString:@"GotoName"]) {
        user.name = value;
    } else if ([cont.name isEqualToString:@"GotoEmail"]) {
        user.email = value;
    }
    [self.tableView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)valueEntryController:(FFValueEntryController*)cont
              didUpdateValue:(NSString*)value
{
    FFUser* user = (FFUser*)self.session.user;
    if ([cont.name isEqualToString:@"GotoName"]) {
        user.name = value;
    } else if ([cont.name isEqualToString:@"GotoEmail"]) {
        user.email = value;
    }
}

@end
