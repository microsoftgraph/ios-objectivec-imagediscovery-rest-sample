/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

#import "CameraViewController.h"
#import "ImageFilterViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <TargetConditionals.h>


@interface CameraViewController () {
    AVCaptureSession *session;
    AVCaptureStillImageOutput *stillImageOutput;
    AVCaptureVideoPreviewLayer *previewLayer;
    AVCaptureDevice *captureDevice;
}

@property (strong, nonatomic) IBOutlet UIView *cameraView;
@property (strong, nonatomic) IBOutlet UILabel *cameraLabel;


@end

@implementation CameraViewController



- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startCamera];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopCamera];
}


#pragma mark - camera

- (void)startCamera {
    if (TARGET_IPHONE_SIMULATOR) {
        return;
    }
    
    self.cameraLabel.text = @"Loading Camera";
    
    if (!session) {
        [self initializeCamera];
    }
    [session startRunning];
}

- (void)stopCamera {
    if (TARGET_IPHONE_SIMULATOR) {
        return;
    }
    
    [session stopRunning];
}

- (IBAction)takePhotoButtonPressed:(UIButton *)sender {
    [self takePhotoWithCompletion:^(NSData *imageData, NSError *error) {
        if (error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:error.localizedDescription
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"Close"
                                                      style:UIAlertActionStyleCancel handler:nil]];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            self.selectedImage = [UIImage imageWithData:imageData];
            [self.parentViewController performSegueWithIdentifier:@"cameraImageFilter" sender:nil];
        }
    }];
    
}

- (void)initializeCamera {
    session = [[AVCaptureSession alloc] init];
    [session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    
    captureDevice = inputDevice;
    
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice
                                                                              error:&error];
    
    if ([session canAddInput:deviceInput]) {
        [session addInput:deviceInput];
    }
    
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setBackgroundColor:[UIColor clearColor].CGColor];
    
    CALayer *rootLayer = [self.cameraView layer];
    [rootLayer setMasksToBounds:NO];
    [previewLayer setFrame:CGRectMake(0, 0, rootLayer.bounds.size.width, rootLayer.bounds.size.height)];
    [rootLayer addSublayer:previewLayer];
    
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = @{AVVideoCodecJPEG:AVVideoCodecKey};
    [stillImageOutput setOutputSettings:outputSettings];
    [session addOutput:stillImageOutput];
}


- (void)takePhotoWithCompletion:(void (^)(NSData *imageData, NSError *error))completion {
    if (TARGET_IPHONE_SIMULATOR) {
        completion(UIImagePNGRepresentation([UIImage imageNamed:@"SamplePhoto"]), nil);
    }
    else {
        // Capture image & upload
        AVCaptureConnection *videoConnection = nil;
        
        for (AVCaptureConnection *connection in stillImageOutput.connections) {
            for (AVCaptureInputPort *port in [connection inputPorts]) {
                if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                    videoConnection = connection;
                    break;
                }
            }
            if (videoConnection) {
                break;
            }
        }
        
        [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                      completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                          if (imageDataSampleBuffer) {
                                                              NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                              completion(imageData, nil);
                                                          }
                                                          else{
                                                              completion(nil, error);
                                                          }
                                                      }];
    }
}

#pragma mark - Helper

- (UIImage*)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


@end
