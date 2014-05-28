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
#import "FFPasswordController.h"
#import "FFAlertView.h"
#import "FFControllerProtocol.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <NSData+Base64.h>
#import <UIImage+Resize.h>

#define AVATAR_SIZE ( 128.f )

@interface FFMyAccountViewController ()
    <UITableViewDataSource, UITableViewDelegate, FFValueEntryControllerDelegate, FFPasswordControllerDelegate,
     UIImagePickerControllerDelegate, UINavigationControllerDelegate, FFControllerProtocol>

@property(nonatomic) UITableView* tableView;
@property(nonatomic) FFAlertView* photoAlert;

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
        vc.sectionTitle = @"Set Name";
    } else if ([segue.identifier isEqualToString:@"GotoEmail"]) {
        FFValueEntryController* vc = segue.destinationViewController;
        vc.keyboardType = UIKeyboardTypeEmailAddress;
        vc.autocapitalizationType = UITextAutocapitalizationTypeNone;
        vc.value = user.email;
        vc.name = segue.identifier;
        vc.delegate = self;
        vc.sectionTitle = @"Set Email";
    } else if ([segue.identifier isEqualToString:@"GotoPassword"]) {
        FFPasswordController* vc = segue.destinationViewController;
        vc.delegate = self;
    }
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

    UIImageView* disclosure = [[UIImageView alloc] initWithFrame:CGRectMake(295.f,
                                                                            indexPath.section == 1 ? 18.5 : 23.5,
                                                                            8.f, 13.f)];
    disclosure.image = [UIImage imageNamed:@"accessory_disclosure_dark"];
    disclosure.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:disclosure];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;

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
            label.text = @"No Name Set";
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
            label.text = @"Change...";
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView
heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 1) {
        return 50.f;
    }
    return 60.f;
}

- (CGFloat)tableView:(UITableView*)tableView
heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 50.f;
    }
    return 35.f;
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
        titleLabel.text = @"Settings";
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
            titleLabel.text = @"Avatar";
        } else if (section == 2) {
            titleLabel.text = @"Name";
        } else if (section == 3) {
            titleLabel.text = @"Email";
        } else if (section == 4) {
            titleLabel.text = @"Password";
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
        UIButton* camera = [FFAlertView blueButtonTitled:@"Take Photo"];
        [camera addTarget:self
                      action:@selector(takePhoto:)
            forControlEvents:UIControlEventTouchUpInside];
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            camera.enabled = NO;
            camera.alpha = .3;
        }

        UIButton* roll = [FFAlertView blueButtonTitled:@"Choose Photo"];
        [roll addTarget:self
                      action:@selector(choosePhoto:)
            forControlEvents:UIControlEventTouchUpInside];

        UIButton* cancel = [FFAlertView greyButtonTitled:@"Cancel"];
        [cancel addTarget:self
                      action:@selector(cancelPhoto:)
            forControlEvents:UIControlEventTouchUpInside];

        _photoAlert = [[FFAlertView alloc] initWithTitle:nil
                                            message:nil
                                            buttons:@[
                                                        camera,
                                                        roll,
                                                        cancel
                                                    ]];
        [_photoAlert showInView:self.navigationController.view];
    } else if (indexPath.section == 2) {
        [self performSegueWithIdentifier:@"GotoName"
                                  sender:nil];
    } else if (indexPath.section == 3) {
        [self performSegueWithIdentifier:@"GotoEmail"
                                  sender:nil];
    } else if (indexPath.section == 4) {
        [self performSegueWithIdentifier:@"GotoPassword"
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
    [_photoAlert hide];
    _photoAlert = nil;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController*)picker
didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    @weakify(self)
    [self dismissViewControllerAnimated:YES
                             completion:
     ^{
         @strongify(self)
         __block FFAlertView* alert = [self showAlert];
         [self->_photoAlert hide];
         self->_photoAlert = nil;

         UIImage* image = info[UIImagePickerControllerOriginalImage];
         CGFloat aspectImage = image.size.width / image.size.height;
         BOOL horizontal = image.size.width > image.size.height;
         CGFloat scaledWidth = horizontal ? AVATAR_SIZE : aspectImage * AVATAR_SIZE;
         CGFloat scaledHeight = horizontal ? AVATAR_SIZE / aspectImage : AVATAR_SIZE;
         UIImage* scaledImage = [image resizedImageToFitInSize:CGSizeMake(scaledWidth, scaledHeight) scaleIfSmaller:YES];
         NSURL* imagePath = info[UIImagePickerControllerReferenceURL];

         NSString* name = imagePath.lastPathComponent;
         NSData* imageData = UIImagePNGRepresentation(scaledImage);
         NSString* imageString = [imageData base64EncodedString];

         [self.session.user updateAvatar:imageString
                                    name:name ? name : @"avatar.png"
                               withBlock:
          ^(id successObj) {
              @strongify(self)
              [alert hide];
              [self.tableView reloadData];
          }
                                 failure:
          ^(NSError * error) {
              @strongify(self)
              [alert hide];
              [self showError:error];
          }];
     }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark - FFValueEntryControllerDelegate

- (void)valueEntryController:(FFValueEntryController*)controller
               didEnterValue:(NSString*)value
{
    __block FFAlertView* alert = [self showAlert];
    if ([controller.name isEqualToString:@"GotoName"]) {
        @weakify(self)
        [self.session.user updateName:value
                            withBlock:
         ^(id successObj) {
             @strongify(self)
             [alert hide];
             [self.tableView reloadData];
         }
                              failure:
         ^(NSError * error) {
             @strongify(self)
             [alert hide];
             [self showError:error];
         }];
    } else if ([controller.name isEqualToString:@"GotoEmail"]) {
        @weakify(self)
        [self.session.user updateEmail:value
                             withBlock:
         ^(id successObj) {
             @strongify(self)
             [alert hide];
             [self.tableView reloadData];
         }
                               failure:
         ^(NSError * error) {
             @strongify(self)
             [alert hide];
             [self showError:error];
         }];
    }
}

#pragma mark - FFPasswordControllerDelegate

- (void)updatePassword:(NSString*)password
               current:(NSString*)current
{
    __block FFAlertView* alert = [self showAlert];
    @weakify(self)
    [self.session.user updatePassword:password
                              current:current
                            withBlock:
     ^(id successObj) {
         [alert hide];
     }
                              failure:
     ^(NSError * error) {
         @strongify(self)
         [alert hide];
         [self showError:error];
     }];
}

#pragma mark - private

- (FFAlertView*)showAlert
{
    FFAlertView* alert = [[FFAlertView alloc] initWithTitle:@"Saving"
                                                   messsage:nil
                                               loadingStyle:FFAlertViewLoadingStylePlain];
    [alert showInView:self.navigationController.view];
    return alert;
}

- (void)showError:(NSError*)error
{
    FFAlertView* ealert = [[FFAlertView alloc] initWithError:error
                                                       title:nil
                                           cancelButtonTitle:nil
                                             okayButtonTitle:@"Dismiss"
                                                    autoHide:YES];
    [ealert showInView:self.navigationController.view];
}

@end
