//
//  ENotebookCell.h
//  Eleye
//
//  Created by Sheldon on 15/4/22.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ENotebookCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

- (void)updateUIWithNotebook:(ENoteBookDO *)noteBook;

@end
