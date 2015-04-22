//
//  EUtility.m
//  Eleye
//
//  Created by sheldon on 15/4/22.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "EUtility.h"

@implementation EUtility

+ (void)addlineOnView:(UIView *)view position:(EViewPosition)position
{
    CALayer *lineLayer = [CALayer layer];
    lineLayer.borderColor = RGBCOLOR(217, 217, 217).CGColor;
    lineLayer.borderWidth = .5;
    
    switch (position) {
        case EViewPositionTop: {
            lineLayer.frame = CGRectMake(0, 0, CGRectGetWidth(view.frame), 1);
            break;
        } 
        case EViewPositionLeft: {
            lineLayer.frame = CGRectMake(0, 0, 1, CGRectGetHeight(view.frame));
            break;
        }
        case EViewPositionRight: {
            lineLayer.frame = CGRectMake(CGRectGetWidth(view.frame) - 1, 0, 1, CGRectGetHeight(view.frame));
            break;
        }
        case EViewPositionBottom: {
            lineLayer.frame = CGRectMake(0, CGRectGetHeight(view.frame) - 1, CGRectGetWidth(view.frame), 1);
            break;
        }
    }
    
    [view.layer addSublayer:lineLayer];
}

@end
