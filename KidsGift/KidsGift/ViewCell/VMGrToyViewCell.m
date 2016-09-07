//
//  VMGrToyViewCell.m
//  KidsGift
//
//  Created by Dragon on 9/7/16.
//  Copyright © 2016 Mobifocuz. All rights reserved.
//

#import "VMGrToyViewCell.h"

@implementation VMGrToyViewCell {

    BOOL mIsSelect;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setSelecValue:(BOOL)isSelect {
    mIsSelect = isSelect;
    if (mIsSelect) {
        [self.imgCheck setImage:[UIImage imageNamed:@"check"]];
    } else {
        [self.imgCheck setImage:nil];
    }
}

- (BOOL)isSelected {
    return mIsSelect;
}

@end
