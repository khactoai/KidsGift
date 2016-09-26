//
//  VMGrMessage.m
//  KidsGift
//
//  Created by Dragon on 9/26/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import "VMGrMessage.h"
#import "AppConstant.h"
#import "VMGrUtilities.h"

@implementation VMGrMessage

- (id)initWithDictionary:(NSDictionary*)dicMessage {
    self = [super init];
    if (self) {
        // ID
        if (dicMessage[FIR_MESSAGES_ID]) {
            self.messageId = dicMessage[FIR_MESSAGES_ID];
        }
        
        // UID_CURRENT
        if (dicMessage[FIR_MESSAGES_UID_SENDER]) {
            self.uidSender = dicMessage[FIR_MESSAGES_UID_SENDER];
        }
        
        // Receiver
        if (dicMessage[FIR_MESSAGES_UID_RECEIVER]) {
            self.uidReceiver = dicMessage[FIR_MESSAGES_UID_RECEIVER];
        }
        
        // Text
        if (dicMessage[FIR_MESSAGES_TEXT]) {
            self.text = dicMessage[FIR_MESSAGES_TEXT];
        }
        
        // Name
        if (dicMessage[FIR_MESSAGES_DISPLAY_NAME]) {
            self.displayName = dicMessage[FIR_MESSAGES_DISPLAY_NAME];
        }
        
        // Date
        if (dicMessage[FIR_MESSAGES_DATE]) {
            self.date = dicMessage[FIR_MESSAGES_DATE];
        }
        
    }
    return self;
}

- (JSQMessage*)createMessage {
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:self.uidSender
                                             senderDisplayName:self.displayName
                                                          date:[VMGrUtilities stringToDate:self.date]
                                                          text:self.text];
    return message;
}

@end
