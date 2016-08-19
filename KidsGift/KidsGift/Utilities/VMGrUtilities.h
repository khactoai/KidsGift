//
//  VMGrUtilities.h
//  KulturelyApp
//
//  Created by Dragon on 9/22/15.
//  Copyright (c) 2015 Dragon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VMGrUtilities : NSObject

+ (BOOL)connectedToNetwork;
+ (BOOL)isValidEmail:(NSString*)email;
+ (void)resizeToFitSubviews:(UIView *)view;

+ (NSString*)dateToString:(NSDate*)date;
+ (NSString*)dateToString:(NSDate*)date format:(NSString*)format;
+ (NSDate*)stringToDate:(NSString*)dateStr;
+ (NSString*)timeElapsed:(NSTimeInterval) seconds;

+ (void)saveImage:(UIImage*)image forKey:(NSString*)imageName;
+ (void)removeImage:(NSString*)fileName;
+ (UIImage*)loadImage:(NSString*)imageName;

@end
