//
//  VMGrMatchesViewController.m
//  KidsGift
//
//  Created by Dragon on 8/18/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import "VMGrMatchesViewController.h"
#import "RESideMenu.h"
#import "MBProgressHUD.h"
#import "AppConstant.h"
#import <FirebaseDatabase/FirebaseDatabase.h>

@import Firebase;

@interface VMGrMatchesViewController () {

    FIRDatabaseReference *mRef;
    FIRUser *mFIRUser;
    NSDictionary *mDictUser;
    NSMutableArray *mAllUsers;
    NSMutableArray *mGroupUsers;
    
    NSString *mToyHave, *mToyWant;
}

@end

@implementation VMGrMatchesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setLogoNavigation];
    
    mAllUsers = [[NSMutableArray alloc] init];
    mGroupUsers = [[NSMutableArray alloc] init];
    
    mFIRUser = [[FIRAuth auth] currentUser];
    mRef = [[FIRDatabase database] reference];
    [self loadUser];
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

- (void)loadUser {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[[mRef child:FIR_DATABASE_USERS] child:mFIRUser.uid]  observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (snapshot && snapshot.value && [snapshot.value isKindOfClass:[NSDictionary class]]) {
            mDictUser = [[NSDictionary alloc] initWithDictionary:snapshot.value];
            if ([mDictUser objectForKey:FIR_USER_TOY_WANT]) {
                mToyHave = [mDictUser objectForKey:FIR_USER_TOY_HAVE];
                mToyWant = [mDictUser objectForKey:FIR_USER_TOY_WANT];
                [self loadUserMatches];
            }
            
        }
    }];
}

//- (void)loadUserMatches:(NSString*)toyHave {
//    
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    
//    FIRDatabaseQuery *allUser = [[mRef child:FIR_DATABASE_USERS] queryOrderedByChild:FIR_USER_TOY_HAVE];
//    FIRDatabaseQuery *userMatches = [allUser queryEqualToValue:toyHave];
//    
//    [userMatches observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//        if (snapshot && snapshot.value && [snapshot.value isKindOfClass:[NSDictionary class]]) {
//            NSDictionary *dicUsers = [[NSDictionary alloc] initWithDictionary:snapshot.value];
//            NSArray *arrKeys = [dicUsers allKeys];
//            for (NSString *key in arrKeys) {
//                NSString *value = [dicUsers objectForKey:key];
//                [mDataUsers addObject:value];
//            }
//        }
//    }];
//    
//}

- (void)loadUserMatches {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    FIRDatabaseQuery *allUser = [mRef child:FIR_DATABASE_USERS];
    
    [allUser observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (snapshot && snapshot.value && [snapshot.value isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dicUsers = [[NSDictionary alloc] initWithDictionary:snapshot.value];
            NSArray *arrKeys = [dicUsers allKeys];
            for (NSString *key in arrKeys) {
                NSDictionary *value = [dicUsers objectForKey:key];
                [mAllUsers addObject:value];
            }
            
            while (mAllUsers.count > 0) {
                [self groupUsers];
            }
        }
    }];
}


- (void)groupUsers {

    NSMutableArray *arrUser = [[NSMutableArray alloc] init];
    NSDictionary *user = [mAllUsers objectAtIndex:0];
    NSString *toyHave = user[FIR_USER_TOY_HAVE];
    NSString *toyWant = user[FIR_USER_TOY_WANT];
    if (!toyHave || !toyHave) {
        [mAllUsers removeObject:user];
        return;
    }
    [arrUser addObject:user];
    
    for (int index = 1; index < mAllUsers.count; index++) {
        NSDictionary *value = [mAllUsers objectAtIndex:index];
        if (value[FIR_USER_TOY_HAVE] && value[FIR_USER_TOY_WANT]) {
            if ([value[FIR_USER_TOY_HAVE] isEqualToString:toyHave] && [value[FIR_USER_TOY_WANT] isEqualToString:toyWant]) {
                [arrUser addObject:value];
                
            }
        }
    }
    [mAllUsers removeObjectsInArray:[NSArray arrayWithArray:arrUser]];
    
    [mGroupUsers addObject:arrUser];
}


@end
