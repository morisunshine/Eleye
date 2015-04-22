//
//  ENotebookStackView.m
//  Eleye
//
//  Created by Sheldon on 15/4/21.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "ENotebookStackView.h"

@implementation ENotebookStackView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [EUtility addlineOnView:self position:EViewPositionBottom insert:17];
}

- (void)updateUIWithNotebook:(ENoteBookDO *)notebook
{
    self.stackNameLabel.text = notebook.name;
    if (notebook.count) {
        self.countLabel.text = [NSString stringWithFormat:@"%@ notes", notebook.count];
    }
}

- (IBAction)viewBtnTapped:(UIButton *)sender {
    if (self.btnHandler) {
        self.btnHandler(sender.tag - 100);
    }
}

@end
