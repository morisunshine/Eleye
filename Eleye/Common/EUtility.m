//
//  EUtility.m
//  Eleye
//
//  Created by sheldon on 15/4/22.
//  Copyright (c) 2015年 wheelab. All rights reserved.
//

#import "EUtility.h"
#include <sys/sysctl.h>
#include <sys/utsname.h>
#import "ENotebookDAO.h"
#import "ENoteDAO.h"

@implementation EUtility

SINGLETON_CLASS(EUtility)

+ (void)addlineOnView:(UIView *)view position:(EViewPosition)position insert:(NSInteger)insert
{
    CALayer *lineLayer = [CALayer layer];
    lineLayer.borderColor = RGBCOLOR(217, 217, 217).CGColor;
    lineLayer.borderWidth = .5;
    
    switch (position) {
        case EViewPositionTop: {
            lineLayer.frame = CGRectMake(insert, 0, APP_SCREEN_WIDTH - insert * 2, 1);
            break;
        } 
        case EViewPositionLeft: {
            lineLayer.frame = CGRectMake(0, 0, 1, CGRectGetHeight(view.frame));
            break;
        }
        case EViewPositionRight: {
            lineLayer.frame = CGRectMake(APP_SCREEN_WIDTH - 1, 0, 1, CGRectGetHeight(view.frame));
            break;
        }
        case EViewPositionBottom: {
            lineLayer.frame = CGRectMake(insert, CGRectGetHeight(view.frame) - 1, APP_SCREEN_WIDTH - insert * 2, 1);
            break;
        }
    }
    
    [view.layer addSublayer:lineLayer];
}

+ (void)addlineOnView:(UIView *)view position:(EViewPosition)position
{
    [[self class] addlineOnView:view position:position insert:0];
}

