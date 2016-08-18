//
//  VMGrLoginViewController.m
//  KidsGift
//
//  Created by Dragon on 8/18/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import "VMGrLoginViewController.h"
#import "FBSDKAccessToken.h"

@interface VMGrLoginViewController ()

@end

@implementation VMGrLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //[FIRApp configure];
    
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
    [[GIDSignIn sharedInstance] signIn];
}

- (IBAction)authFacebookAction:(id)sender {
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        
        if (error == nil) {
            
            FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                             credentialWithAccessToken:[FBSDKAccessToken currentAccessToken]
                                             .tokenString];
            
            [[FIRAuth auth] signInWithCredential:credential
                                      completion:^(FIRUser *user, NSError *error) {
                                          // ...
                                          
                                          if (error == nil) {
                                              NSLog(@"Login success : %@", user.displayName);
                                          } else {
                                              NSLog(@"Login False");
                                          }
                                      }];
            
        } else {
            NSLog(@"Login error");
        }
        
    }];
}


@end
