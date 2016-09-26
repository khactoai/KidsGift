//
//  VMGrRecent.h
//  KidsGift
//
//  Created by SLSS on 9/27/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VMGrRecent : NSObject

@property(retain, nonatomic) NSString *uidSender;
@property(retain, nonatomic) NSString *uidReceiver;
@property(retain, nonatomic) NSString *text;
@property(retain, nonatomic) NSString *date;
@property(retain, nonatomic) NSString *displayName;
@property(assign) NSInteger count;

@property(retain, nonatomic) UIImage *imgAvatar;

- (id)initWithDictionary:(NSDictionary*)dicRecent;

@end
