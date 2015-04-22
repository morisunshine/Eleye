//
//  ENoteCell.m
//  Eleye
//
//  Created by Sheldon on 15/4/21.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "ENoteCell.h"
#import <ENSDKAdvanced.h>

@implementation ENoteCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateUIWithNote:(ENoteDO *)note
{
    self.titleLabel.text = note.title;
    self.contentLabel.text = note.content;
//    [EUtility addlineOnView:self position:EViewPositionBottom insert:17];
}

@end
