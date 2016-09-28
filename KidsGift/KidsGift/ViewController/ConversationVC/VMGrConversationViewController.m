//
//  VMGrConversationViewController.m
//  KidsGift
//
//  Created by Dragon on 9/26/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import "VMGrConversationViewController.h"
#import <FirebaseDatabase/FirebaseDatabase.h>
#import "AppConstant.h"
#import "VMGrUtilities.h"
#import "VMGrMessage.h"

@interface VMGrConversationViewController () {
    
    JSQMessagesBubbleImage *bubbleImageSender;
    JSQMessagesBubbleImage *bubbleImageReceiver;
    
    JSQMessagesAvatarImage *avatarImageSender;
    JSQMessagesAvatarImage *avatarImageReciver;
    JSQMessagesAvatarImage *avatarImageBlank;
    
    FIRDatabaseReference *mRef;
    NSString *mMessageId;
    
    VMGrUser *mCurrentUser;
    VMGrUser *mReceiverUser;
    
    NSMutableArray *mArrMessages;
}

@end

@implementation VMGrConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = mReceiverUser.name;
    
    self.senderId = mCurrentUser.uid;
    self.senderDisplayName = mCurrentUser.name;
    
    mRef = [[FIRDatabase database] reference];
    mMessageId = [self createMessageId];
    mArrMessages = [[NSMutableArray alloc] init];
    [self loadMessages];
    [self clearRecent];
    
    [self setupViewMessage];
    
}

- (void)setupViewMessage {

    [self.inputToolbar.contentView.textView setPlaceHolder:@"Type a message ..."];
    
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    self.showLoadEarlierMessagesHeader = NO;
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    bubbleImageSender = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    bubbleImageReceiver = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    avatarImageBlank = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"no_avatar"] diameter:20.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.collectionView.collectionViewLayout.springinessEnabled = NO;
    
    // Clear recent
    [self clearRecent];
}

// Set user
- (void)setCurrentUser:(VMGrUser*)currentUser receiverUser:(VMGrUser*)receiverUser {
    mCurrentUser = currentUser;
    mReceiverUser = receiverUser;
}

// Create message id
- (NSString*)createMessageId {
    NSString *uidCurrent = mCurrentUser.uid;
    NSString *uidReceiver = mReceiverUser.uid;
    return ([uidCurrent compare:uidReceiver] < 0) ? [NSString stringWithFormat:@"%@%@", uidCurrent, uidReceiver] : [NSString stringWithFormat:@"%@%@", uidReceiver, uidCurrent];
}

#pragma mark message
- (void)loadMessages {
    
    [[[mRef child:FIR_DATABASE_MESSAGES] child:mMessageId]  observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot && snapshot.value && [snapshot.value isKindOfClass:[NSDictionary class]]) {
            
            VMGrMessage *messageObj = [[VMGrMessage alloc] initWithDictionary:snapshot.value];
            [mArrMessages addObject:[messageObj createMessage]];
            [self finishReceivingMessage];
            
        }
    }];
}

- (void)sendMessage:(NSString *)text {
    
    NSDictionary *dictMessage = @{FIR_MESSAGES_ID: mMessageId,
                             FIR_MESSAGES_UID_SENDER: mCurrentUser.uid,
                             FIR_MESSAGES_UID_RECEIVER: mReceiverUser.uid,
                             FIR_MESSAGES_TEXT: text,
                             FIR_MESSAGES_DISPLAY_NAME: mCurrentUser.name,
                             FIR_MESSAGES_DATE: [VMGrUtilities dateToString:[NSDate date]]};
    
    
    [[[[mRef child:FIR_DATABASE_MESSAGES] child:mMessageId] childByAutoId] setValue:dictMessage withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
    }];
}

#pragma mark recent

- (void)clearRecent {
    
    NSDictionary *dictRecent = @{FIR_RECENT_UID_SENDER: mCurrentUser.uid,
                                 FIR_RECENT_UID_RECEIVER: mReceiverUser.uid,
                                 FIR_RECENT_COUNT: @0,
                                 FIR_RECENT_DATE: [VMGrUtilities dateToString:[NSDate date]]};
    [[[[mRef child:FIR_DATABASE_RECENTS] child:mCurrentUser.uid] child:mReceiverUser.uid] updateChildValues:dictRecent withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
    }];
}

- (void)updateRecentForSender:(NSString*)text {
    NSDictionary *dictRecent = @{FIR_RECENT_UID_SENDER: mCurrentUser.uid,
                                 FIR_RECENT_UID_RECEIVER: mReceiverUser.uid,
                                 FIR_RECENT_TEXT: text,
                                 FIR_RECENT_DISPLAY_NAME: mReceiverUser.name,
                                 FIR_RECENT_COUNT: @0,
                                 FIR_RECENT_DATE: [VMGrUtilities dateToString:[NSDate date]]};
    
    [[[[mRef child:FIR_DATABASE_RECENTS] child:mCurrentUser.uid] child:mReceiverUser.uid] updateChildValues:dictRecent withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
    }];
}

