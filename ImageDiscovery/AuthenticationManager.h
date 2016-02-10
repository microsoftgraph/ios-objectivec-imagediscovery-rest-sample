/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ADAuthenticationContext.h>

/**
 *  AuthenticationManager
 *  This class is used as an interface between a UIViewController and authentication.
 *  If additional authentication mechanisms are used, this class is scalable.
 */

@interface AuthenticationManager : NSObject

+ (AuthenticationManager*)sharedInstance;

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) ADTokenCacheStoreItem *tokenCacheItem;

// Authenticate
- (void)acquireAuthTokenCompletion:(void (^)(ADAuthenticationResult *result))completion;
- (void)acquireAuthTokenSilentlyWithCompletion:(void (^)(ADAuthenticationResult *result))completion;

// Clears the ADAL token cache and the cookie cache.
- (void) clearCredentials;

// Check for status
- (BOOL) isConnected;

@end

