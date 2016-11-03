//
//  VMGrMatchesViewController.m
//  KidsGift
//
//  Created by Dragon on 8/18/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import "VMGrMatchesViewController.h"
#import "RESideMenu.h"
#import "MBProgressHUD.h"
#import "AppConstant.h"
#import <FirebaseDatabase/FirebaseDatabase.h>
#import "VMGrMatchesViewCell.h"
#import "VMGrUser.h"
#import "VMGrMatchesHeaderViewCell.h"
#import "VMGrUtilities.h"
#import <CoreLocation/CoreLocation.h>
#import "LGRefreshView.h"
#import "VMGrConversationViewController.h"
#import "VMGrToy.h"
#import "VMGrAlertView.h"

@import Firebase;

@interface VMGrMatchesViewController () <LGRefreshViewDelegate, VMGrToyLoadUsersMatchesDelegate>{

    FIRDatabaseReference *mRef;
    FIRUser *mFIRUser;
    VMGrUser *mCurrentUser;
    
    NSMutableArray *mArrToySetup;
    NSInteger mSectionDelete;
    
}
@property (weak, nonatomic) IBOutlet UITableView *tableMatches;
@property (strong, nonatomic) LGRefreshView *refreshView;

@end

@implementation VMGrMatchesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setLogoNavigation];
    self.tableMatches.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    mArrToySetup = [[NSMutableArray alloc] init];
    
    mFIRUser = [[FIRAuth auth] currentUser];
    mRef = [[FIRDatabase database] reference];
    [self loadCurrentUser];
    
    self.refreshView = [LGRefreshView refreshViewWithScrollView:self.tableMatches delegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadCurrentUser) name:NOTIFICATION_SETUP_UPDATE object:nil];
    [self setLogoNavigation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadCurrentUser {
    
    // check connection
    if (![VMGrUtilities connectedToNetwork]) {
        [VMGrAlertView showAlertNoConnection];
        return;
    }
    
    MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [progressHUD hideAnimated:YES afterDelay:60.0];
    [[[mRef child:FIR_DATABASE_USERS] child:mFIRUser.uid]  observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (snapshot && snapshot.value && [snapshot.value isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dicUser = [[NSDictionary alloc] initWithDictionary:snapshot.value];
            mCurrentUser = [[VMGrUser alloc] initWithDictionary:dicUser];
            [mArrToySetup removeLastObject];
            if (mCurrentUser.arrToySetup && mCurrentUser.arrToySetup.count > 0) {
                mArrToySetup = mCurrentUser.arrToySetup;
                // load user matches
                [self loadUsersMatches];
            }
            [self.tableMatches reloadData];
        }
    }];
}

// Load users matches
- (void)loadUsersMatches {
    if (mArrToySetup && mArrToySetup.count > 0) {
        for (VMGrToy *toy in mArrToySetup) {
            toy.delegate = self;
            [toy loadUsersMatches:mRef currentUser:mCurrentUser];
        }
    }
}

#pragma mark UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return mArrToySetup.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    VMGrToy *toy = [mArrToySetup objectAtIndex:section];
    return toy.arrUserMatches.count > 0 ? toy.arrUserMatches.count : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 55;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *identifier = @"VMGrMatchesHeaderViewCell";
    
    VMGrMatchesHeaderViewCell *cell = [self.tableMatches dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[VMGrMatchesHeaderViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (mArrToySetup && mArrToySetup.count > 0) {
        VMGrToy *toy = [mArrToySetup objectAtIndex:section];
        cell.title.text = [NSString stringWithFormat:@"%@ %@ for %@", toy.toyNum, toy.toyHave, toy.toyWant];
        cell.btnDelete.tag = section;
        [cell.btnDelete addTarget:self action:@selector(deleteGroup:) forControlEvents:UIControlEventTouchUpInside];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"VMGrMatchesViewCell";
    
    VMGrMatchesViewCell *cell = [self.tableMatches dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[VMGrMatchesViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    VMGrToy *toy = [mArrToySetup objectAtIndex:indexPath.section];
    if (toy && toy.arrUserMatches && toy.arrUserMatches.count > 0) {
        VMGrUser *user = [toy.arrUserMatches objectAtIndex:indexPath.row];
        if (!user) {
            return cell;
        }
        cell.noUserMatchesView.hidden = YES;
        cell.userInteractionEnabled = YES;
        cell.name.text = user.name;
        NSDate *date = [VMGrUtilities stringToDate:user.toyDateRequest];
        NSString *dateRequest = [VMGrUtilities relativeDateStringForDate:date];
        cell.time.text = dateRequest;
        // Load image avatar
        cell.imgAvatar.layer.cornerRadius = cell.imgAvatar.frame.size.width/2;
        cell.imgAvatar.layer.masksToBounds = YES;
        if (user.imgAvatar) {
            cell.imgAvatar.image = user.imgAvatar;
        } else {
            cell.imgAvatar.image = [UIImage imageNamed:@"no_avatar"];
            [self loadImageAvatarWithUser:user image:cell.imgAvatar];
        }
        
        
    } else {
        cell.noUserMatchesView.hidden = NO;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = NO;
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    VMGrToy *toy = [mArrToySetup objectAtIndex:indexPath.section];
    if (toy && toy.arrUserMatches) {
        VMGrUser *receiverUser = [toy.arrUserMatches objectAtIndex:indexPath.row];
        VMGrConversationViewController *conversationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VMGrConversationViewController"];
        [conversationViewController setCurrentUser:mCurrentUser receiverUser:receiverUser];
        [self.navigationController pushViewController:conversationViewController animated:YES];
        self.tabBarController.tabBar.hidden = YES;
    }
}

- (void)loadImageAvatarWithUser:(VMGrUser *)user image:(UIImageView*)imageView {
    
    FIRStorage *storage = [FIRStorage storage];
    FIRStorageReference *storageRef = [storage referenceForURL:FIR_STORAGE_SG];
    FIRStorageReference *avatarRef = [storageRef child:FIR_STORAGE_AVATAR];
    FIRStorageReference *uidRef = [avatarRef child:user.uid];
    
    [uidRef dataWithMaxSize:1 * 1024 * 1024 completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        
        if (error != nil) {
            
        } else {
            UIImage *imgAvatar = [UIImage imageWithData:data];
            [imageView setImage:imgAvatar];
            user.imgAvatar = imgAvatar;
        }
    }];
}

#pragma mark load users matches Delegate
- (void)loadUsersMatchesFinish:(VMGrToy*)toy {
    [self.tableMatches reloadData];
}

- (void)deleteGroup:(UIButton*)sender {
    mSectionDelete = sender.tag;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Do you want to delete group?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Delete", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        VMGrToy *toy = [mArrToySetup objectAtIndex:mSectionDelete];
        if (toy) {
            [[[[[mRef child:FIR_DATABASE_USERS] child:mCurrentUser.uid]child:FIR_USER_TOY_SETUP] child:toy.groupID] removeValueWithCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                if (!error) {
                    [self loadCurrentUser];
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SETUP_DELETE object:self];
                }
            }];
        }
        
    }
}

#pragma mark Refesh Delegate
- (void)refreshViewRefreshing:(LGRefreshView *)refreshView {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
        [self.refreshView endRefreshing];
    });
    [self loadUsersMatches];
}

@end
