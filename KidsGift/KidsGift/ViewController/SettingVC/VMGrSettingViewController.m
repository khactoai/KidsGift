//
//  VMGrSettingViewController.m
//  KidsGift
//
//  Created by Dragon on 8/18/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import "VMGrSettingViewController.h"
#import "VMGrMenuViewCell.h"
#import "AppConstant.h"
#import <FirebaseDatabase/FirebaseDatabase.h>
#import <AFNetworking.h>

@import Firebase;

enum CellMenu : NSUInteger {
    CellInfo            = 0,
    CellLocation        = 1,
    CellDistance        = 2,
    CellSetupGift       = 3,
    CellNotify          = 4,
    CellLogout          = 5
};

@interface VMGrSettingViewController () {
    
    NSArray *mArrCell;
    NSString *mLocationAddressFromGG;
    
    FIRDatabaseReference *mRef;
    FIRUser *mUser;

}

@property (weak, nonatomic) IBOutlet UITableView *tableSetting;

@end

@implementation VMGrSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableSetting.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocation) name:NOTIFICATION_LOCATION_UPDATE object:nil];
    
    mArrCell = [[NSArray alloc] initWithObjects:@"VMGrInfoViewCell",
                                                @"VMGrLocationViewCell",
                                                @"VMGrDiscoveryViewCell",
                                                @"VMGrSetupGiftViewCell",
                                                @"VMGrNotifyViewCell",
                                                @"VMGrLogoutViewCell", nil];
    
    
    
    mRef = [[FIRDatabase database] reference];
    mUser = [[FIRAuth auth] currentUser];
    
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

#pragma mark UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    int heightCell = 90;
    switch (indexPath.row) {
        case CellInfo:
            heightCell = 100;
            break;
        default:
            break;
    }
    return heightCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [mArrCell count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = [mArrCell objectAtIndex:indexPath.row];
    
    VMGrMenuViewCell *cell = [self.tableSetting dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[VMGrMenuViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    return cell;

}

- (void)updateLocation {
    
    
    [[[mRef child:FIR_DATABASE_USERS] child:mUser.uid]  observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *dicUser = [[NSDictionary alloc] initWithDictionary:snapshot.value];
        
        float latitude = [[dicUser objectForKey:FIR_USER_LATITUDE] floatValue];
        float longitude = [[dicUser objectForKey:FIR_USER_LONGITUDE] floatValue];
        
        [self loadAddressFromGGWithLatitude:latitude longitude:longitude];
        
    }];

}



- (void)loadAddressFromGGWithLatitude:(float)latitude longitude:(float)longitude {
    
    NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=false",latitude, longitude];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"%@ %@", response, responseObject);
            NSDictionary *dic = [[responseObject objectForKey:@"results"] objectAtIndex:0];
            
            if ([dic objectForKey:@"formatted_address"]) {
                NSArray *arrFormattedAddress = [dic objectForKey:@"formatted_address"];
                NSString *strFormattedAddress = [arrFormattedAddress description];
                if (strFormattedAddress != nil && ![strFormattedAddress isEqualToString:@""]) {
                    mLocationAddressFromGG = strFormattedAddress;
                    //[self updateCellLocation];
                    NSLog(@"mLocationAddressFromGG : %@", mLocationAddressFromGG);
                }
            }
            
            if (!mLocationAddressFromGG || [mLocationAddressFromGG isEqualToString:@""]) {
                if ([dic objectForKey:@"address_components"]) {
                    NSArray* arr = [dic objectForKey:@"address_components"];
                    NSString *cityName;
                    NSString *countryName;
                    for (NSDictionary* d in arr)
                    {
                        NSArray* typesArr = [d objectForKey:@"types"];
                        NSString* firstType = [typesArr objectAtIndex:0];
                        if([firstType isEqualToString:@"locality"] || [firstType isEqualToString:@"administrative_area_level_1"])
                            cityName = [d objectForKey:@"long_name"];
                        if([firstType isEqualToString:@"country"])
                            countryName = [d objectForKey:@"long_name"];
                        
                    }
                    mLocationAddressFromGG = [NSString stringWithFormat:@"%@,%@",cityName,countryName];
                    if (mLocationAddressFromGG != nil && ![mLocationAddressFromGG isEqualToString:@""]) {
                        //[self updateCellLocation];
                        NSLog(@"mLocationAddressFromGG : %@", mLocationAddressFromGG);
                    }
                }
                
            }
            
            
        }
    }];
    [dataTask resume];
}


@end