- (void)updateRecentForReceiver:(NSString*)text {
    
    [[[[mRef child:FIR_DATABASE_RECENTS] child:mReceiverUser.uid] child:mCurrentUser.uid] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSInteger count = 0;
        if (snapshot && snapshot.value && [snapshot.value isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dictValue = [[NSDictionary alloc] initWithDictionary:snapshot.value];
            count = dictValue[FIR_RECENT_COUNT] ? [dictValue[FIR_RECENT_COUNT] integerValue] : 0;
        }
        NSDictionary *dictRecent = @{FIR_RECENT_UID_SENDER: mReceiverUser.uid,
                                     FIR_RECENT_UID_RECEIVER: mCurrentUser.uid,
                                     FIR_RECENT_TEXT: text,
                                     FIR_RECENT_DISPLAY_NAME: mCurrentUser.name,
                                     FIR_RECENT_COUNT: [NSNumber numberWithInteger:count + 1],
                                     FIR_RECENT_DATE: [VMGrUtilities dateToString:[NSDate date]]};
        
        [[[[mRef child:FIR_DATABASE_RECENTS] child:mReceiverUser.uid] child:mCurrentUser.uid] updateChildValues:dictRecent withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            
        }];
        
    }];
}

// Load avatar
- (void)loadImageAvatarWithUid:(NSString *)uid {
    
    FIRStorage *storage = [FIRStorage storage];
    FIRStorageReference *storageRef = [storage referenceForURL:FIR_STORAGE_SG];
    FIRStorageReference *avatarRef = [storageRef child:FIR_STORAGE_AVATAR];
    FIRStorageReference *uidRef = [avatarRef child:uid];
    
    [uidRef dataWithMaxSize:1 * 1024 * 1024 completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        
        if (error != nil) {
            
        } else {
            UIImage *imgAvatar = [UIImage imageWithData:data];
            if ([uid isEqual:mCurrentUser.uid]) {
                avatarImageSender = [JSQMessagesAvatarImageFactory avatarImageWithImage:imgAvatar diameter:20.0];
            } else {
                avatarImageReciver = [JSQMessagesAvatarImageFactory avatarImageWithImage:imgAvatar diameter:20.0];
            }
            
            [self.collectionView reloadData];
        }
    }];
}


#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)name date:(NSDate *)date {
    
    // Add message
    [self sendMessage:text];
    // Update recent for Receiver
    [self updateRecentForSender:text];
    [self updateRecentForReceiver:text];
    
    [self finishSendingMessage];
    [self scrollToBottomAnimated:NO];
    self.automaticallyScrollsToMostRecentMessage = YES;
    self.showLoadEarlierMessagesHeader = NO;
    
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return mArrMessages[indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessage *jsqMessage = [mArrMessages objectAtIndex:indexPath.row];
    if ([jsqMessage.senderId isEqual:mCurrentUser.uid]) {
        return bubbleImageSender;
    }
    return bubbleImageReceiver;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessage *message = [mArrMessages objectAtIndex:indexPath.row];
    if ([message.senderId isEqualToString:mCurrentUser.uid]) {
        if (!avatarImageSender) {
            [self loadImageAvatarWithUid:mCurrentUser.uid];
        } else {
            return avatarImageSender;
        }
    } else {
        if (!avatarImageReciver) {
            [self loadImageAvatarWithUid:mReceiverUser.uid];
        } else {
            return avatarImageReciver;
        }
    }
    return avatarImageBlank;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessage *message = mArrMessages[indexPath.row];
    if (indexPath.row > 0)
    {
        JSQMessage *previous = mArrMessages[indexPath.row - 1];
        if ([message.senderId isEqual:previous.senderId]) {
            return nil;
        }
    }
    return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
}

// Display Name
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}


- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [mArrMessages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage *jsqMessage = [mArrMessages objectAtIndex:indexPath.row];
    if ([jsqMessage.senderId isEqual:mCurrentUser.uid]) {
        cell.textView.textColor = [UIColor whiteColor];
    } else {
        cell.textView.textColor = [UIColor blackColor];
    }
    cell.textView.linkTextAttributes = @{NSForegroundColorAttributeName:[UIColor blueColor]};
    
    return cell;
}


#pragma mark - JSQMessages collection view flow layout delegate

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessage *message = mArrMessages[indexPath.row];
    if (indexPath.row > 0)
    {
        JSQMessage *previous = mArrMessages[indexPath.row - 1];
        if ([message.senderId isEqual:previous.senderId]) {
            return 10;
        }
    }
    return 30;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    return 0;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    return 0;
}

@end
