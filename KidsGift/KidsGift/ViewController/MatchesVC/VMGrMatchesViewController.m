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

@import Firebase;

@interface VMGrMatchesViewController () {

    FIRDatabaseReference *mRef;
    NSMutableArray *mDataUsers;
}

@end

@implementation VMGrMatchesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setLogoNavigation];
    
    mDataUsers = [[NSMutableArray alloc] init];
    
    mRef = [[FIRDatabase database] reference];
    [self loadUserMatches];
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

- (void)loadUserMatches {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    FIRDatabaseQuery *toysQuery = [[mRef child:@"toyhave"] queryEqualToValue:@"name" childKey:@"Sport"];
    [toysQuery  observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (snapshot && snapshot.value && [snapshot.value isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dicToys = [[NSDictionary alloc] initWithDictionary:snapshot.value];
            NSArray *arrKeys = [dicToys allKeys];
            for (NSString *key in arrKeys) {
                NSString *value = [dicToys objectForKey:key];
                [mDataUsers addObject:value];
            }
        }
        
    }];
    
}


@end
