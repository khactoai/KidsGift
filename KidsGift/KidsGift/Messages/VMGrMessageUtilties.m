//
//  VMGrMessage.m
//  KidsGift
//
//  Created by Dragon on 9/26/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import "VMGrMessageUtilties.h"

@implementation VMGrMessageUtilties

- (NSString*)getMessageIdWithUid:(NSString*)uidCurrent uidReceiver:(NSString*)uidReceiver {
    NSString *messageId = ([uidCurrent compare:uidReceiver] < 0) ? [NSString stringWithFormat:@"%@%@", uidCurrent, uidReceiver] : [NSString stringWithFormat:@"%@%@", uidReceiver, uidCurrent];
    return messageId;
}


@end
