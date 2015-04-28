//
//  EMenuView.m
//  Eleye
//
//  Created by sheldon on 15/4/28.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "EMenuView.h"

@implementation EMenuView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.layer.cornerRadius = 5;
    self.clipsToBounds = YES;
}

- (IBAction)hightlightBtnTapped:(UIButton *)sender 
{
    if (self.highlightBtnTappedHandler) {
        if ([sender.titleLabel.text isEqualToString:@"highlight"]) {
            self.highlightBtnTappedHandler(YES);
        } else {
            self.highlightBtnTappedHandler(NO);
        }
    }
}

- (IBAction)cBtnTapped:(id)sender 
{
    if (self.copyBtnTappedHandler) {
        self.copyBtnTappedHandler();
    }
}

@end
