//
//  AppDelegate.m
//  KidsGift
//
//  Created by Dragon on 8/18/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import "AppDelegate.h"
#import <AFNetworking.h>
#import "VMGrLoginViewController.h"

@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    // Use Firebase library to configure APIs
    [FIRApp configure];
    [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
    [GIDSignIn sharedInstance].delegate = self;
    
    
//    UIStoryboard *storyboard = self.window.rootViewController.storyboard;
//    UIViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"VMGrRootViewController"];
//    self.window.rootViewController = rootViewController;
//    [self.window makeKeyAndVisible];
    
    
    FIRUser *mUser = [[FIRAuth auth] currentUser];
    
    if (mUser) {
        NSLog(@"User is Login with email: %@ , name: %@", mUser.displayName, mUser.email);
    } else {
        NSLog(@"User is Logout");
    }
    
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options {
    
    if([[FBSDKApplicationDelegate sharedInstance] application:application
                                                      openURL:url
                                            sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                   annotation:options[UIApplicationOpenURLOptionsAnnotationKey]]) {
        
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                              openURL:url
                                                    sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                           annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    
    }
    
    if ([[GIDSignIn sharedInstance] handleURL:url
        sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
        annotation:options[UIApplicationOpenURLOptionsAnnotationKey]]) {
        
        return [[GIDSignIn sharedInstance] handleURL:url
                                   sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                          annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
        
    }

    return YES;
}

/*
 * run on iOS 8 and older
 */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if([[FBSDKApplicationDelegate sharedInstance] application:application
                                                      openURL:url
                                            sourceApplication:sourceApplication
                                                   annotation:annotation]) {
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                              openURL:url
                                                    sourceApplication:sourceApplication
                                                           annotation:annotation];
    } else if ([[GIDSignIn sharedInstance] handleURL:url
                                   sourceApplication:sourceApplication
                                          annotation:annotation]) {
        return [[GIDSignIn sharedInstance] handleURL:url sourceApplication:sourceApplication annotation:annotation];
    }
    return YES;

}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark Delegate Google

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if (error == nil) {
        
        if ([self.window.rootViewController isKindOfClass:[VMGrLoginViewController class]]) {
            VMGrLoginViewController* loginVC = (VMGrLoginViewController*)self.window.rootViewController;
            
            
        }
        
        NSLog(@"Class : %@", [self.window.rootViewController class]);
        
        
        
        
        if (user.profile.hasImage) {
            
            NSUInteger dimension = round(300 * [[UIScreen mainScreen] scale]);
            NSURL *imageURL = [user.profile imageURLWithDimension:dimension];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:imageURL];
            
            [self downloadImageProfile:urlRequest];
            
            
        
        }
        
        GIDAuthentication *authentication = user.authentication;
        FIRAuthCredential *credential = [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
                                         accessToken:authentication.accessToken];
        
        [[FIRAuth auth] signInWithCredential:credential
                                  completion:^(FIRUser *user, NSError *error) {
                                      // ...
                                      if (error == nil) {
                                          NSLog(@"Login success");
                                      } else {
                                          NSLog(@"Login False");
                                      }
                                      
                                  }];
    } else {
        NSLog(@"%@", error.localizedDescription);
    }
}

- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
    // Perform any operations when the user disconnects from app here.
}

#pragma mark download image profile
- (void)downloadImageProfile:(NSURLRequest*)request {
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath);
        [self uploadFileToFireBase:filePath];
    }];
    [downloadTask resume];
    
}

- (void)uploadFileToFireBase:(NSURL*)filePath {
    
    FIRStorage *storage = [FIRStorage storage];
    
    
    
    // Points to the root reference
    FIRStorageReference *storageRef = [storage referenceForURL:@"gs://kidsgift-34c93.appspot.com"];
    // Points to "images"
    FIRStorageReference *imagesRef = [storageRef child:@"images"];
    
    // Points to "images/space.jpg"
    // Note that you can use variables to create child values
    NSString *fileName = @"space.jpg";
    FIRStorageReference *spaceRef = [imagesRef child:fileName];
    
    // File path is "images/space.jpg"
    NSString *path = spaceRef.fullPath;
    
    // File name is "space.jpg"
    NSString *name = spaceRef.name;
    
    FIRStorageMetadata *metadata = [[FIRStorageMetadata alloc] init];
    metadata.contentType = @"image/jpeg";
    
    FIRStorageUploadTask *uploadTask = [spaceRef putFile:filePath metadata:metadata completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
        
        if (error != nil) {
            // Uh-oh, an error occurred!
        } else {
            // Metadata contains file metadata such as size, content-type, and download URL.
            NSURL *downloadURL = metadata.downloadURL;
        }
        
    }];
    
    
    
}


@end


