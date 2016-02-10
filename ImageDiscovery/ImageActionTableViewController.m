/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

#import "AuthenticationManager.h"
#import "ImageActionTableViewController.h"
#import <AFNetworking/AFNetworking.h>


@interface ImageActionTableViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *signInOutButton;
@property (weak, nonatomic) IBOutlet UITableViewCell *sendEmailCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *storeOneDriveCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *storeLocalCell;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;

@property (strong, nonatomic) AuthenticationManager *authManager;
@property (assign, nonatomic) BOOL isConnected;

@end

@implementation ImageActionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    self.previewImageView.image = self.image;
    
    NSLog(@"userconnected %d", [AuthenticationManager sharedInstance].isConnected);
    if ([AuthenticationManager sharedInstance].isConnected) {
        [self setUserConnected:YES];
    }
    else {
        [self setUserConnected:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - O365 connection

- (void)setUserConnected:(BOOL)connected {
    self.isConnected = connected;
    
    if (connected) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.signInOutButton.title = @"Log out";
        });
        self.isConnected = YES;
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.signInOutButton.title = @"Connect";
        });
        self.isConnected = NO;
    }
}


#pragma mark - Sign in and out
- (IBAction)signInOutButtonPressed:(id)sender {
    if (!self.isConnected) {
        [[AuthenticationManager sharedInstance] acquireAuthTokenCompletion:^(ADAuthenticationResult *result) {
            if (result.status == AD_SUCCEEDED){
                [self setUserConnected:YES];
            }
        }];
    }
    else {
        [[AuthenticationManager sharedInstance] clearCredentials];
        [self setUserConnected:NO];
    }
}

#pragma mark - Upload to OneDrive
- (void)uploadToOneDrive {
    
    [[AuthenticationManager sharedInstance] acquireAuthTokenCompletion:^(ADAuthenticationResult *result) {
        if (result.status == AD_SUCCEEDED) {
            [self setUserConnected:YES];
            
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"Save to OneDrive"
                                                  message:@"Save this image with a file name.\nIt will be stored under /ImageDiscovery/{filename}.jpg"
                                                  preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
             {
                 textField.placeholder = NSLocalizedString(@"Enter file name", @"Filename");
             }];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action)
                                       {
                                           UITextField *filename = alertController.textFields.firstObject;
                                           NSData *photoData = UIImageJPEGRepresentation(self.image, 0.5);
                                           
                                           [self uploadToOneDriveRESTWithFilename:filename.text content:photoData];
                                           
                                           
                                       }];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:nil];
            [alertController addAction:okAction];
            [alertController addAction:cancelAction];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alertController animated:YES completion:nil];
            });
        }
        else {
            NSLog(@"failed to acquire access token");
            self.storeOneDriveCell.detailTextLabel.text = @"Failed, please check log";
        }
    }];
}

- (void)uploadToOneDriveRESTWithFilename:(NSString*) filename
                                 content:(NSData*) data{
    self.storeOneDriveCell.detailTextLabel.text = @"Storing";
    
    NSMutableString *urlString = [NSMutableString stringWithString:@"https://graph.microsoft.com/v1.0/me/drive/root:/ImageDiscovery/<FILENAME>.jpg:/content"];
    
    [urlString replaceOccurrencesOfString:@"<FILENAME>"
                               withString:filename
                                  options:0 range:(NSRange){0, [urlString length]}];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json, text/plain, */*" forHTTPHeaderField:@"Accept"];
    
    NSString *authorization = [NSString stringWithFormat:@"Bearer %@", [AuthenticationManager sharedInstance].accessToken];
    [request setValue:authorization forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:data];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [[manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (!error && ((NSHTTPURLResponse*)response).statusCode == 201) {
            self.storeOneDriveCell.detailTextLabel.text = @"Done";
        }
        else {
            NSLog(@"%@", error.localizedDescription);
            NSLog(@"%@", response);
            self.storeOneDriveCell.detailTextLabel.text = @"Failed, please check log";
        }
    }] resume];
    
}

#pragma mark - Send mail
- (void)sendMail {
    
    [[AuthenticationManager sharedInstance] acquireAuthTokenCompletion:^(ADAuthenticationResult *result) {
        if (result.status == AD_SUCCEEDED) {
            [self setUserConnected:YES];
            
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"Send mail"
                                                  message:@"Email this image to"
                                                  preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
             {
                 textField.placeholder = NSLocalizedString(@"Enter email address", @"Email");
             }];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action)
                                       {
                                           UITextField *emailAddress = alertController.textFields.firstObject;
                                           NSData *postData = [self mailContent:[UIImageJPEGRepresentation(self.image, 0.5) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]
                                                                             to:emailAddress.text];
                                           
                                           [self sendMailREST:postData];
                                       }];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:nil];
            [alertController addAction:okAction];
            [alertController addAction:cancelAction];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alertController animated:YES completion:nil];
            });
        }
        else {
            NSLog(@"failed to acquire access token");
            self.sendEmailCell.detailTextLabel.text = @"Failed, please check log";
        }
    }];
}

- (NSData *)mailContent:(NSString *)contentString
                     to:(NSString *)emailAddress
{
    
    NSString *jsonContentPath = [[NSBundle mainBundle] pathForResource:@"EmailPostContent" ofType:@"json"];
    NSMutableString *jsonContentString = [NSMutableString stringWithContentsOfFile:jsonContentPath encoding:NSUTF8StringEncoding error:nil];
    
    [jsonContentString replaceOccurrencesOfString:@"<EMAIL>"
                                       withString:emailAddress
                                          options:0 range:(NSRange){0, [jsonContentString length]}];
    
    [jsonContentString replaceOccurrencesOfString:@"<ContentBytes>"
                                       withString:contentString
                                          options:0 range:(NSRange){0, [jsonContentString length]}];
    return [jsonContentString dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)sendMailREST:(NSData *)postData {
    self.sendEmailCell.detailTextLabel.text = @"Sending";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://graph.microsoft.com/v1.0/me/microsoft.graph.sendmail"]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json, text/plain, */*" forHTTPHeaderField:@"Accept"];
    
    NSString *authorization = [NSString stringWithFormat:@"Bearer %@", [[AuthenticationManager sharedInstance] accessToken]];
    [request setValue:authorization forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:postData];
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [[manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSLog(@"%d", (int)(((NSHTTPURLResponse*)response).statusCode));
        
        if (!error && ((NSHTTPURLResponse*)response).statusCode == 202) {
            self.sendEmailCell.detailTextLabel.text = @"Done";
        }
        else {
            NSLog(@"%@", error.localizedDescription);
            NSLog(@"%@", response);
            self.sendEmailCell.detailTextLabel.text = @"Failed, please check log";
        }
    }] resume];
}


#pragma mark - Save to local device
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo
{
    if (error) {
        NSLog(@"%@", error.localizedDescription);
        self.storeLocalCell.detailTextLabel.text = @"Failed, please check log";
    }
    else {
        self.storeLocalCell.detailTextLabel.text = @"Saved";
    }
}


#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (selectedCell == _sendEmailCell) {
        [self sendMail];
    }
    else if(selectedCell == _storeLocalCell) {
        UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
    
    else if(selectedCell == _storeOneDriveCell) {
        [self uploadToOneDrive];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
