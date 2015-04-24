//
//  EUtility.m
//  Eleye
//
//  Created by sheldon on 15/4/22.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "EUtility.h"

@implementation EUtility

+ (void)addlineOnView:(UIView *)view position:(EViewPosition)position insert:(NSInteger)insert
{
    CALayer *lineLayer = [CALayer layer];
    lineLayer.borderColor = RGBCOLOR(217, 217, 217).CGColor;
    lineLayer.borderWidth = .5;
    
    switch (position) {
        case EViewPositionTop: {
            lineLayer.frame = CGRectMake(insert, 0, CGRectGetWidth(view.frame) - insert * 2, 1);
            break;
        } 
        case EViewPositionLeft: {
            lineLayer.frame = CGRectMake(0, 0, 1, CGRectGetHeight(view.frame));
            break;
        }
        case EViewPositionRight: {
            lineLayer.frame = CGRectMake(CGRectGetWidth(view.frame) - 1, 0, 1, CGRectGetHeight(view.frame));
            break;
        }
        case EViewPositionBottom: {
            lineLayer.frame = CGRectMake(insert, CGRectGetHeight(view.frame) - 1, CGRectGetWidth(view.frame) - insert * 2, 1);
            break;
        }
    }
    
    [view.layer addSublayer:lineLayer];
}

+ (void)addlineOnView:(UIView *)view position:(EViewPosition)position
{
    [[self class] addlineOnView:view position:position insert:0];
}

+ (void)saveContentToFileWithContent:(NSString *)content guid:(NSString *)guid
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *notePath = [libraryDirectory stringByAppendingPathComponent:@"note"];
    BOOL isPathExist = [[NSFileManager defaultManager] fileExistsAtPath:notePath];
    if (isPathExist) {
        
    } else {
        [[NSFileManager defaultManager] createDirectoryAtPath:notePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *path = [notePath stringByAppendingFormat:@"/note%@.html", guid];
    [content writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@end
