//
//  EMenuView.h
//  Eleye
//
//  Created by sheldon on 15/4/28.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMenuView : UIView

@property (weak, nonatomic) IBOutlet UIButton *highlightActionBtn;
@property (weak, nonatomic) IBOutlet UIButton *ctionBtn;

@property (nonatomic, copy) void (^highlightBtnTappedHandler)(BOOL isHighlight);
@property (nonatomic, copy) void (^copyBtnTappedHandler)(void);

@end
