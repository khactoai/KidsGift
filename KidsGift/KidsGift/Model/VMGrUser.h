//
//  VMGrUser.h
//  KidsGift
//
//  Created by SLSS on 9/17/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface VMGrUser : NSObject

@property(retain, nonatomic) NSString *uid;
@property(retain, nonatomic) NSString *name;
@property(retain, nonatomic) NSString *location;
@property(assign, nonatomic) float latitude;
@property(assign, nonatomic) float longitude;
@property(assign, nonatomic) NSInteger distance;
@property(assign, nonatomic) Boolean notifyMatch;
@property(assign, nonatomic) Boolean notifyChat;

@property(retain, nonatomic) NSString *toyHave;
@property(retain, nonatomic) NSString *toyWant;
@property(retain, nonatomic) NSString *toyNum;
@property(retain, nonatomic) NSString *toyDateRequest;
@property(assign, nonatomic) CLLocationDistance locationDistance;

@property(retain, nonatomic) UIImage *imgAvatar;
@property(retain, nonatomic) NSMutableArray *arrGroupDelete;
@property(retain, nonatomic) NSMutableArray *arrToySetup;

- (id)initWithDictionary:(NSDictionary*)dicUser;

- (CLLocation* )getLocation;
- (void)setDistanceWithLocation:(CLLocation *)otherLocation;

@end
