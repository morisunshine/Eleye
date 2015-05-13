//
//  ENotebookDAO.h
//  Eleye
//
//  Created by sheldon on 15/4/22.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "EBaseDAO.h"

@interface ENotebookDAO : EBaseDAO

+ (instancetype)sharedENotebookDAO;

- (NSArray *)notebooks;

- (BOOL)deleteAllNoteBooks;

- (BOOL)deleteNoteWithGuid:(NSString *)guid;

@end
