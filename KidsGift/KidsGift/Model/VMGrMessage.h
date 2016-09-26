//
//  VMGrMessage.h
//  KidsGift
//
//  Created by Dragon on 9/26/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VMGrMessage : NSObject

@property(retain, nonatomic) NSString *messageId;
@property(retain, nonatomic) NSString *uidSender;
@property(retain, nonatomic) NSString *uidReceiver;
@property(retain, nonatomic) NSString *text;
@property(retain, nonatomic) NSString *displayName;
@property(retain, nonatomic) NSString *date;

- (id)initWithDictionary:(NSDictionary*)dicMessage;


@end
