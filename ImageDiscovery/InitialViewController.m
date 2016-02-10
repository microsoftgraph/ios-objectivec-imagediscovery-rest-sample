/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

#import "CameraViewController.h"
#import "ImageFilterViewController.h"
#import "ImageSearchViewController.h"
#import "InitialViewController.h"


@interface InitialViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *switchModeButton;
@property (nonatomic, strong) CameraViewController *cameraViewController;
@property (nonatomic, strong) ImageSearchViewController *imageSearchViewController;
@end

@implementation InitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.switchModeButton.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.switchModeButton.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UIScrollView delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.imageSearchViewController dismissKeyboard];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.x == 0) {
        [self switchButtonToCamera:NO];
    }
    else {
        [self switchButtonToCamera:YES];
    }
}

#pragma mark - Toggle Camera/Image search
- (IBAction)switchPictureMode:(id)sender {
    CGRect frame = self.scrollView.frame;
    if (self.scrollView.contentOffset.x == 0) {
        frame.origin.x = frame.size.width;
        frame.origin.y = 0;
        [self switchButtonToCamera:YES];
    }
    else {
        frame.origin.x = 0;
        frame.origin.y = 0;
        [self switchButtonToCamera:NO];
    }
    [self.scrollView scrollRectToVisible:frame animated:YES];
}



- (void)switchButtonToCamera:(BOOL)camera {
    if (camera) {
        [self.switchModeButton setImage:[UIImage imageNamed:@"Camera"]
                               forState:UIControlStateNormal];
    }
    else {
        [self.switchModeButton setImage:[UIImage imageNamed:@"Search"]
                               forState:UIControlStateNormal];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    if ([segue.identifier isEqualToString:@"embedCamera"]) {
        self.cameraViewController = segue.destinationViewController;
    }
    
    else if ([segue.identifier isEqualToString:@"embedImageSearch"]) {
        self.imageSearchViewController = segue.destinationViewController;
    }
    
    else if ([segue.identifier isEqualToString:@"cameraImageFilter"]) {
        ImageFilterViewController *vc = segue.destinationViewController;
        vc.selectedImage = self.cameraViewController.selectedImage;
        vc.thumbnailImage = self.cameraViewController.selectedImage;
    }
    
    else if ([segue.identifier isEqualToString:@"searchImageFilter"]) {
        ImageFilterViewController *vc = segue.destinationViewController;
        vc.selectedImage = self.imageSearchViewController.selectedImage;
        vc.thumbnailImage = self.imageSearchViewController.selectedImage;
        vc.fullSizeImageURLString = self.imageSearchViewController.fullImageURLString;
    }
}


@end
