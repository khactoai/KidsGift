//
//  VMGrUtilities.m
//  KulturelyApp
//
//  Created by Dragon on 9/22/15.
//  Copyright (c) 2015 Dragon. All rights reserved.
//

#import "VMGrUtilities.h"
#import "Reachability.h"
#import "AppConstant.h"

@implementation VMGrUtilities

#pragma mark check network

+ (BOOL)connectedToNetwork {
    BOOL isInternet = NO;
    Reachability *internetReachability = [Reachability reachabilityForInternetConnection];
    [internetReachability startNotifier];
    NetworkStatus remoteHostStatus = [internetReachability currentReachabilityStatus];
    if(remoteHostStatus == NotReachable)
    {
        isInternet = NO;
    }
    else if (remoteHostStatus == ReachableViaWWAN)
    {
        isInternet = YES;
    }
    else if (remoteHostStatus == ReachableViaWiFi)
    {
        isInternet = YES;
    }
    
    return isInternet;
}

#pragma mark valid email

+ (BOOL)isValidEmail:(NSString*)email {
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

#pragma mark SizeToFix UIView

+ (void)resizeToFitSubviews:(UIView *)view {
    float w = 0.0, h = 0.0;
    
    for (UIView *v in view.subviews) {
        float fw = v.frame.origin.x + v.frame.size.width;
        float fh = v.frame.origin.y + v.frame.size.height;
        w = MAX(fw, w);
        h = MAX(fh, h);
    }
    [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, w, h)];
}

#pragma mark convert

+ (NSString*)dateToString:(NSDate*)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:DATE_FORMAT];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    return [formatter stringFromDate:date];
}

+ (NSString*)dateToString:(NSDate*)date format:(NSString*)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    return [formatter stringFromDate:date];
}

+ (NSDate*)stringToDate:(NSString*)dateStr {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:DATE_FORMAT];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    return [formatter dateFromString:dateStr];
}

+ (NSString*)timeElapsed:(NSTimeInterval) seconds {
    NSString *elapsed;
    if (seconds < 60)
    {
        elapsed = @"Just now";
    }
    else if (seconds < 60 * 60)
    {
        int minutes = (int) (seconds / 60);
        elapsed = [NSString stringWithFormat:@"%d %@", minutes, (minutes > 1) ? @"mins" : @"min"];
    }
    else if (seconds < 24 * 60 * 60)
    {
        int hours = (int) (seconds / (60 * 60));
        elapsed = [NSString stringWithFormat:@"%d %@", hours, (hours > 1) ? @"hours" : @"hour"];
    }
    else
    {
        int days = (int) (seconds / (24 * 60 * 60));
        elapsed = [NSString stringWithFormat:@"%d %@", days, (days > 1) ? @"days" : @"day"];
    }
    return elapsed;
}

//saving an image
+ (void)saveImage:(UIImage*)image forKey:(NSString*)imageName
{
    NSData *imageData = UIImagePNGRepresentation(image);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", imageName]];
    [fileManager createFileAtPath:fullPath contents:imageData attributes:nil];
}

//removing an image
+ (void)removeImage:(NSString*)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", fileName]];
    [fileManager removeItemAtPath: fullPath error:NULL];
}

//loading an image
+ (UIImage*)loadImage:(NSString*)imageName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", imageName]];
    return [UIImage imageWithContentsOfFile:fullPath];
}

+ (NSString *)relativeDateStringForDate:(NSDate *)date {
    NSCalendarUnit units = NSMinuteCalendarUnit | NSHourCalendarUnit | NSCalendarUnitDay | NSCalendarUnitWeekOfYear |
    NSCalendarUnitMonth | NSCalendarUnitYear;
    
    // if `date` is before "now" (i.e. in the past) then the components will be positive
    NSDateComponents *components = [[NSCalendar currentCalendar] components:units
                                                                   fromDate:date
                                                                     toDate:[NSDate date]
                                                                    options:0];
    
    if (components.year > 0) {
        if (components.year == 1) {
            return [NSString stringWithFormat:@"%ld year ago", (long)components.year];
        } else {
            return [NSString stringWithFormat:@"%ld years ago", (long)components.year];
        }
    } else if (components.month > 0) {
        if (components.month == 1) {
            return [NSString stringWithFormat:@"%ld month ago", (long)components.month];
        } else {
            return [NSString stringWithFormat:@"%ld months ago", (long)components.month];
        }
        
    } else if (components.weekOfYear > 0) {
        if (components.weekOfYear == 1) {
            return [NSString stringWithFormat:@"%ld week ago", (long)components.weekOfYear];
        } else {
            return [NSString stringWithFormat:@"%ld weeks ago", (long)components.weekOfYear];
        }
    } else if (components.day > 0) {
        if (components.day == 1) {
            return @"Yesterday";
        } else {
            return [NSString stringWithFormat:@"%ld days ago", (long)components.day];
        }
    } else if (components.hour > 0) {
        if(components.hour == 1) {
            return [NSString stringWithFormat:@"%ld hour ago",(long)components.hour];
        } else {
            return [NSString stringWithFormat:@"%ld hours ago",(long)components.hour];
        }
    } else {
        return @"Just now";
    }
}


@end
