//
//  VMGrUser.m
//  KidsGift
//
//  Created by SLSS on 9/17/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import "VMGrUser.h"
#import "AppConstant.h"

@implementation VMGrUser

- (id)initWithDictionary:(NSDictionary*)dicUser {
    self = [super init];
    if (self) {
        // UID
        if (dicUser[FIR_USER_UID]) {
            self.uid = dicUser[FIR_USER_UID];
        }
        // Name
        if (dicUser[FIR_USER_NAME]) {
            self.name = dicUser[FIR_USER_NAME];
        }
        // Location
        if (dicUser[FIR_USER_LOCATION]) {
            self.location = dicUser[FIR_USER_LOCATION];
        }
        // latitude
        if (dicUser[FIR_USER_LATITUDE]) {
            self.latitude = [dicUser[FIR_USER_LATITUDE] floatValue];
        }
        // longitude
        if (dicUser[FIR_USER_LONGITUDE]) {
            self.longitude = [dicUser[FIR_USER_LONGITUDE] floatValue];
        }
        // distance
        if (dicUser[FIR_USER_DISTANCE]) {
            self.distance = [dicUser[FIR_USER_DISTANCE] integerValue];
        }
        // notifyMatch
        if (dicUser[FIR_USER_NOTIFY_MATCH]) {
            self.notifyMatch = [dicUser[FIR_USER_NOTIFY_MATCH] boolValue];
        }
        // notifyChat
        if (dicUser[FIR_USER_NOTIFY_CHAT]) {
            self.notifyChat = [dicUser[FIR_USER_NOTIFY_CHAT] boolValue];
        }
        // toyHave
        if (dicUser[FIR_USER_TOY_HAVE]) {
            self.toyHave = dicUser[FIR_USER_TOY_HAVE];
        }
        // toyWant
        if (dicUser[FIR_USER_TOY_WANT]) {
            self.toyWant = dicUser[FIR_USER_TOY_WANT];
        }
        // toyNum
        if (dicUser[FIR_USER_TOY_NUM]) {
            self.toyNum = dicUser[FIR_USER_TOY_NUM];
        }
        // toyNum
        if (dicUser[FIR_USER_TOY_DATE_REQUEST]) {
            self.toyDateRequest = dicUser[FIR_USER_TOY_DATE_REQUEST];
        }
    }
    return self;
}

- (CLLocation* )getLocation {
    return [[CLLocation alloc] initWithLatitude:self.latitude longitude:self.longitude];
}

- (void)setDistanceWithLocation:(CLLocation *)otherLocation {
    CLLocation *currentLocation = [self getLocation];
    CLLocationDistance kilometers = [otherLocation distanceFromLocation:currentLocation] / 1000;
    self.locationDistance = kilometers;
}


@end
