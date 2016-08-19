//
//  VMGrAlertView.m
//  KulturelyApp
//
//  Created by Dragon on 9/22/15.
//  Copyright (c) 2015 Dragon. All rights reserved.
//

#import "VMGrAlertView.h"

@implementation VMGrAlertView

+ (void)showAlertMessage:(NSString*)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

+ (void)showAlertTitle:(NSString*)title message:(NSString*)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

+ (void)showAlertNoConnection {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"No connection. Please check connection"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

@end
