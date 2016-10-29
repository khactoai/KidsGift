//
//  VMGrToy.h
//  KidsGift
//
//  Created by SLSS on 10/28/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FirebaseDatabase/FirebaseDatabase.h>
#import "VMGrUser.h"

@class VMGrToy;
@protocol VMGrToyLoadUsersMatchesDelegate <NSObject>
@optional
- (void)loadUsersMatchesFinish:(VMGrToy*)toy;
@end

@interface VMGrToy : NSObject

@property(retain, nonatomic) NSString *toyNum;
@property(retain, nonatomic) NSString *toyHave;
@property(retain, nonatomic) NSString *toyWant;
@property(retain, nonatomic) NSString *toyDateRequest;
@property(retain, nonatomic) NSString *groupID;
@property(retain, nonatomic) NSMutableArray *arrUserMatches;
@property (nonatomic, weak) id <VMGrToyLoadUsersMatchesDelegate> delegate;

- (id)initWithDictionary:(NSDictionary*)dicToy;
- (void)loadUsersMatches:(FIRDatabaseReference*) mRef currentUser:(VMGrUser*) currentUser;

@end
