/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

#import <UIKit/UIKit.h>

@interface ImageFilterViewController : UIViewController

@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, strong) NSString *fullSizeImageURLString;

@end
