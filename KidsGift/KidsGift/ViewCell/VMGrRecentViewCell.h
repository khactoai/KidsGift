//
//  VMGrRecentViewCell.h
//  KidsGift
//
//  Created by SLSS on 9/27/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VMGrRecentViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *message;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UIView *badgeView;

@end
