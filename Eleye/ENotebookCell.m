//
//  ENotebookCell.m
//  Eleye
//
//  Created by Sheldon on 15/4/22.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "ENotebookCell.h"

@implementation ENotebookCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateUIWithNotebook:(ENoteBookDO *)noteBook
{
    self.titleLabel.text = noteBook.name;
    if (noteBook.count) {
        self.countLabel.text = [NSString stringWithFormat:@"%@ notes", noteBook.count];
    }
}

@end
