//
//  VMGrMessage.m
//  KidsGift
//
//  Created by Dragon on 9/26/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import "VMGrMessage.h"
#import "AppConstant.h"

@implementation VMGrMessage

- (id)initWithDictionary:(NSDictionary*)dicMessage {
    self = [super init];
    if (self) {
        // ID
        if (dicMessage[FIR_MESSAGES_ID]) {
            self.messageId = dicMessage[FIR_MESSAGES_ID];
        }
        
        // UID_CURRENT
        if (dicMessage[FIR_MESSAGES_UID_CURRENT]) {
            self.uidCurrent = dicMessage[FIR_MESSAGES_UID_CURRENT];
        }
        
        // Receiver
        if (dicMessage[FIR_MESSAGES_UID_RECEIVER]) {
            self.uidReceiver = dicMessage[FIR_MESSAGES_UID_RECEIVER];
        }
        
        // Text
        if (dicMessage[FIR_MESSAGES_TEXT]) {
            self.text = dicMessage[FIR_MESSAGES_TEXT];
        }
        
        // Date
        if (dicMessage[FIR_MESSAGES_DATE]) {
            self.date = dicMessage[FIR_MESSAGES_DATE];
        }
        
    }
    return self;
}

@end
