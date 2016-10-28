//
//  VMGrMatches.h
//  KidsGift
//
//  Created by Dragon on 10/28/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VMGrToy.h"
#import "VMGrUser.h"

@interface VMGrMatches : NSObject

@property(retain, nonatomic) VMGrToy *toy;
@property(retain, nonatomic) NSMutableArray *arrUsers;

@end
