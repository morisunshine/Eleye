//
//  EUtility.h
//  Eleye
//
//  Created by sheldon on 15/4/22.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, EViewPosition) {
    EViewPositionTop,
    EViewPositionLeft,
    EViewPositionRight,
    EViewPositionBottom
};

@interface EUtility : NSObject

+ (void)addlineOnView:(UIView *)view position:(EViewPosition)position;

@end
