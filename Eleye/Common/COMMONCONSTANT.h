//
//  COMMONCONSTANT.h
//  demo
//
//  Created by ZengYun on 5/8/13.
//  Copyright (c) 2013 Gezbox. All rights reserved.
//

#ifndef demo_COMMONCONSTANT_h
#define demo_COMMONCONSTANT_h

#ifndef NEED_OUTPUT_LOG
#ifdef DEBUG
#define NEED_OUTPUT_LOG             1
#define Is_CanSwitchServer          1
#else
#define NEED_OUTPUT_LOG             0
#define Is_CanSwitchServer          0
#endif
#endif

#pragma mark - Color 颜色
//Color
#define COLOR_CLEAR                         [UIColor clearColor];
#define COLOR_BG_APP                        RGBCOLOR(242, 242, 242)
#define COLOR_BG_REPLACEIMAGE               RGBCOLOR(220,220,220)
#define COLOR_SHADOW_APP                    RGBACOLOR(0, 0, 0, 0.35f)
#define COLOR_SHADOW_NAVTITLE               RGBCOLOR(65,130,0)
#define COLOR_TEXT_BLACK                    RGBCOLOR(58, 58, 58)
#define COLOR_TEXT_CLEARBLACK               RGBCOLOR(78, 78, 71)
#define COLOR_TEXT_CLEARGRAY                RGBCOLOR(163, 162, 157)
#define COLOR_TEXT_DARKBLUE                 RGBCOLOR(0, 163, 222)
#define COLOR_TEXT_NAVIGATION_TITLE         [UIColor whiteColor]
#define COLOR_LINE_GRAY                     RGBCOLOR(220, 219, 212)
#define COLOR_LINK_BLUE                     RGBCOLOR(66, 175, 212)

#pragma mark - Font 字体
//Font
#define FONT_NAVIGATION_TITILE              [UIFont boldSystemFontOfSize:20]
#define FONT_TABLEVIEW_TEXT                 [UIFont systemFontOfSize:14]
#define FONE_TABBAR_TEXT                    [UIFont systemFontOfSize:12.]

#pragma mark - Offset 
//Offset
#define OFFSET_SHADOW_NAVIGATION_TITLE      CGSizeMake(0, 1)

#define SHOWGUIDE                           @"hasShowGuide"

#define UPDATENOTENOTIFICATION              @"UPDATENOTES"
#define UPDATENOTELISTNOTIFICATION          @"UPDATENOTELISTS"

#pragma mark - 默认图片
//默认图片
#define DEFAULT_IMAGE_REPLACE               @"defaultImage.png"
#define DEFAULT_IMAGE_BUTTON_BACK_NORMAL    @"button_back_normal.png"
#define DEFAULT_IMAGE_BUTTON_BACK_TAPPED    @"button_back_tapped.png"
#define DEFAULT_IMAGE_NAVIGATION_BAR        @"navigationbar.png"

#pragma mark - Evernote - APPKEY

#define EVERNOTECONSUMER_KEY  @"yousurm"
#define EVERNOTECONSUMER_SECRET @"cb61b2f2bbbcb741"
#define YINXIANGCONSUMER_KEY @"yousurm-4843"
#define YINXIANGCONSUMER_SECRET  @"19601b04ea2a0f05"

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


#pragma mark - app信息

#pragma mark - Log
//Log
#if NEED_OUTPUT_LOG
#define GLog(xx, ...)                       NSLog(xx, ##__VA_ARGS__)
#define GBLog(xx, ...)                      NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#define GBLogRect(rect) \
GBLog(@"%s x=%f, y=%f, w=%f, h=%f", #rect, rect.origin.x, rect.origin.y, \
rect.size.width, rect.size.height)

#define GBLogPoint(pt) \
GBLog(@"%s x=%f, y=%f", #pt, pt.x, pt.y)

#define GBLogSize(size) \
GBLog(@"%s w=%f, h=%f", #size, size.width, size.height)

#define GBLogColor(_COLOR) \
GBLog(@"%s h=%f, s=%f, v=%f", #_COLOR, _COLOR.hue, _COLOR.saturation, _COLOR.value)

#define GBLogSuperViews(_VIEW) \
{ for (UIView* view = _VIEW; view; view = view.superview) { GBLog(@"%@", view); } }

#define GBLogSubViews(_VIEW) \
{ for (UIView* view in [_VIEW subviews]) { GBLog(@"%@", view); } }
#else
#define GLog(xx, ...)   ((void)0)
#define GBLog(xx, ...)  ((void)0)
#define GBLogSize(size) ((void)0)
#endif


#endif
