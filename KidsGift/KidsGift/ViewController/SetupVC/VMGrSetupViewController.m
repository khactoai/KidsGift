//
//  VMGrSetupViewController.m
//  KidsGift
//
//  Created by Dragon on 9/7/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import "VMGrSetupViewController.h"
#import "VMGrListToysViewController.h"
#import "ActionSheetPicker.h"
#import "AppConstant.h"
#import <FirebaseDatabase/FirebaseDatabase.h>
#import "VMGrAlertView.h"
#import "VMGrUtilities.h"
#import "MBProgressHUD.h"
#import "VMGrSetupViewCell.h"

@import Firebase;

#define PLEASE_SELECT_NUM @"Please select number"
#define PLEASE_SELECT_TOY @"Please select toy"

enum CellSetup : NSUInteger {
    CellNumber            = 0,
    CellToyHave        = 1,
    CellToyWant        = 3
};

@interface VMGrSetupViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableSetup;

@end


@interface VMGrSetupViewController () <VMGrToySelectedDelegate> {

    NSString *toySelected;
    NSInteger mSelectedNum;
    
    FIRUser *mFIRUser;
    FIRDatabaseReference *mRef;
    NSDictionary *mDictUser;
    NSIndexPath *mIndexPathSelectToy;
}

@end


@implementation VMGrSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setLogoNavigation];
    self.tableSetup.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    mDictUser = [[NSDictionary alloc] init];
    mRef = [[FIRDatabase database] reference];
    mFIRUser = [[FIRAuth auth] currentUser];
    [self loadDataSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


 #pragma mark - Navigation

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     
     if ([[segue identifier] isEqualToString:@"VMGrListToysSegue"]) {
         VMGrListToysViewController *vc = [segue destinationViewController];
         vc.delegate = self;
         [vc setToySelected:toySelected];
     }
 }

- (void)loadDataSetup {

    [[[mRef child:FIR_DATABASE_USERS] child:mFIRUser.uid]  observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        mDictUser = [[NSDictionary alloc] initWithDictionary:snapshot.value];
        [self.tableSetup reloadData];
        
    }];
}


#pragma mark UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"VMGrSetupViewCell";
    
    VMGrSetupViewCell *cell = [self.tableSetup dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[VMGrSetupViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    if (indexPath.row == 0) {
        cell.lableTitle.text = @"I have";
        if ([mDictUser objectForKey:FIR_USER_TOY_NUM]) {
            cell.labelValue.text = [mDictUser objectForKey:FIR_USER_TOY_NUM];
            [cell.labelValue setFont:[UIFont systemFontOfSize:16]];
            [cell.labelValue setTextColor:[UIColor blackColor]];
        } else {
            cell.labelValue.text = PLEASE_SELECT_NUM;
            [cell.labelValue setFont:[UIFont systemFontOfSize:14]];
            [cell.labelValue setTextColor:[UIColor grayColor]];
        }
    } else if (indexPath.row == 1) {
        cell.lableTitle.text = @"";
        if ([mDictUser objectForKey:FIR_USER_TOY_HAVE]) {
            cell.labelValue.text = [mDictUser objectForKey:FIR_USER_TOY_HAVE];
            [cell.labelValue setFont:[UIFont systemFontOfSize:16]];
            [cell.labelValue setTextColor:[UIColor blackColor]];
        } else {
            cell.labelValue.text = PLEASE_SELECT_TOY;
            [cell.labelValue setFont:[UIFont systemFontOfSize:14]];
            [cell.labelValue setTextColor:[UIColor grayColor]];
        }
    } else if (indexPath.row == 2) {
        cell.lableTitle.text = @"I want";
        cell.labelValue.text = @"";
        [cell.imgArrow setHidden:YES];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    } else if (indexPath.row == 3) {
        cell.lableTitle.text = @"";
        if ([mDictUser objectForKey:FIR_USER_TOY_WANT]) {
            cell.labelValue.text = [mDictUser objectForKey:FIR_USER_TOY_WANT];
            [cell.labelValue setFont:[UIFont systemFontOfSize:16]];
            [cell.labelValue setTextColor:[UIColor blackColor]];
        } else {
            cell.labelValue.text = PLEASE_SELECT_TOY;
            [cell.labelValue setFont:[UIFont systemFontOfSize:14]];
            [cell.labelValue setTextColor:[UIColor grayColor]];
        }
    }
    
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == CellNumber) {
        VMGrSetupViewCell *cell = (VMGrSetupViewCell*)[self.tableSetup cellForRowAtIndexPath:indexPath];
        [self selectNumer:cell];
    } else if (indexPath.row == CellToyHave || indexPath.row == CellToyWant) {
        mIndexPathSelectToy = indexPath;
        VMGrSetupViewCell *cell = (VMGrSetupViewCell*)[self.tableSetup cellForRowAtIndexPath:indexPath];
        toySelected = cell.labelValue.text;
        [self performSegueWithIdentifier:@"VMGrListToysSegue" sender:self];
    }
    
}

