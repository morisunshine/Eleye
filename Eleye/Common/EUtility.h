//
//  EUtility.h
//  Eleye
//
//  Created by sheldon on 15/4/22.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, EViewPosition) {
    EViewPositionTop,
    EViewPositionLeft,
    EViewPositionRight,
    EViewPositionBottom
};

@interface UIButton (backgroundColorState)

- (void)setBackgoundColor:(UIColor *)color forState:(UIControlState)state;

@end

@interface EUtility : NSObject

- (void)saveContentToFileWithContent:(NSString *)content guid:(NSString *)guid;

+ (instancetype)sharedEUtility;

+ (void)addlineOnView:(UIView *)view cellHeight:(NSInteger)cellHeight;

+ (void)addlineOnView:(UIView *)view position:(EViewPosition)position insert:(NSInteger)insert;

+ (void)addlineOnView:(UIView *)view position:(EViewPosition)position;

+ (BOOL)deleteNotePathWithGuid:(NSString *)guid;

+ (NSString *)noteHtmlFromLocalPathWithGuid:(NSString *)guid;

+ (NSString *)noteContentWithGuid:(NSString *)guid;

+ (NSString *)platformString;

+ (void)clearDataBase;

+ (void)renewDataBase;

+ (void)showAutoHintTips:(NSString *)string;

+ (BOOL)createFloderWithPath:(NSString *)path;

+ (void)setSafeValue:(id)value key:(NSString *)key fileName:(NSString *)fileName;

+ (id)valueWithKey:(NSString *)key fileName:(NSString *)fileName;

+ (void)removeValueWithKey:(NSString *)key fileName:(NSString *)fileName;

+ (void)saveDataBaseResources:(NSArray *)resources withNoteGuid:(NSString *)noteGuid;

@end
