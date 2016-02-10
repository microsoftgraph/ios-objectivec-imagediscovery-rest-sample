/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

#import <Foundation/Foundation.h>

@interface ImageSearchManager : NSObject

// Searches and returns array of results in ImageResult form.
+ (void)searchForImage:(NSString *)searchTerm
            completion:(void (^)(NSArray *, NSError *))completion;

@end
