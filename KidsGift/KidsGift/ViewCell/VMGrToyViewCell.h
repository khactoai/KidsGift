//
//  VMGrToyViewCell.h
//  KidsGift
//
//  Created by Dragon on 9/7/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VMGrToyViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *imgCheck;

- (void)setSelecValue:(BOOL)isSelect;
- (BOOL)isSelected;

@end

