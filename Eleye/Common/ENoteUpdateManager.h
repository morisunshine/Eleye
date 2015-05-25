//
//  ENoteUpdateManager.h
//  Eleye
//
//  Created by sheldon on 15/5/25.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ENoteUpdateManager : NSObject

+ (instancetype)sharedENoteUpdateManager;

- (void)checkUnUploadNotes;

- (void)addUploadNoteWithGuid:(NSString *)guid;

@end
