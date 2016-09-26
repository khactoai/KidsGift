//
//  VMGrMessage.h
//  KidsGift
//
//  Created by Dragon on 9/26/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import <Foundation/Foundation.h>

@import Firebase;

@interface VMGrMessageUtilties : NSObject

- (NSString*)getMessageIdWithUid:(NSString*)uidCurrent uidReceiver:(NSString*)uidReceiver;

@end
