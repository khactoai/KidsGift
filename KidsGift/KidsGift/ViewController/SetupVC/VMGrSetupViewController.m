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

@import Firebase;

#define PLEASE_SELECT_TOY @"Please select toy"

@interface VMGrSetupViewController () <VMGrToySelectedDelegate> {

    NSString *toySelected;
    BOOL isToyHaveSelected;
    NSInteger mSelectedNum;
    
    FIRUser *mFIRUser;
    FIRDatabaseReference *mRef;
}

@property (weak, nonatomic) IBOutlet UIButton *btnToyNum;
@property (weak, nonatomic) IBOutlet UIButton *btnToyHave;
@property (weak, nonatomic) IBOutlet UIButton *btnToyWant;

@end


@implementation VMGrSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setLogoNavigation];
    
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
        
        NSDictionary *dictUser = [[NSDictionary alloc] initWithDictionary:snapshot.value];
        
        // Num
        if ([dictUser objectForKey:FIR_USER_TOY_NUM]) {
            [self.btnToyNum setTitle:[dictUser objectForKey:FIR_USER_TOY_NUM] forState:UIControlStateNormal];
        } else {
            [self.btnToyNum setTitle:@"1" forState:UIControlStateNormal];
        }
        
        // have
        if ([dictUser objectForKey:FIR_USER_TOY_HAVE]) {
            [self.btnToyHave setTitle:[dictUser objectForKey:FIR_USER_TOY_HAVE] forState:UIControlStateNormal];
        } else {
            [self.btnToyHave setTitle:PLEASE_SELECT_TOY forState:UIControlStateNormal];
        }
        
        // want
        if ([dictUser objectForKey:FIR_USER_TOY_WANT]) {
            [self.btnToyWant setTitle:[dictUser objectForKey:FIR_USER_TOY_WANT] forState:UIControlStateNormal];
        } else {
            [self.btnToyWant setTitle:PLEASE_SELECT_TOY forState:UIControlStateNormal];
        }
        
    }];
}

#pragma mark delegate select

- (void)selectedToy:(NSString*)toyName {
    if (isToyHaveSelected) {
        [self.btnToyHave setTitle:toyName forState:UIControlStateNormal];
    } else {
        [self.btnToyWant setTitle:toyName forState:UIControlStateNormal];
    }
    
}

- (IBAction)toyHaveAction:(id)sender {
    isToyHaveSelected = YES;
    toySelected = self.btnToyHave.titleLabel.text;
    [self performSegueWithIdentifier:@"VMGrListToysSegue" sender:self];
}

- (IBAction)toyWantAction:(id)sender {
    isToyHaveSelected = NO;
    toySelected = self.btnToyWant.titleLabel.text;
    [self performSegueWithIdentifier:@"VMGrListToysSegue" sender:self];
    
}

- (IBAction)numAction:(id)sender {
    
    NSArray *arrNumer = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", nil];
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select number"
                                            rows:arrNumer
                                initialSelection:mSelectedNum
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           NSLog(@"Picker: %@, Index: %ld, value: %@", picker, (long)selectedIndex, selectedValue);
                                           mSelectedNum = selectedIndex;
                                           [self.btnToyNum setTitle:[arrNumer objectAtIndex:mSelectedNum] forState:UIControlStateNormal];
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender];
    
    
}

- (IBAction)setupAction:(id)sender {
    
    if (![VMGrUtilities connectedToNetwork]) {
        [VMGrAlertView showAlertNoConnection];
        return;
    }
    
    NSString *toyNum = self.btnToyNum.titleLabel.text;
    NSString *toyHave = self.btnToyHave.titleLabel.text;
    NSString *toyWant = self.btnToyWant.titleLabel.text;
    
    if (![toyNum isEqualToString:@""] && ![toyHave isEqualToString:PLEASE_SELECT_TOY] && ![toyWant isEqualToString:PLEASE_SELECT_TOY]) {
        
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
