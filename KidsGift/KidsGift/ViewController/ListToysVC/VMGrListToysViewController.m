//
//  VMGrListToysViewController.m
//  KidsGift
//
//  Created by Dragon on 9/7/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import "VMGrListToysViewController.h"
#import <FirebaseDatabase/FirebaseDatabase.h>
#import "AppConstant.h"
#import "VMGrToyViewCell.h"
#import "MBProgressHUD.h"

@import Firebase;

@interface VMGrListToysViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableToys;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation VMGrListToysViewController {

    FIRDatabaseReference *mRef;
    NSMutableArray *mDataToys;
    NSMutableArray *mDataFillter;
    
    NSString *mToySelected;
}

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableToys.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self setLogoNavigation];
    
    mDataToys = [[NSMutableArray alloc] init];
    mDataFillter = [[NSMutableArray alloc] init];
    
    mRef = [[FIRDatabase database] reference];
    [self loadDataToys];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadDataToys {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    FIRDatabaseQuery *toysQuery = [[mRef child:FIR_DATABASE_TOYS] queryOrderedByKey];
    [toysQuery  observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (snapshot && snapshot.value && [snapshot.value isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dicToys = [[NSDictionary alloc] initWithDictionary:snapshot.value];
            NSArray *arrKeys = [dicToys allKeys];
            for (NSString *key in arrKeys) {
                NSString *value = [dicToys objectForKey:key];
                [mDataFillter addObject:value];
                [mDataToys addObject:value];
                [self.tableToys reloadData];
            }
        }
        
    }];
    
}

- (void)setToySelected:(NSString*)toyName {
    mToySelected = toyName;
}


#pragma mark UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [mDataFillter count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"VMGrToyViewCell";
    
    VMGrToyViewCell *cell = [self.tableToys dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[VMGrToyViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSString *toyName = [mDataFillter objectAtIndex:indexPath.row];
    cell.name.text = toyName;
    
    BOOL isSelect = [mToySelected isEqualToString:toyName];
    [cell setSelecValue:isSelect];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self selectSignleValue:indexPath];
    
}

- (void)selectSignleValue:(NSIndexPath*)indexPathSelect {
    
    mToySelected = [mDataFillter objectAtIndex:indexPathSelect.row];
    
    for (int row = 0; row < [self.tableToys numberOfRowsInSection:0]; row ++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        VMGrToyViewCell *cell = [self.tableToys cellForRowAtIndexPath:indexPath];
        if (indexPathSelect.row == indexPath.row) {
            [cell setSelecValue:YES];
        } else {
            [cell setSelecValue:NO];
        }
    }
}


#pragma mark search var delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length == 0) {
        mDataFillter = mDataToys;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"SELF contains[c] %@", searchText];
        NSArray *arrFillter = [mDataToys filteredArrayUsingPredicate:predicate];
        mDataFillter = [[NSMutableArray alloc] initWithArray:arrFillter];
    }
    [self.tableToys reloadData];
    
}
- (IBAction)doneAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
    for (int row = 0; row < [self.tableToys numberOfRowsInSection:0]; row ++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        VMGrToyViewCell *cell = [self.tableToys cellForRowAtIndexPath:indexPath];
        if (cell.isSelected) {
            NSString *toySelected = [mDataFillter objectAtIndex:row];
            if ([delegate respondsToSelector:@selector(selectedToy:)]) {
                [delegate selectedToy:toySelected];
                return;
            }
        }
    }
    
}



@end