- (void)selectNumer:(VMGrSetupViewCell*)cell{
    NSArray *arrNumer = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", nil];
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select number"
                                            rows:arrNumer
                                initialSelection:mSelectedNum
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           NSLog(@"Picker: %@, Index: %ld, value: %@", picker, (long)selectedIndex, selectedValue);
                                           mSelectedNum = selectedIndex;
                                           cell.labelValue.text = [arrNumer objectAtIndex:mSelectedNum];
                                           [cell.labelValue setFont:[UIFont systemFontOfSize:16]];
                                           [cell.labelValue setTextColor:[UIColor blackColor]];
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:cell];
    
    
}


#pragma mark delegate select

- (void)selectedToy:(NSString*)toyName {
    VMGrSetupViewCell *cell = (VMGrSetupViewCell*)[self.tableSetup cellForRowAtIndexPath:mIndexPathSelectToy];
    cell.labelValue.text = toyName;
    [cell.labelValue setFont:[UIFont systemFontOfSize:16]];
    [cell.labelValue setTextColor:[UIColor blackColor]];
}

- (IBAction)setupAction:(id)sender {
    
    if (![VMGrUtilities connectedToNetwork]) {
        [VMGrAlertView showAlertNoConnection];
        return;
    }
    
    NSString *toyNum;
    NSString *toyHave;
    NSString *toyWant;
    
    for (int row = 0; row < [self.tableSetup numberOfRowsInSection:0]; row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        VMGrSetupViewCell *cell = (VMGrSetupViewCell*)[self.tableSetup cellForRowAtIndexPath:indexPath];
        if (cell && row == CellNumber) {
            toyNum = cell.labelValue.text;
        } else if (cell && row == CellToyHave) {
            toyHave = cell.labelValue.text;
        } else if (cell && row == CellToyWant) {
            toyWant = cell.labelValue.text;
        }
    }
    
    if (![toyNum isEqualToString:PLEASE_SELECT_NUM] && ![toyHave isEqualToString:PLEASE_SELECT_TOY] && ![toyWant isEqualToString:PLEASE_SELECT_TOY]) {
        
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDictionary *dicToy = @{FIR_USER_TOY_NUM: toyNum,
                                  FIR_USER_TOY_HAVE: toyHave,
                                  FIR_USER_TOY_WANT: toyWant,
                                  FIR_USER_TOY_DATE_REQUEST: [dateFormatter stringFromDate:[NSDate date]]};
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[[mRef child:FIR_DATABASE_USERS] child:mFIRUser.uid] updateChildValues:dicToy withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
            if (error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [VMGrAlertView showAlertMessage:@"Setup error, please check again"];
            } else {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [VMGrAlertView showAlertMessage:@"Setup success"];
            }
            
        }];
        
    } else {
        [VMGrAlertView showAlertMessage:PLEASE_SELECT_TOY];
    }
    
}


@end
