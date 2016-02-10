/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

#import "ImageActionTableViewController.h"
#import "ImageFilterViewController.h"
#import <UIImageView+AFNetworking.h>


@interface ImageFilterViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *mainPreviewImageView;

@end

@implementation ImageFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mainPreviewImageView.image = self.thumbnailImage;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.fullSizeImageURLString) {
        
        [self.mainPreviewImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.fullSizeImageURLString] ] placeholderImage:self.thumbnailImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            self.mainPreviewImageView.image = image;
            self.selectedImage = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"error fetching full size image\n%@", error.localizedDescription);
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (IBAction)originalButtonPressed:(id)sender {

    self.mainPreviewImageView.image = self.selectedImage;
}

- (IBAction)blackAndWhitePressed:(id)sender {

    UIImage *image = self.selectedImage;
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    CGImageRef grayImage = CGBitmapContextCreateImage(context);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, nil, kCGImageAlphaOnly);
    CGContextDrawImage(context, imageRect, [image CGImage]);
    CGImageRef mask = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    
    UIImage *grayScaleImage = [UIImage imageWithCGImage:CGImageCreateWithMask(grayImage, mask)
                                                  scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(grayImage);
    CGImageRelease(mask);
    
    self.mainPreviewImageView.image = grayScaleImage;
    
}

- (IBAction)selectPressed:(id)sender {
     [self performSegueWithIdentifier:@"sendStoreImage" sender:nil];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"sendStoreImage"]) {
        ImageActionTableViewController *vc = segue.destinationViewController;
        vc.image = self.mainPreviewImageView.image;
    }
    
}


@end
