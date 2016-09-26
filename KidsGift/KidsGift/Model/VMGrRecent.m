//
//  VMGrRecent.m
//  KidsGift
//
//  Created by SLSS on 9/27/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import "VMGrRecent.h"
#import "AppConstant.h"
#import "VMGrUtilities.h"

@implementation VMGrRecent

- (id)initWithDictionary:(NSDictionary*)dicRecent {
    self = [super init];
    if (self) {
        // UID SENDER
        if (dicRecent[FIR_RECENT_UID_SENDER]) {
            self.uidSender = dicRecent[FIR_RECENT_UID_SENDER];
        }
        
        // UID RECEIVER
        if (dicRecent[FIR_RECENT_UID_RECEIVER]) {
            self.uidReceiver = dicRecent[FIR_RECENT_UID_RECEIVER];
        }
        
        // TEXT
        if (dicRecent[FIR_RECENT_TEXT]) {
            self.text = dicRecent[FIR_RECENT_TEXT];
        }
        
        // DATE
        if (dicRecent[FIR_RECENT_DATE]) {
            self.date = dicRecent[FIR_RECENT_DATE];
        }
        
        // COUNT
        if (dicRecent[FIR_RECENT_COUNT]) {
            self.count = [dicRecent[FIR_RECENT_COUNT] integerValue];
        }
        
        // DISPLAY NAME
        if (dicRecent[FIR_RECENT_DISPLAY_NAME]) {
            self.displayName = dicRecent[FIR_RECENT_DISPLAY_NAME];
        }
        
    }
    return self;
}

@end
