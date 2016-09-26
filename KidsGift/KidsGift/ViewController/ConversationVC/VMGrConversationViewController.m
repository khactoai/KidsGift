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
    
    JSQMessagesBubbleImage *bubbleImageOutgoing;
    JSQMessagesBubbleImage *bubbleImageIncoming;
    
    FIRUser *mFIRUserCurrent;
    NSString *mMessageId;
    
    
    FIRDatabaseReference *mRef;
}

@property(retain, nonatomic) NSMutableArray *mArrMessages;

@end

@implementation VMGrConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    mRef = [[FIRDatabase database] reference];
    mFIRUserCurrent = [[FIRAuth auth] currentUser];
    
    self.senderId = mFIRUserCurrent.uid;
    self.senderDisplayName = mFIRUserCurrent.displayName;
    
    
    NSString *uidCurrent = mFIRUserCurrent.uid;
    NSString *uidReceiver = self.mUserReceiver.uid;
    mMessageId = ([uidCurrent compare:uidReceiver] < 0) ? [NSString stringWithFormat:@"%@%@", uidCurrent, uidReceiver] : [NSString stringWithFormat:@"%@%@", uidReceiver, uidCurrent];

    self.mArrMessages = [[NSMutableArray alloc] init];
    [self loadMessages];
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    bubbleImageOutgoing = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    bubbleImageIncoming = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadMessages {
    
    [[[mRef child:FIR_DATABASE_MESSAGES] child:mMessageId]  observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot && snapshot.value && [snapshot.value isKindOfClass:[NSDictionary class]]) {
            
            VMGrMessage *messageObj = [[VMGrMessage alloc] initWithDictionary:snapshot.value];
            
            JSQMessage *jsqMessage = [[JSQMessage alloc] initWithSenderId:messageObj.uidSender
                                                      senderDisplayName:messageObj.displayName
                                                                   date:[VMGrUtilities stringToDate:messageObj.date]
                                                                   text:messageObj.text];
            [self.mArrMessages addObject:jsqMessage];
            [self finishReceivingMessage];
            
        }
    }];
}

- (void)sendMessage:(NSString *)text {
    
    NSDictionary *dictMessage = @{FIR_MESSAGES_ID: mMessageId,
                             FIR_MESSAGES_UID_SENDER: mFIRUserCurrent.uid,
                             FIR_MESSAGES_UID_RECEIVER: self.mUserReceiver.uid,
                             FIR_MESSAGES_TEXT: text,
                             FIR_MESSAGES_DISPLAY_NAME: mFIRUserCurrent.displayName,
                             FIR_MESSAGES_DATE: [VMGrUtilities dateToString:[NSDate date]]};
    
    
    [[[[mRef child:FIR_DATABASE_MESSAGES] child:mMessageId] childByAutoId] setValue:dictMessage withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
    }];
    
    
}


- (void)addMessage {
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:@"053496-4509-289"
                                             senderDisplayName:@"Jesse Squires"
                                                          date:[NSDate distantPast]
                                                          text:NSLocalizedString(@"Welcome to JSQMessages: A messaging UI framework for iOS.", nil)];
    [self.mArrMessages addObject:message];
    
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)name date:(NSDate *)date {
    
    [self sendMessage:text];
    [self finishSendingMessage];
    
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.mArrMessages[indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessage *jsqMessage = [self.mArrMessages objectAtIndex:indexPath.row];
    if ([jsqMessage.senderId isEqual:mFIRUserCurrent.uid]) {
        return bubbleImageOutgoing;
    }
    return bubbleImageIncoming;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
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
    return [self.mArrMessages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    cell.textView.textColor = [UIColor blackColor];
    cell.textView.linkTextAttributes = @{NSForegroundColorAttributeName:[UIColor blueColor]};
    
    return cell;
}


#pragma mark - JSQMessages collection view flow layout delegate

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
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
