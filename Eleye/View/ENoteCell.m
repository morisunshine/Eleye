//
//  ENoteCell.m
//  Eleye
//
//  Created by Sheldon on 15/4/21.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "ENoteCell.h"
#import <ENSDKAdvanced.h>

static NSInteger kCellHeight = 100;

@implementation ENoteCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    UIView * selectedBackgroundView = [[UIView alloc] init];
    [selectedBackgroundView setBackgroundColor:SELECTEDCOLOR];
    [self setSelectedBackgroundView:selectedBackgroundView];
    // Configure the view for the selected state
}

- (void)updateUIWithNote:(EDAMNote *)note
{
    self.titleLabel.text = note.title;
    self.contentLabel.text = note.content;
    
    CALayer *lineLayer = [CALayer layer];
    lineLayer.borderColor = RGBCOLOR(217, 217, 217).CGColor;
    lineLayer.borderWidth = .5;
    lineLayer.frame = CGRectMake(17, kCellHeight - 1, APP_SCREEN_WIDTH - 34, 1);
    [self.contentView.layer addSublayer:lineLayer];
}

@end
