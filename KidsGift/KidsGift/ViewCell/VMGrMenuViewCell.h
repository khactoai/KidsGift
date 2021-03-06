//
//  VMGrMenuViewCell.h
//  KidsGift
//
//  Created by Dragon on 9/6/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VMGrMenuViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UILabel *distance;
@property (weak, nonatomic) IBOutlet UISlider *sliderDistance;
@property (weak, nonatomic) IBOutlet UISwitch *switchNotifyMatch;
@property (weak, nonatomic) IBOutlet UISwitch *switchNotifyChat;

@end
