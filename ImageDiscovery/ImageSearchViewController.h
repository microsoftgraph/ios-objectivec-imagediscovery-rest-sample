/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

#import <UIKit/UIKit.h>

@interface ImageSearchViewController : UICollectionViewController

@property (strong, nonatomic) UIImage *selectedImage;
@property (strong, nonatomic) NSString *fullImageURLString;

- (void) dismissKeyboard;

@end
