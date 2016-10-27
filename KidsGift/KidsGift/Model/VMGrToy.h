//
//  VMGrToy.h
//  KidsGift
//
//  Created by SLSS on 10/28/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VMGrToy : NSObject

@property(retain, nonatomic) NSString *toyNum;
@property(retain, nonatomic) NSString *toyHave;
@property(retain, nonatomic) NSString *toyWant;
@property(retain, nonatomic) NSString *toyDateRequest;

- (id)initWithDictionary:(NSDictionary*)dicToy;

@end
