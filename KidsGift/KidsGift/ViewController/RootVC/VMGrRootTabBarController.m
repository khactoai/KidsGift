//
//  VMGrRootTabBarController.m
//  KidsGift
//
//  Created by SLSS on 9/28/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import "VMGrRootTabBarController.h"
#import "AppConstant.h"
#import "VMGrRecent.h"
#import "VMGrUtilities.h"

@import Firebase;

@interface VMGrRootTabBarController () {

    FIRDatabaseReference *mRef;
    FIRUser *mFIRUser;
    NSMutableArray *mArrRecents;
}

@end

@implementation VMGrRootTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    mRef = [[FIRDatabase database] reference];
    mFIRUser = [[FIRAuth auth] currentUser];
    
    mArrRecents = [[NSMutableArray alloc] init];
    [self loadRecents];
    [self updateRecents];
    
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
            [self setupBadgeTabChat];
        }
    }];
}

- (void)updateRecents {
    
    [[[mRef child:FIR_DATABASE_RECENTS] child:mFIRUser.uid]  observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot && snapshot.value && [snapshot.value isKindOfClass:[NSDictionary class]]) {
            VMGrRecent *recent = [[VMGrRecent alloc]initWithDictionary:snapshot.value];
            if (recent.text != nil && recent.displayName != nil) {
                for (int index = 0; index < mArrRecents.count; index++) {
                    VMGrRecent *recentChange = [mArrRecents objectAtIndex:index];
                    if ([recent.uidReceiver isEqual:recentChange.uidReceiver]) {
                        recent.imgAvatar = recentChange.imgAvatar;
                        [mArrRecents replaceObjectAtIndex:index withObject:recent];
                    }
                }
            }
            [self setupBadgeTabChat];
        }
    }];
}

- (void)setupBadgeTabChat {
    NSInteger badge = 0;
    for (VMGrRecent *recent in mArrRecents) {
        if (recent.count > 0) {
            badge ++;
        }
    }
    if (badge > 0) {
        [[self.viewControllers objectAtIndex:2] tabBarItem].badgeValue = [NSString stringWithFormat:@"%ld", (long)badge];
    } else {
        [[self.viewControllers objectAtIndex:2] tabBarItem].badgeValue = nil;
    }
    
}

@end
