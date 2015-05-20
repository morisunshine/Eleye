//
//  EResourceDAO.h
//  Eleye
//
//  Created by sheldon on 15/5/19.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "EBaseDAO.h"

@interface EResourceDAO : EBaseDAO

+ (instancetype)sharedEResourceDAO;

- (BOOL)deleteResourcesWithNoteGuid:(NSString *)noteGuid;

- (NSArray *)resourcesWithNoteGuid:(NSString *)noteGuid;

@end
