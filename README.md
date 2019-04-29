# [ARCHIVED] Office 365 Microsoft Graph Image Discovery for iOS

## IMPORTANT

This project is being archived. As part of the archival process, we're closing all open issues and pull requests.

You can continue to use this sample "as-is", but it won't be maintained moving forward. We apologize for any inconvenience.

## Overview

Image Discovery is an iOS sample app that allows you either to take a picture or to search the web for one, and process the fetched image. You can then save it in the cloud or mail to a recipient. For example, you can take a picture, convert the image to black and white, and push it to OneDrive for Business to store.

![Camera](https://github.com/OfficeDev/O365-iOS-Microsoft-Graph-Image-Discovery/blob/master/Images/camera.gif)

Or, you can search for an image via Google Custom Search and mail it to a friend.

![Search](https://github.com/OfficeDev/O365-iOS-Microsoft-Graph-Image-Discovery/blob/master/Images/search.gif)

This sample illustrates how to use Microsoft Graph, a unified API endpoint, for working with mail and files in Office 365. For more information about Microsoft Graph see the Microsoft Graph overview page.

## Prerequisites
* [Xcode](https://developer.apple.com/xcode/downloads/) from Apple
* Installation of [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html) as a dependency manager.
* An Office 365 account. You can sign up for [an Office 365 Developer subscription](https://aka.ms/devprogramsignup) that includes the resources that you need to start building Office 365 apps.

     > Note: If you already have a subscription, the previous link sends you to a page with the message *Sorry, you can’t add that to your current account*. In that case, use an account from your current Office 365 subscription.Mic
* A Microsoft Azure Tenant to register your application. Microsoft Azure Active Directory (AD) provides identity services that applications use for authentication and authorization. A trial subscription can be acquired here: [Microsoft Azure](https://account.windowsazure.com/SignUp).

     > Important: You'll also need to ensure your Azure subscription is bound to your Office 365 tenant. To do this, see the Active Directory Team's Blog post, [Creating and Managing Multiple Windows Azure Active Directories](http://blogs.technet.com/b/ad/archive/2013/11/08/creating-and-managing-multiple-windows-azure-active-directories.aspx). The **Adding a new directory** section will explain how to do this. You can also see [Set up your Office 365 development environment](https://msdn.microsoft.com/office/office365/howto/setup-development-environment#bk_CreateAzureSubscription) and the section **Associate your Office 365 account with Azure AD to create and manage apps** for more information.
      
* A client id (application id) and redirect uri values of an application registered in Azure. This sample application must be granted several permissions for **Microsoft Graph**. To create the registration, see [Grant permissions to the Snippets application in Azure](https://github.com/microsoftgraph/ios-objectivec-imagediscovery-rest-sample/wiki/Grant-permissions-to-the-Image-Discovery-application-in-Azure).

* This sample uses Google Custom Search to search for images. In order for the search functionality in this app to work, you'll need your own API key and custom search engine ID (cx). For more information about obtaining these values see [Google Custom Search](https://developers.google.com/custom-search/docs/overview). 

   > Note: The search functionality in this app is reliant on getting the API Key and search engine ID. The camera workflow, for getting an image, will still function without this information, but again you'll need these values for the search component in the app to work. Also, Google Custom Search is just being used as an example; you can implement other search engine options as needed.

       
## Running this sample in Xcode

1. Clone this repository
2. Use CocoaPods to import the Active Directory Authentication Library (ADAL) iOS dependency:
        
	     pod 'AFNetworking', ' ~> 3.0'
	     pod 'ADALiOS'

 This sample app already contains a podfile that will get the ADAL components (pods) into  the project. Simply navigate to the project from **Terminal** and run: 
        
        pod install
        
   For more information, see **Using CocoaPods** in [Additional Resources](#AdditionalResources)
  
3. Open **ImageDiscovery.xcworkspace**
4. Open **AuthenticationConstants.m**. You'll see that the **ClientID** (this is the application id from the registration process) and **RedirectUri** values can be added to the top of the file. Also you'll need to provide the Google API Key and the custom search engine ID (cx) for the search functionality to work. Supply the necessary values here:

        // You will set your application's Client ID and Redirect URI.
        NSString * const kRedirectUri = @"ENTER_YOUR_REDIRECT_URI";
        NSString * const kClientId    = @"ENTER_YOUR_CLIENT_ID";
        NSString * const kResourceId  = @"https://graph.microsoft.com";
        NSString * const kAuthority   = @"https://login.microsoftonline.com/common";
        
        // To enable image search in the app, you'll need to supply the API Key and 
        // custom search engine ID (cx) after registering for Google Images.
        NSString * const kGoogleAPIKey = @"ENTER_Google_API_KEY";
        NSString * const kGoogleCX     = @"ENTER_Google_CX";


5. Run the sample.

<a name="contributing"></a>
## Contributing ##

If you'd like to contribute to this sample, see [CONTRIBUTING.MD](/CONTRIBUTING.md).

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Questions and comments

We'd love to get your feedback about the Office 365 iOS Microsoft Graph Image Discovery project. You can send your questions and suggestions to us in the [Issues](https://github.com/OfficeDev/O365-iOS-Microsoft-Graph-Image-Discovery/issues) section of this repository.

Questions about Office 365 development in general should be posted to [Stack Overflow](http://stackoverflow.com/questions/tagged/Office365+API). Make sure that your questions or comments are tagged with [Office365] and [MicrosoftGraph].

## Additional resources

* [Office Dev Center](http://dev.office.com/)
* [Microsoft Graph overview page](https://graph.microsoft.io)
* [Using CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

## Copyright
Copyright (c) 2016 Microsoft. All rights reserved.
