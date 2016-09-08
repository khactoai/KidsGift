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
#import "AppConstant.h"
#import <FirebaseDatabase/FirebaseDatabase.h>

@interface AppDelegate () <UISplitViewControllerDelegate> {
    
    FIRDatabaseReference *mRef;
    FIRUser *mUser;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    // Use Firebase library to configure APIs
    [FIRApp configure];
    
    mRef = [[FIRDatabase database] reference];
    
    [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
    [GIDSignIn sharedInstance].delegate = self;
    
    
    mUser = [[FIRAuth auth] currentUser];
    if (mUser) {
        NSDictionary *dicUser = @{FIR_USER_UID: mUser.uid,
                                  FIR_USER_NAME: mUser.displayName};
        
        [[[mRef child:FIR_DATABASE_USERS] child:mUser.uid] updateChildValues:dicUser];
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
    [self locationManagerStart];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark Delegate Google

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    
    UIViewController *currentVC = [self getCurrentViewController];
    if ([currentVC isKindOfClass:[VMGrLoginViewController class]]) {
        VMGrLoginViewController *loginVC = (VMGrLoginViewController*)currentVC;
        [loginVC signIn:signIn didSignInForUser:user withError:error];
    }
}

- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
    
    UIViewController *currentVC = [self getCurrentViewController];
    if ([currentVC isKindOfClass:[VMGrLoginViewController class]]) {
        VMGrLoginViewController *loginVC = (VMGrLoginViewController*)currentVC;
        [loginVC signIn:signIn didDisconnectWithUser:user withError:error];
    }
}

- (id)getCurrentViewController {
    
    id windowRootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    id currentViewController = [self findTopViewController:windowRootVC];
    return currentViewController;
}

- (id)findTopViewController:(id)inController {
    /* if ur using any Customs classes, do like this.
     * Here SlideNavigationController is a subclass of UINavigationController.
     * And ensure you check the custom classes before native controllers , if u have any in your hierarchy.
     if ([inController isKindOfClass:[SlideNavigationController class]])
     {
     return [self findTopViewController:[inController visibleViewController]];
     }
     else */
    if ([inController isKindOfClass:[UITabBarController class]])
    {
        return [self findTopViewController:[inController selectedViewController]];
    }
    else if ([inController isKindOfClass:[UINavigationController class]])
    {
        return [self findTopViewController:[inController visibleViewController]];
    }
    else if ([inController isKindOfClass:[UIViewController class]])
    {
        return inController;
    }
    else
    {
        NSLog(@"Unhandled ViewController class : %@",inController);
        return nil;
    }
}


#pragma mark - Location manager methods

- (void)locationManagerStart {
    if (self.locationManager == nil)
    {
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager setDelegate:self];
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        
    }
    [self.locationManager startUpdatingLocation];
}

- (void)locationManagerStop {
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    if (mUser && newLocation) {
        [self updateUserLocation:newLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *newLocation = [locations lastObject];
    
    if (mUser && newLocation) {
        [self updateUserLocation:newLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
}

- (void)updateUserLocation:(CLLocation *)location{
    
    NSDictionary *dicUser = @{FIR_USER_UID: mUser.uid,
                              FIR_USER_NAME: mUser.displayName,
                              FIR_USER_LATITUDE: [NSNumber numberWithFloat:location.coordinate.latitude],
                              FIR_USER_LONGITUDE: [NSNumber numberWithFloat:location.coordinate.longitude]};
    
    [[[mRef child:FIR_DATABASE_USERS] child:mUser.uid] updateChildValues:dicUser withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOCATION_UPDATE object:self];
    }];
    
}

@end


