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

@interface VMGrLoginViewController () {

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)authGoogleAction:(id)sender {
    if (![VMGrUtilities connectedToNetwork]) {
        [VMGrAlertView showAlertNoConnection];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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
                                          }
                                      }];
            
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [VMGrAlertView showAlertMessage:error.localizedDescription];
        }
        
    }];
}


#pragma mark Delegate SignIn Google
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    
    if (!error) {
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
                                      }
                                      
                                  }];
    } else {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [VMGrAlertView showAlertMessage:error.localizedDescription];
    }

}

- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark login success
- (void)loginSuccess:(FIRUser* )user {
    mFIRUser = user;
    if (mImageRequest && mFIRUser) {
        [self downloadImageProfile];
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    RESideMenu *sideMenuVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VMGrRootViewController"];
    sideMenuVC.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:sideMenuVC animated:YES completion:nil];
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


@end
