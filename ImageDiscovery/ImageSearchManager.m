/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

#import "AuthenticationConstants.h"
#import "ImageResult.h"
#import "ImageSearchManager.h"
#import <AFNetworking/AFNetworking.h>


@implementation ImageSearchManager

/**
 *  Searches images and returns array of ImageResult.
 *  This uses Google Custom Search but can be replaced with any other search engines
 */
+ (void)searchForImage:(NSString *)searchTerm
            completion:(void (^)(NSArray *, NSError *))completion
{
    NSString *URLString = @"https://www.googleapis.com/customsearch/v1";
    NSDictionary *parameters = @{@"key":kGoogleAPIKey,
                                 @"cx":kGoogleCX,
                                 @"searchType":@"image",
                                 @"rights":@"cc_publicdomain",
                                 @"start":@"1",
                                 @"num":@"10",
                                 @"q":searchTerm,
                                 };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:URLString
      parameters:parameters progress:nil
         success:^(NSURLSessionTask *task, id responseObject) {
             NSMutableArray *result = [NSMutableArray new];
             NSArray *items = [responseObject objectForKey:@"items"];

             [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                 ImageResult *image = [ImageResult new];
                 image.thumbnailURLString = [[obj objectForKey:@"image"] objectForKey:@"thumbnailLink"];
                 image.imageURLString = [obj objectForKey:@"link"];
                 
                 [result addObject:image];
             }];
             completion(result, nil);
         } failure:^(NSURLSessionTask *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             completion(nil, error);
         }];
}


@end
