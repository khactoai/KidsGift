//
//  VMGrLoginViewController.m
//  KidsGift
//
//  Created by Dragon on 8/18/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import "VMGrLoginViewController.h"
#import "FBSDKAccessToken.h"
#import <AFNetworking/AFNetworking.h>
#import "AppConstant.h"
#import "FBSDKGraphRequest.h"
#import "VMGrUtilities.h"
#import "VMGrAlertView.h"
#import "MBProgressHUD.h"
#import "RESideMenu.h"
#import "AppConstant.h"
#import "VMGrRootTabBarController.h"
#import "VMGrUser.h"

@interface VMGrLoginViewController () {

    FIRDatabaseReference *mRef;
    FIRUser *mFIRUser;
    NSURLRequest *mImageRequest;
    
}

@end

@implementation VMGrLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_main_m"]]];
    
    [GIDSignIn sharedInstance].uiDelegate = self;
    
    mRef = [[FIRDatabase database] reference];
    mFIRUser = [[FIRAuth auth] currentUser];
    
    bool check = [[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstTimeLaunchedApp"];
    if (check) {
        // open main VC
        [self openMainVC];
    } else {
        [self logoutUser];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"VMGrRootTabBarSegue"]) {
        
    }
}

- (IBAction)authGoogleAction:(id)sender {
    if (![VMGrUtilities connectedToNetwork]) {
        [VMGrAlertView showAlertNoConnection];
        return;
    }
    [[GIDSignIn sharedInstance] signIn];
}

- (IBAction)authFacebookAction:(id)sender {
    if (![VMGrUtilities connectedToNetwork]) {
        [VMGrAlertView showAlertNoConnection];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    NSArray *arrPermissions = @[@"public_profile", @"email", @"user_friends"];
    [login logInWithReadPermissions:arrPermissions fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (result.isCancelled) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            return;
        }
        
        if (!error && [FBSDKAccessToken currentAccessToken]) {
            // Request Image Profile
            NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [[FBSDKAccessToken currentAccessToken] userID]];
            NSURL *imageURL = [NSURL URLWithString:userImageURL];
            mImageRequest = [NSURLRequest requestWithURL:imageURL];
            
            FIRAuthCredential *credential = [FIRFacebookAuthProvider credentialWithAccessToken:[FBSDKAccessToken currentAccessToken].tokenString];
            
            [[FIRAuth auth] signInWithCredential:credential
                                      completion:^(FIRUser *user, NSError *error) {
                                          if (error == nil) {
                                              [self loginSuccess:user];
                                          } else {
                                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                                              [VMGrAlertView showAlertMessage:@"Login error"];
                                              [self logoutUser];
                                          }
                                      }];
            
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            //[VMGrAlertView showAlertMessage:error.localizedDescription];
        }
        
    }];
}


#pragma mark Delegate SignIn Google
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    
    if (!error) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        // Request Image Profile
        if (user.profile.hasImage) {
            NSUInteger dimension = round(300 * [[UIScreen mainScreen] scale]);
            NSURL *imageURL = [user.profile imageURLWithDimension:dimension];
            mImageRequest = [NSURLRequest requestWithURL:imageURL];
        }
        
        GIDAuthentication *authentication = user.authentication;
        FIRAuthCredential *credential = [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
                                                                         accessToken:authentication.accessToken];
        
        [[FIRAuth auth] signInWithCredential:credential
                                  completion:^(FIRUser *user, NSError *error) {
                                      if (!error) {
                                          [self loginSuccess:user];
                                      } else {
                                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                                          [VMGrAlertView showAlertMessage:@"Login error"];
                                          [self logoutUser];
                                      }
                                      
                                  }];
    } else {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        //[VMGrAlertView showAlertMessage:error.localizedDescription];
    }

}

- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark login success
- (void)loginSuccess:(FIRUser* )user {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    mFIRUser = user;
    if (mFIRUser) {
        NSDictionary *dicUser = @{FIR_USER_UID: mFIRUser.uid,
                                  FIR_USER_NAME: mFIRUser.displayName};
        [[[mRef child:FIR_DATABASE_USERS] child:mFIRUser.uid] updateChildValues:dicUser];
    }
    
    if (mImageRequest && mFIRUser) {
        [self downloadImageProfile];
    }
    // open main VC
    [self openMainVC];
}

#pragma mark download image profile
- (void)downloadImageProfile {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:mImageRequest progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        [self uploadImageToFireBase:filePath];
    }];
    [downloadTask resume];
    
}

- (void)uploadImageToFireBase:(NSURL*)filePath {
    
    FIRStorage *storage = [FIRStorage storage];
    FIRStorageReference *storageRef = [storage referenceForURL:FIR_STORAGE_SG];
    FIRStorageReference *avatarRef = [storageRef child:FIR_STORAGE_AVATAR];
    FIRStorageReference *uidRef = [avatarRef child:mFIRUser.uid];
    
    FIRStorageMetadata *metadata = [[FIRStorageMetadata alloc] init];
    metadata.contentType = @"image/jpeg";
    [uidRef putFile:filePath metadata:metadata completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
        if (!error) {
            
        }
    }];
    
}

- (void)logoutUser {
    
    if (mFIRUser) {
        for (id<FIRUserInfo> userInfo in mFIRUser.providerData) {
            if ([userInfo.providerID isEqualToString:FIRFacebookAuthProviderID]) {
                FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
                [login logOut];
                
            } else if ([userInfo.providerID isEqualToString:FIRGoogleAuthProviderID]) {
                [[GIDSignIn sharedInstance] signOut];
            }
        }
        
        NSError *signOutError;
        BOOL status = [[FIRAuth auth] signOut:&signOutError];
        if (status) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstTimeLaunchedApp"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstTimeLaunchedApp"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

- (void)openMainVC {
    if (![VMGrUtilities connectedToNetwork]) {
        [VMGrAlertView showAlertNoConnection];
        return;
    }
    if (mFIRUser) {
        MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [progressHUD hideAnimated:YES afterDelay:60.0];
        [[[mRef child:FIR_DATABASE_USERS] child:mFIRUser.uid]  observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSInteger selectedIndex = 0;
            if (snapshot && snapshot.value && [snapshot.value isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dictUser = [[NSDictionary alloc] initWithDictionary:snapshot.value];
                VMGrUser *user = [[VMGrUser alloc] initWithDictionary:dictUser];
                if (user && user.arrToySetup && user.arrToySetup.count > 0) {
                    selectedIndex = 1;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                VMGrRootTabBarController *rootViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VMGrRootTabBarController"];
                rootViewController.selectedIndex = selectedIndex;
                rootViewController.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
                [self presentViewController:rootViewController animated:YES completion:nil];
            });
            
        }];
    }
}


@end
