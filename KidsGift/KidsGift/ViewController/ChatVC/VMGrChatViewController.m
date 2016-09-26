//
//  VMGrChatViewController.m
//  KidsGift
//
//  Created by Dragon on 9/7/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import "VMGrChatViewController.h"
#import "VMGrRecentViewCell.h"
#import "VMGrConversationViewController.h"
#import "AppConstant.h"
#import "VMGrRecent.h"
#import "VMGrUtilities.h"

@import Firebase;

@interface VMGrChatViewController() {

    FIRDatabaseReference *mRef;
    FIRUser *mFIRUser;
    VMGrUser *mCurrentUser;
    
    NSMutableArray *mArrRecents;
}
@property (weak, nonatomic) IBOutlet UITableView *tableRecents;

@end

@implementation VMGrChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setLogoNavigation];
    
    self.tableRecents.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    mRef = [[FIRDatabase database] reference];
    mFIRUser = [[FIRAuth auth] currentUser];
    
    mArrRecents = [[NSMutableArray alloc] init];
    [self loadRecents];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadRecents {
    
    [[[mRef child:FIR_DATABASE_RECENTS] child:mFIRUser.uid]  observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot && snapshot.value && [snapshot.value isKindOfClass:[NSDictionary class]]) {
            VMGrRecent *recent = [[VMGrRecent alloc]initWithDictionary:snapshot.value];
            if (recent.text != nil && recent.displayName != nil) {
                [mArrRecents addObject:recent];
            }
            [self.tableRecents reloadData];
        }
    }];

}

#pragma mark UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return mArrRecents.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"VMGrRecentViewCell";
    
    VMGrRecentViewCell *cell = [self.tableRecents dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[VMGrRecentViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    VMGrRecent *recent = [mArrRecents objectAtIndex:indexPath.row];
    if (recent == nil) {
        return cell;
    }
    
    cell.name.text = recent.displayName;
    cell.message.text = recent.text;
    
    NSDate *date = [VMGrUtilities stringToDate:recent.date];
    NSString *dateRequest = [VMGrUtilities relativeDateStringForDate:date];
    cell.time.text = dateRequest;
    
    // Load image avatar
    cell.imgAvatar.layer.cornerRadius = cell.imgAvatar.frame.size.width/2;
    cell.imgAvatar.layer.masksToBounds = YES;
    
    if (recent.imgAvatar) {
        cell.imgAvatar.image = recent.imgAvatar;
    } else {
        cell.imgAvatar.image = [UIImage imageNamed:@"no_avatar"];
        [self loadImageAvatarWithUser:recent image:cell.imgAvatar];
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //VMGrConversationViewController *conversationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VMGrConversationViewController"];
    
    //[self.navigationController pushViewController:conversationViewController animated:YES];
    //self.tabBarController.tabBar.hidden = YES;
    
}

- (void)loadImageAvatarWithUser:(VMGrRecent *)recent image:(UIImageView*)imageView {
    
    FIRStorage *storage = [FIRStorage storage];
    FIRStorageReference *storageRef = [storage referenceForURL:FIR_STORAGE_SG];
    FIRStorageReference *avatarRef = [storageRef child:FIR_STORAGE_AVATAR];
    FIRStorageReference *uidRef = [avatarRef child:recent.uidSender];
    
    [uidRef dataWithMaxSize:1 * 1024 * 1024 completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        
        if (error != nil) {
            
        } else {
            UIImage *imgAvatar = [UIImage imageWithData:data];
            [imageView setImage:imgAvatar];
            recent.imgAvatar = imgAvatar;
        }
    }];
}

@end
