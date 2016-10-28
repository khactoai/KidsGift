//
//  VMGrMatches.m
//  KidsGift
//
//  Created by Dragon on 10/28/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import "VMGrMatches.h"

@implementation VMGrMatches

- (id)init {
    self = [super init];
    if (self) {
        self.toy = [[VMGrToy alloc] init];
        self.arrUsers = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
