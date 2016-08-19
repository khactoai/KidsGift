//
//  VMGrAlertView.h
//  KulturelyApp
//
//  Created by Dragon on 9/22/15.
//  Copyright (c) 2015 Dragon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VMGrAlertView : NSObject

+ (void)showAlertMessage:(NSString*)message;
+ (void)showAlertTitle:(NSString*)title message:(NSString*)message;
+ (void)showAlertNoConnection;

@end
