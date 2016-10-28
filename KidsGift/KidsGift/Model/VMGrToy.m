//
//  VMGrToy.m
//  KidsGift
//
//  Created by SLSS on 10/28/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import "VMGrToy.h"
#import "AppConstant.h"

@implementation VMGrToy

- (id)initWithDictionary:(NSDictionary*)dicToy {
    self = [super init];
    if (self) {
        // toyHave
        if (dicToy[FIR_USER_TOY_HAVE]) {
            self.toyHave = dicToy[FIR_USER_TOY_HAVE];
        }
        // toyWant
        if (dicToy[FIR_USER_TOY_WANT]) {
            self.toyWant = dicToy[FIR_USER_TOY_WANT];
        }
        // toyNum
        if (dicToy[FIR_USER_TOY_NUM]) {
            self.toyNum = dicToy[FIR_USER_TOY_NUM];
        }
        // toyDate
        if (dicToy[FIR_USER_TOY_DATE_REQUEST]) {
            self.toyDateRequest = dicToy[FIR_USER_TOY_DATE_REQUEST];
        }
    }
    return self;
}

//- (void)loadUsersMatches:(FIRDatabaseReference*) mRef{
//    
//    [mRef child:FIR_DATABASE_USERS] qu
//    
//    [[[mRef child:FIR_DATABASE_USERS] child:mFIRUser.uid]  observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
//        
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//        if (snapshot && snapshot.value && [snapshot.value isKindOfClass:[NSDictionary class]]) {
//            NSDictionary *dicUser = [[NSDictionary alloc] initWithDictionary:snapshot.value];
//            mCurrentUser = [[VMGrUser alloc] initWithDictionary:dicUser];
//            if (mCurrentUser.arrToySetup && mCurrentUser.arrToySetup.count > 0) {
//                mArrToySetup = mCurrentUser.arrToySetup;
//                [self.tableMatches reloadData];
//            }
//            
//            
//            //            mCurrentLocation = [mCurrentUser getLocation];
//            //            if (mCurrentUser.toyHave && mCurrentUser.toyWant) {
//            //                if (wself) {
//            //                    [wself loadAllUsers];
//            //                }
//            //            }
//        }
//    }];
//
//
//}

@end
