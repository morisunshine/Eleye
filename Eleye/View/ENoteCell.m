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
    CGFloat titleWidth = [self widthOfString:note.title withFont:self.titleLabel.font];
    if (titleWidth < 287) {
        self.titleLabel.numberOfLines = 1;
        self.contentLabel.numberOfLines = 2;
    } else {
        self.titleLabel.numberOfLines = 2;
        self.contentLabel.numberOfLines = 1;
    }
    
    [EUtility addlineOnView:self cellHeight:kCellHeight];
}

- (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

@end
