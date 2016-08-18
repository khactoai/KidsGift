//
//  AppDelegate.h
//  KidsGift
//
//  Created by Dragon on 8/18/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>

@import Firebase;
#import <GoogleSignIn/GoogleSignIn.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, GIDSignInDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

