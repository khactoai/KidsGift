//
//  VMGrRootViewController.m
//  KulturelyApp
//
//  Created by Dragon on 10/1/15.
//  Copyright (c) 2015 Dragon. All rights reserved.
//

#import "VMGrRootViewController.h"
#import "VMGrSettingViewController.h"
#import "AppConstant.h"

@interface VMGrRootViewController ()

@end

@implementation VMGrRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (void)awakeFromNib
{
    UINavigationController *navigationMainPage = [self.storyboard instantiateViewControllerWithIdentifier:@"navigationMatches"];
    UINavigationController *navigationSetting = [self.storyboard instantiateViewControllerWithIdentifier:@"navigationSetting"];
    
    self.leftMenuViewController = navigationSetting;
    self.contentViewController = navigationMainPage;
    
    self.panGestureEnabled = NO;
    self.scaleMenuView = NO;
    self.scaleContentView = NO;
    self.contentViewScaleValue = 1.0;
    self.contentViewInLandscapeOffsetCenterX = SCREEN_WIDTH;
    self.contentViewInPortraitOffsetCenterX = SCREEN_WIDTH;
    //self.contentViewShadowOpacity = 0.6;
    //self.contentViewShadowRadius = 12;
    //self.contentViewShadowEnabled = YES;
}

@end
