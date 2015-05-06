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

#pragma mark - 默认图片
//默认图片
#define DEFAULT_IMAGE_REPLACE               @"defaultImage.png"
#define DEFAULT_IMAGE_BUTTON_BACK_NORMAL    @"button_back_normal.png"
#define DEFAULT_IMAGE_BUTTON_BACK_TAPPED    @"button_back_tapped.png"
#define DEFAULT_IMAGE_NAVIGATION_BAR        @"navigationbar.png"

#pragma mark - 第三方Oauth的app id和app key
//第三方Oauth的app id和app key
#define OAUTH_DOUBAN_APPKEY                 @"0c183af4c0928a4d2448b0de41b79ee7"
#define OAUTH_DOUBAN_APPSECRET              @"4f46b142c32b1d76"
#define OAUTH_SINA_APPID                    @"3135285468"
#define OAUTH_SINA_SECRET                   @"9c3dc5c796a39dbc046d2adbf0003e6b"
#define OAUTH_WEIXIN_APPID                  @"wxec2c1e346938f71f"
#define OAUTH_WEIXIN_APPKEY                 @"4277876c726f77bd4914b29cb9065111"
#define OAUTH_TAOBAO_APPKEY                 @"21499475"
#define OAUTH_TAOBAO_SECRET                 @"bc3fa5e643d1f0d87aa75194f740bc8d"
#define OAUTH_RENREN_APPID                  @"fa3aae03b5f64794a4c30c24353361ef"
#define OAUTH_RENREN_APPSECRET              @"99d4d7c498d74def9e395378896f0eae"
#define OAUTH_TWITTER_APPKEY                @"X8LbRwk5B91cTiwPDf1g"
#define OAUTH_TWITTER_APPSECRET             @"UTy6C4zmHZ7VqCBpn8wd3FeV1ORQrep0D55DFOk"
#define OAUTH_FACEBOOK_APPID                @"224466694326390"
#define OAUTH_FACEBOOK_APPSECRET            @"20ee82ab75f019748934d5d6e10fa786"
#define OAUTH_QQ_APPKEY                     @"100289163"

#pragma mark - View Tag
//view TAG
#define TAG_VIEW_INDICATOR                  10000
#define TAG_VIEW_LOADING_BLACKBACK          10001

#pragma mark - NOTIFICATION 编号
//NOTIFICATION编号
#define NOTIFICATION_UPLOADPROGRESS         @"uploadImageProgress"


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
#define USER_DEFAULT                        [GVUserDefaults standardUserDefaults]

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
