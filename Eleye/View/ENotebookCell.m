//
//  ENotebookCell.m
//  Eleye
//
//  Created by Sheldon on 15/4/22.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "ENotebookCell.h"

static NSInteger kCellHeight = 49;

@implementation ENotebookCell

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

- (void)updateUIWithNotebook:(ENoteBookDO *)noteBook
{
    self.titleLabel.text = noteBook.name;
    NSString *text;
    if (noteBook.count) {
        text = [NSString stringWithFormat:@"%@ notes", noteBook.count];
    } else {
        text = @"0 notes";
    }
    
    self.countLabel.text = text;
    [EUtility addlineOnView:self cellHeight:kCellHeight];
}

@end
