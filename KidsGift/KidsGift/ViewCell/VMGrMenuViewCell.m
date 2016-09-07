//
//  VMGrMenuViewCell.m
//  KidsGift
//
//  Created by Dragon on 9/6/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import "VMGrMenuViewCell.h"

@implementation VMGrMenuViewCell

- (void)awakeFromNib {

}

- (IBAction)distanceChanged:(id)sender {
    
    int distanceValue = self.sliderDistance.value;
    self.distance.text = [NSString stringWithFormat:@"%d",distanceValue];
}

@end
