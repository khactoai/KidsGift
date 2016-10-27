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

@end
