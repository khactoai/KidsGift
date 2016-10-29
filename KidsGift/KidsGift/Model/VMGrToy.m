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
        // group id
        if (dicToy[FIR_USER_TOY_GROUP_ID]) {
            self.groupID = dicToy[FIR_USER_TOY_GROUP_ID];
        }
        // array user matches
        self.arrUserMatches = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)loadUsersMatches:(FIRDatabaseReference*) mRef currentUser:(VMGrUser*) currentUser{
    FIRDatabaseQuery *userQuery = [mRef child:FIR_DATABASE_USERS];
    NSString *groupMatches = [NSString stringWithFormat:@"%@-%@", self.toyWant, self.toyHave];
    NSString *childId = [NSString stringWithFormat:@"toy_setup/%@/%@", groupMatches, FIR_USER_TOY_GROUP_ID];
    
    [[[userQuery queryOrderedByChild:childId] queryEqualToValue:groupMatches] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        [self.arrUserMatches removeAllObjects];
        if (snapshot && snapshot.value && [snapshot.value isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dicUsers = [[NSDictionary alloc] initWithDictionary:snapshot.value];
            NSArray *arrKeys = [dicUsers allKeys];
            for (NSString *key in arrKeys) {
                NSDictionary *value = [dicUsers objectForKey:key];
                VMGrUser *user = [[VMGrUser alloc] initWithDictionary:value];
                [user setDistanceWithLocation:[currentUser getLocation]];
                if (![user.uid isEqual:currentUser.uid]) {
                    [self.arrUserMatches addObject:user];
                }
            }
            [self sortUsesWithDistance:self.arrUserMatches];
            if (self.delegate && [self.delegate respondsToSelector:@selector(loadUsersMatchesFinish:)]) {
                [self.delegate loadUsersMatchesFinish:self];
            }
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        
    }];

}

- (void)sortUsesWithDistance:(NSMutableArray *)arrSort{
    [arrSort sortUsingComparator:^NSComparisonResult(VMGrUser  *user1, VMGrUser  *user2) {
        if (user1.locationDistance > user2.locationDistance)
        {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if (user1.locationDistance < user2.locationDistance)
        {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
}

@end
