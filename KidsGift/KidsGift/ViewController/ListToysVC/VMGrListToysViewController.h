//
//  VMGrListToysViewController.h
//  KidsGift
//
//  Created by Dragon on 9/7/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VMGrViewController.h"

@protocol VMGrToySelectedDelegate;

@interface VMGrListToysViewController : VMGrViewController

@property (strong, nonatomic) NSObject <VMGrToySelectedDelegate> *delegate;

- (void)setToySelected:(NSString*)toyName;

@end

@protocol VMGrToySelectedDelegate
@optional
- (void)selectedToy:(NSString*)toyName;
@end
