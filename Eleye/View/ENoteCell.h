//
//  ENoteCell.h
//  Eleye
//
//  Created by Sheldon on 15/4/21.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ENoteCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

- (void)updateUIWithNote:(ENoteDO *)note;

@end