- (void)saveContentToFileWithContent:(NSString *)content guid:(NSString *)guid
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *notePath = [libraryDirectory stringByAppendingPathComponent:@"note"];
    BOOL isPathExist = [[NSFileManager defaultManager] fileExistsAtPath:notePath];
    if (isPathExist) {
        NSString *userPath = [notePath stringByAppendingFormat:@"/%@", @([ENSession sharedSession].userID)];
        BOOL isUserPathExist = [[NSFileManager defaultManager] fileExistsAtPath:userPath];        
        if (isUserPathExist) {
            NSString *guidPath = [userPath stringByAppendingFormat:@"/%@", guid];
            BOOL isGuidPathExist = [[NSFileManager defaultManager] fileExistsAtPath:guidPath];
            if (!isGuidPathExist) {
                [[NSFileManager defaultManager] createDirectoryAtPath:guidPath withIntermediateDirectories:YES attributes:nil error:nil];
            } 
        } else {
            [[NSFileManager defaultManager] createDirectoryAtPath:userPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    } else {
        [[NSFileManager defaultManager] createDirectoryAtPath:notePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *path = [notePath stringByAppendingFormat:@"/%@/%@/note.html", @([ENSession sharedSession].userID), guid];
    [content writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    dispatch_async(dispatch_queue_create("com.duotin.attribted.html", DISPATCH_QUEUE_SERIAL), ^{
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[content dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        NSString *string = attributedString.string;
        NSString *subString;
        if (200 < string.length) {
            subString = [string substringToIndex:200];
        } else {
            subString = [string substringToIndex:string.length];
        }
        NSString *contentPath = [notePath stringByAppendingFormat:@"/%@/%@/note", @([ENSession sharedSession].userID), guid];
        [subString writeToFile:contentPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        [NOTIFICATION_CENTER postNotificationName:UPDATENOTELISTNOTIFICATION object:nil];
    });
}

+ (NSString *)noteContentWithGuid:(NSString *)guid
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *notePath = [[libraryDirectory stringByAppendingPathComponent:@"note"] stringByAppendingFormat:@"/%@/%@/note", @([ENSession sharedSession].userID), guid];
    NSString *content = [NSString stringWithContentsOfFile:notePath encoding:NSUTF8StringEncoding error:nil];
    
    return content;
}

+ (BOOL)deleteNotePathWithGuid:(NSString *)guid
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *notePath = [libraryDirectory stringByAppendingFormat:@"/note/%@/%@", @([ENSession sharedSession].userID), guid];
    BOOL deleteSuccess = [[NSFileManager defaultManager] removeItemAtPath:notePath error:nil];
    
    return deleteSuccess;
}

+ (NSAttributedString *)stringFromLocalPathWithGuid:(NSString *)guid
{
    NSString *content = [self contentFromLocalPathWithGuid:guid];
    __block NSAttributedString *attributedString;
    dispatch_async(dispatch_queue_create("com.duotin.attribted.html", DISPATCH_QUEUE_SERIAL), ^{
        attributedString = [[NSAttributedString alloc] initWithData:[content dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    });
    
    return attributedString;
}

+ (NSString *)contentFromLocalPathWithGuid:(NSString *)guid
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *notePath = [[libraryDirectory stringByAppendingPathComponent:@"note"] stringByAppendingFormat:@"/%@/%@/note.html", @([ENSession sharedSession].userID), guid];
    NSString *content = [NSString stringWithContentsOfFile:notePath encoding:NSUTF8StringEncoding error:nil];
    
    return content;
}

+ (NSString *)platformString
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad mini 2G (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad mini 2G (Cellular)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    
    return platform;
}

+ (BOOL)clearDataBase
{
    BOOL deleteAllNoteBooks = [[ENotebookDAO sharedENotebookDAO] deleteAllNoteBooks];
    BOOL deleteAllNotes = [[ENoteDAO sharedENoteDAO] deleteAllNotes];
    
    BOOL deleteSuccess = NO;
    
    if (deleteAllNotes && deleteAllNoteBooks) {
        deleteSuccess = YES;
    }
    return deleteSuccess;
}

+ (void)showAutoHintTips:(NSString *)string
{
    UIView *view = [UIApplication sharedApplication].keyWindow;
    static BOOL hasShowTips;
    if(hasShowTips) return;
    
    hasShowTips = YES;
    
    CGFloat posY = floor(CGRectGetHeight(view.bounds)/2)-100;
    
    UIFont *font = [UIFont boldSystemFontOfSize:16];
    
    UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 100)];
    tipView.layer.cornerRadius = 10;
    tipView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    tipView.userInteractionEnabled = NO;
    tipView.layer.opacity = 0;
    
    UILabel *stringLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(tipView.bounds)-20, 20)];
    stringLabel.textColor = [UIColor whiteColor];
    stringLabel.backgroundColor = [UIColor clearColor];
    stringLabel.adjustsFontSizeToFitWidth = YES;
    stringLabel.textAlignment = NSTextAlignmentCenter;
    stringLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    stringLabel.font = font;
    //    stringLabel.numberOfLines = 2;
    stringLabel.numberOfLines = 0;
    stringLabel.text = string;
    [stringLabel sizeToFit];
    stringLabel.width = tipView.width-20;
    stringLabel.shadowColor = [UIColor blackColor];
    stringLabel.shadowOffset = CGSizeMake(0, -1);
    [tipView addSubview:stringLabel];
    
    tipView.height = stringLabel.height + 20;
    
    if(![tipView isDescendantOfView:view]) {
        tipView.layer.opacity = 0;
        [view addSubview:tipView];
    }
    
    if(tipView.layer.opacity != 1) {
        
        posY+=(CGRectGetHeight(tipView.bounds)/2);
        tipView.center = CGPointMake(CGRectGetWidth(tipView.superview.bounds)/2, posY);
        
        tipView.layer.transform = CATransform3DScale(CATransform3DMakeTranslation(0, 0, 0), 1.3, 1.3, 1);
        tipView.layer.opacity = 0.3;
        
        [UIView animateWithDuration:0.15
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut
                         animations:^{
                             tipView.layer.transform = CATransform3DScale(CATransform3DMakeTranslation(0, 0, 0), 1, 1, 1);
                             tipView.layer.opacity = 1;
                         }completion:NULL];
    }
    
    [UIView animateWithDuration:0.15
                          delay:2.5
                        options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         tipView.layer.transform = CATransform3DScale(CATransform3DMakeTranslation(0, 0, 0), 0.8, 0.8, 1.0);
                         tipView.layer.opacity = 0;
                     }completion:^(BOOL finished){
                         if(tipView.layer.opacity == 0) [tipView removeFromSuperview];
                         hasShowTips = NO;
                     }];
}

@end
