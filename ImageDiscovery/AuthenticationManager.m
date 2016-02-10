/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

#import "AuthenticationConstants.h"
#import "AuthenticationManager.h"
#import <ADAuthenticationResult.h>
#import <ADAuthenticationSettings.h>
#import <ADTokenCacheStoreItem.h>


NSString * const kUserConnectionKey = @"USER_CONNECTED";

@interface AuthenticationManager()

@property (nonatomic, strong) ADAuthenticationContext *context;

@end

@implementation AuthenticationManager

// Use a single authentication manager for the application.
+ (AuthenticationManager *)sharedInstance {
    static AuthenticationManager *sharedInstance;
    static dispatch_once_t onceToken;
    
    // Initialize the AuthenticationManager only once.
    dispatch_once(&onceToken, ^{
        // Disable Keychain sharing
        // For more information, please visit https://github.com/AzureAD/azure-activedirectory-library-for-objc
        [[ADAuthenticationSettings sharedInstance] setSharedCacheKeychainGroup:@"com.microsoft.ImageDiscovery"];

        sharedInstance = [[AuthenticationManager alloc] init];
        ADAuthenticationError *error;
        sharedInstance.context = [ADAuthenticationContext authenticationContextWithAuthority:kAuthority error:&error];

        if (error) {
            NSLog(@"%@", error.localizedDescription);
            sharedInstance = nil;
        }
    });
    return sharedInstance;
}

#pragma mark - acquire token
- (void)acquireAuthTokenCompletion:(void (^)(ADAuthenticationResult *result))completion {
    [self.context acquireTokenWithResource:kResourceId
                                  clientId:kClientId
                               redirectUri:[NSURL URLWithString:kRedirectUri]
                           completionBlock:^(ADAuthenticationResult *result) {
                               if (result.status == AD_SUCCEEDED){
                                   self.accessToken = result.accessToken;
                                   self.tokenCacheItem = result.tokenCacheStoreItem;
                                   [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserConnectionKey];
                               }
                               completion(result);
                           }];
}

- (void)acquireAuthTokenSilentlyWithCompletion:(void (^)(ADAuthenticationResult *result))completion {
    [self.context acquireTokenSilentWithResource:kResourceId
                                        clientId:kClientId
                                     redirectUri:[NSURL URLWithString:kRedirectUri]
                                 completionBlock:^(ADAuthenticationResult *result) {
                                     if (result.status ==AD_SUCCEEDED){
                                         self.accessToken = result.accessToken;
                                         self.tokenCacheItem = result.tokenCacheStoreItem;
                                         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserConnectionKey];
                                     }
                                     completion(result);
                                 }];
}

#pragma mark - clear credentials
//Clears the ADAL token cache and the cookie cache.
- (void)clearCredentials{
    
    // Remove all the cookies from this application's sandbox. The authorization code is stored in the
    // cookies and ADAL will try to get to access tokens based on auth code in the cookie.
    NSHTTPCookieStorage *cookieStore = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in cookieStore.cookies) {
        [cookieStore deleteCookie:cookie];
    }
    
    self.accessToken = nil;
    self.tokenCacheItem = nil;
    [self.context.tokenCacheStore removeAllWithError:nil];
}

#pragma mark - status
- (BOOL) isConnected {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kUserConnectionKey];
}

@end

