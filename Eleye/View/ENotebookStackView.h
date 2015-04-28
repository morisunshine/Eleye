//
//  ENotebookStackView.h
//  Eleye
//
//  Created by Sheldon on 15/4/21.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ENotebookStackView : UIView

@property (weak, nonatomic) IBOutlet UILabel *stackNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *viewBtn;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (nonatomic, copy) void (^btnHandler)(NSInteger index);

- (void)updateUIWithNotebook:(ENoteBookDO *)notebook;

@end
