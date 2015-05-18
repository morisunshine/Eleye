//
//  ENoteDAO.h
//  Eleye
//
//  Created by sheldon on 15/4/22.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "EBaseDAO.h"

@interface ENoteDAO : EBaseDAO

+ (instancetype)sharedENoteDAO;

- (NSArray *)notesWithNotebookGuid:(NSString *)notebookGuid;

- (ENoteDO *)noteWithGuid:(NSString *)noteGuid;

- (BOOL)deleteAllNotes;

- (BOOL)deleteNoteWithGuid:(NSString *)guid;

@end
