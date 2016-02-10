/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

#import "AuthenticationConstants.h"

@implementation AuthenticationConstants

// You will set your application's clientId and redirect URI.
NSString * const kRedirectUri = @"ENTER_YOUR_REDIRECT_URI";
NSString * const kClientId    = @"ENTER_YOUR_CLIENT_ID";
NSString * const kResourceId  = @"https://graph.microsoft.com";
NSString * const kAuthority   = @"https://login.microsoftonline.com/common";

// This app uses Google Custom Search.
// To enable image search in the app, you'll need to supply the
// API Key and custom search engine ID (cx) for Google Custom Search
NSString * const kGoogleAPIKey = @"ENTER_Google_API_KEY";
NSString * const kGoogleCX     = @"ENTER_Google_CX";

@end
