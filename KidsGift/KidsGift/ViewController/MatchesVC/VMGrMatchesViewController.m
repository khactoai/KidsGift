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

@import Firebase;

@interface VMGrMatchesViewController () <LGRefreshViewDelegate>{

    FIRDatabaseReference *mRef;
    FIRUser *mFIRUser;
    VMGrUser *mCurrentUser;
    CLLocation *mCurrentLocation;
    
    NSMutableArray *mAllUsers;
    NSMutableArray *mGroupUsers;
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
    
    mAllUsers = [[NSMutableArray alloc] init];
    mGroupUsers = [[NSMutableArray alloc] init];
    
    mFIRUser = [[FIRAuth auth] currentUser];
    mRef = [[FIRDatabase database] reference];
    [self loadUser];
    
    self.refreshView = [LGRefreshView refreshViewWithScrollView:self.tableMatches delegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)loadUser {
     __weak typeof (self) wself = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[[mRef child:FIR_DATABASE_USERS] child:mFIRUser.uid]  observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (snapshot && snapshot.value && [snapshot.value isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dicUser = [[NSDictionary alloc] initWithDictionary:snapshot.value];
            mCurrentUser = [[VMGrUser alloc] initWithDictionary:dicUser];
            mCurrentLocation = [mCurrentUser getLocation];
            if (mCurrentUser.toyHave && mCurrentUser.toyWant) {
                if (wself) {
                    [wself loadAllUsers];
                }
            }
        }
    }];
}


- (void)loadAllUsers {
    
    __weak typeof (self) wself = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    FIRDatabaseQuery *allUser = [mRef child:FIR_DATABASE_USERS];
    [allUser observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (snapshot && snapshot.value && [snapshot.value isKindOfClass:[NSDictionary class]]) {
            mAllUsers = [[NSMutableArray alloc] init];
            mGroupUsers = [[NSMutableArray alloc] init];
            
            NSDictionary *dicUsers = [[NSDictionary alloc] initWithDictionary:snapshot.value];
            NSArray *arrKeys = [dicUsers allKeys];
            for (NSString *key in arrKeys) {
                NSDictionary *value = [dicUsers objectForKey:key];
                VMGrUser *user = [[VMGrUser alloc] initWithDictionary:value];
                [user setDistanceWithLocation:mCurrentLocation];
                if (![user.uid isEqual:mCurrentUser.uid]) {
                    [mAllUsers addObject:user];
                }
            }
            // Sort user with distance
            [self sortUsesWithDistance:mAllUsers];
            
            if (mAllUsers.count > 0) {
                // Group user matches
                [wself groupUsersMatches];
                
                // Group other users
                while (mAllUsers.count > 0) {
                    [wself groupUsers];
                }
                
                // Reload table
                [wself.tableMatches reloadData];
            }
            
        }
    }];
}

- (void)groupUsersMatches {

    NSMutableArray *arrUsersMatches = [[NSMutableArray alloc] init];
    NSMutableArray *arrUsersWithToyHave = [[NSMutableArray alloc] init];
    NSMutableArray *arrUsersWithToyWant = [[NSMutableArray alloc] init];
   
    for (VMGrUser *user in mAllUsers) {
        if (user.toyHave && user.toyWant) {
            if ([user.toyHave isEqualToString:mCurrentUser.toyWant] && [user.toyWant isEqualToString:mCurrentUser.toyHave]) {
                [arrUsersMatches addObject:user];
            } else if ([user.toyHave isEqualToString:mCurrentUser.toyWant]) {
                [arrUsersWithToyHave addObject:user];
            } else if ([user.toyWant isEqualToString:mCurrentUser.toyHave]) {
                [arrUsersWithToyWant addObject:user];
            }
        }
    }
    if (arrUsersMatches.count > 0) {
        [mAllUsers removeObjectsInArray:[NSArray arrayWithArray:arrUsersMatches]];
        [mGroupUsers addObject:arrUsersMatches];
    }
    
    if (arrUsersWithToyHave.count > 0) {
        [mAllUsers removeObjectsInArray:[NSArray arrayWithArray:arrUsersWithToyHave]];
        [mGroupUsers addObject:arrUsersWithToyHave];
    }
    
    if (arrUsersWithToyWant.count > 0) {
        [mAllUsers removeObjectsInArray:[NSArray arrayWithArray:arrUsersWithToyWant]];
        [mGroupUsers addObject:arrUsersWithToyWant];
    }
    
}

- (void)groupUsers {

    NSMutableArray *arrUsers = [[NSMutableArray alloc] init];
    VMGrUser *userFirst = [mAllUsers objectAtIndex:0];
    NSString *toyHave = userFirst.toyHave;
    NSString *toyWant = userFirst.toyWant;
    NSString *toyNum = userFirst.toyNum;
    
    if (!toyHave || !toyWant) {
        [mAllUsers removeObject:userFirst];
        return;
    }
    [arrUsers addObject:userFirst];
    
    for (int index = 1; index < mAllUsers.count; index++) {
        VMGrUser *user = [mAllUsers objectAtIndex:index];
        if (user.toyHave && user.toyWant) {
            if ([user.toyHave isEqual:toyHave] && [user.toyWant isEqual:toyWant] && [user.toyNum isEqual:toyNum]) {
                [arrUsers addObject:user];
            }
        }
    }
    [mAllUsers removeObjectsInArray:[NSArray arrayWithArray:arrUsers]];
    [mGroupUsers addObject:arrUsers];
    
}

- (void)sortUsesWithDistance:(NSMutableArray *)arrSort{
    [arrSort sortUsingComparator:^NSComparisonResult(VMGrUser  *user1, VMGrUser  *user2) {
        if (user1.locationDistance > user2.locationDistance)
        {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if (user1.locationDistance < user2.locationDistance)
        {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
}

#pragma mark UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return mGroupUsers.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSMutableArray*)[mGroupUsers objectAtIndex:section]).count;
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
    NSMutableArray *arr = [mGroupUsers objectAtIndex:section];
    VMGrUser *user = [arr firstObject];
    cell.title.text = [NSString stringWithFormat:@"%@ %@ for %@", user.toyNum, user.toyHave, user.toyWant];
    
    cell.btnDelete.tag = section;
    [cell.btnDelete addTarget:self action:@selector(deleteGroup:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"VMGrMatchesViewCell";
    
    VMGrMatchesViewCell *cell = [self.tableMatches dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[VMGrMatchesViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    
    NSMutableArray *arr = [mGroupUsers objectAtIndex:indexPath.section];
    VMGrUser *user = [arr objectAtIndex:indexPath.row];
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

    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
        [mGroupUsers removeObjectAtIndex:mSectionDelete];
        [self.tableMatches reloadData];
    }
}

#pragma mark Refesh Delegate
- (void)refreshViewRefreshing:(LGRefreshView *)refreshView {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
        [self.refreshView endRefreshing];
    });
    
    [self loadUser];
}


@end
