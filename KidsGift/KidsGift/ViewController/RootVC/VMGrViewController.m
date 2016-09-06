//
//  VMGrViewController.m
//  KulturelyApp
//
//  Created by SLSS on 10/3/15.
//  Copyright (c) 2015 Dragon. All rights reserved.
//

#import "VMGrViewController.h"

@interface VMGrViewController ()

@end

@implementation VMGrViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg_main_m"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    self.navigationItem.title = @"";
}

- (void) setLogoNavigation {
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 40.0)];
    titleView.backgroundColor = [UIColor clearColor];
    UIImageView *imageLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 79, 18)];
    imageLogo.image = [UIImage imageNamed:@"logo_m"];
    [imageLogo setCenter:CGPointMake(titleView.frame.size.width/2, titleView.frame.size.height/2)];
    [titleView addSubview:imageLogo];
    self.navigationItem.titleView = titleView;
}


@end
