//
//  VMGrConversationViewController.h
//  KidsGift
//
//  Created by Dragon on 9/26/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSQMessagesViewController.h"
#import <JSQMessagesViewController/JSQMessages.h>
#import <JSQMessagesViewController/JSQMessagesBubbleImageFactory.h>
#import "VMGrUser.h"

@import Firebase;

@interface VMGrConversationViewController : JSQMessagesViewController

@property (strong, nonatomic) VMGrUser *mUserReceiver;

@end
