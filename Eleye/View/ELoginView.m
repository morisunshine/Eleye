//
//  ELoginView.m
//  Eleye
//
//  Created by Sheldon on 15/5/6.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "ELoginView.h"

@implementation ELoginView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.evernoteBtn.alpha = 0;
    self.yinxiangBtn.alpha = 0;
    self.yinxiangBtn.layer.borderWidth = 1.0;
    self.yinxiangBtn.layer.borderColor = RGBCOLOR(139, 87, 42).CGColor;
    self.yinxiangBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
}

@end
