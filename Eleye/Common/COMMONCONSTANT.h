//
//  COMMONCONSTANT.h
//  demo
//
//  Created by ZengYun on 5/8/13.
//  Copyright (c) 2013 Gezbox. All rights reserved.
//

#ifndef demo_COMMONCONSTANT_h
#define demo_COMMONCONSTANT_h

#pragma mark - Font 字体
//Font
#define FONT_NAVIGATION_TITILE              [UIFont boldSystemFontOfSize:20]
#define FONT_TABLEVIEW_TEXT                 [UIFont systemFontOfSize:14]
#define FONE_TABBAR_TEXT                    [UIFont systemFontOfSize:12.]

#define SHOWGUIDE                           @"hasShowGuide"

#define UPDATENOTENOTIFICATION              @"UPDATENOTES"
#define UPDATENOTELISTNOTIFICATION          @"UPDATENOTELISTS"

#pragma mark - Evernote - APPKEY

#define EVERNOTECONSUMER_KEY  @"yousurm"
#define EVERNOTECONSUMER_SECRET @"cb61b2f2bbbcb741"
#define YINXIANGCONSUMER_KEY @"yousurm-4843"
#define YINXIANGCONSUMER_SECRET  @"19601b04ea2a0f05"

#define EMAIL @"wheelab7@gmail.com"
#define HOSTNAME  @"host"
#define EVERNOTEHOST @"app.evernote.com"
#define YINXIANGHOST @"app.yinxiang.com"
#define LOCALUPDATEFILE @"LOCALUPDATEFILE"
#define REMOTEUPDATEDTITLE @"REMOTEUPDATEDTITLE"
#define WAITUPLOADFILE @"WAITUPLOADFILE"

#pragma mark - 函数定义
//函数定义
#define RGBCOLOR(r,g,b)                     [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBACOLOR(r,g,b,a)                  [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define FONT(size)                          [UIFont systemFontOfSize:size]
#define FONTBOLD(size)                      [UIFont boldSystemFontOfSize:size]
#define LOCALSTRING(x, ...)                 NSLocalizedString(x, nil)
#define URLWITHSTRING(string)               [NSURL URLWithString:string]

#pragma mark- 入口
//单例
#define IMAGE_CACHE                         [SDImageCache sharedImageCache]
#define NOTIFICATION_CENTER                 [NSNotificationCenter defaultCenter]
#define USER_DEFAULT                        [NSUserDefaults standardUserDefaults]

#pragma mark - Local Path
//应用的某些使用率高的路径
#define APP_DOCUMENT                [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define APP_LIBRARY                 [NSSearchPathForDirectoriesInDomains (NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define APP_CACHES_PATH             [NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#pragma mark - 设备信息
//设备信息
#define iOS_VERSION_5                       ([[[UIDevice currentDevice] systemVersion] integerValue] == 5)
#define iOS_VERSION_6                       ([[[UIDevice currentDevice] systemVersion] integerValue] == 6)
#define IS_4_INCH                           (APP_SCREEN_HEIGHT > 480.0)
#define IS_IPHONE5                          ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define ISPAD                               (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IOS_VERSION                         [[[UIDevice currentDevice] systemVersion] floatValue]
#define CURRENTSYSTEMVERSION                ([[UIDevice currentDevice] systemVersion])
#define CURRENTLANGUAGE                     ([[NSLocale preferredLanguages] objectAtIndex:0])
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
#define APP_SCREEN_WIDTH                    [UIScreen mainScreen].bounds.size.width
#define APP_SCREEN_HEIGHT                   [UIScreen mainScreen].bounds.size.height
#define APP_SCREEN_CONTENT_HEIGHT           ([UIScreen mainScreen].bounds.size.height-20.0)
#define KEYWINDOW                           [UIApplication sharedApplication].keyWindow
#define APP_BUILD_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey]
#define APP_VERSION [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"]
#define APP_DISPLAY_NAME [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]
#define APP_BUNDLEID [[NSBundle mainBundle] bundleIdentifier]
#define APP_UNIQUEID [[[UIDevice currentDevice] identifierForVendor] UUIDString]

//singleton
#define SINGLETON_CLASS(classname) \
\
+ (classname *)shared##classname \
{\
static dispatch_once_t pred = 0; \
__strong static id _shared##classname = nil; \
dispatch_once(&pred,^{ \
_shared##classname = [[self alloc] init]; \
});  \
return _shared##classname; \
}

#endif
