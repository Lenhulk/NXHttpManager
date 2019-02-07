//
//  AppsCommonConfig.h
//  TestProject
//
//  Created by IMAC on 2017/2/27.
//
//

@import Foundation;

#define appDelegate				((AppDelegate *)[[UIApplication sharedApplication] delegate])

//statusBar
#define StatusBarHeight 20
#define SelectScrollBarHeight 44
//获取运行环境的版本
#define runTimeOSVersion        [UIDevice currentDevice].systemVersion.floatValue

// 判断设备类型(todo: 貌似没什么卵用)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

// 定义弱引用/强引用
#define WeakObj(type) __weak typeof(type) weak##type = type;
#define StrongObj(type) __strong typeof(type) Strong##type = type;

// 颜色快速设置宏
#define UIColorFromRGB(rgbValue) [[UIColor alloc] initWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define UIColorFromRGBA(rgbValue) [[UIColor alloc] initWithRed:((float)((rgbValue & 0xFF000000) >> 16))/255.0 green:((float)((rgbValue & 0xFF0000) >> 8))/255.0 blue:((float)(rgbValue & 0xFF00))/255.0 alpha:((float)(rgbValue & 0xFF))/255.0]

#define CGColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0].CGColor;

// 定义布局常用值
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

// 布局比例宏
#define SizeWidthScale ScreenWidth / 375
#define SizeHeightScale ScreenHeight / 667

#define SizeWidthScale320 ScreenWidth / 320
#define SizeHeightScale320 ScreenHeight / 568

#define SizeWidthScale360 ScreenWidth / 360

//判断是否iphonex
#define kDevice_iPhoneX ( CGSizeEqualToSize(CGSizeMake(375, 812), [[UIScreen mainScreen] bounds].size) ? YES : NO )

//判断是否iPhoneX系列机型
#define kDevice_iPhoneXSeries (ScreenHeight == 812.0f || ScreenHeight == 896.0f)

//iphonex tabbar适配
#define TabbarHeight ( kDevice_iPhoneXSeries ? 83 : 49 )

//iphonex navBar适配
#define NavigationBar_HEIGHT ( kDevice_iPhoneXSeries ? 68 : 44 )

//iphonex statusBar适配
#define iPhoneXstatusOffset (kDevice_iPhoneXSeries ? 24 : 0)

//坐标适配宏
#define scaleX(x) (x)*SizeWidthScale
#define scaleY(y) (y)*SizeHeightScale

#define scaleX320(x) (x)*SizeWidthScale320
#define scaleY320(y) (y)*SizeHeightScale320

#define scaleX360(x) (x)*SizeWidthScale360

//字体适配宏
#define adoptedFont(font) [UIFont systemFontOfSize:(font) * SizeWidthScale]
#define boldAdoptedFont(font) [UIFont boldSystemFontOfSize:(font) * SizeWidthScale]
#define adoptedFontWithName(font, name) [UIFont fontWithName:name size:(font) * SizeWidthScale]

// 沙盒目录文件目录
#define SandboxTempPath NSTemporaryDirectory()
#define SandboxDocumentPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
#define SandboxCachePath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]


//定义网络错误提示语
#define NETWORK_NOT_REACHABLE_MSG       @"暂无网络,请开启网络后再试。"
#define NETWORK_ERROR_MSG               @"网络错误，请稍候再试。"
#define SERVICE_ERROR_MSG               @"服务器有问题，请稍后再试。"
#define HTTP_NO_RESPONSE_ERROR_MSG      @"请求数据失败，请稍后再试（服务器无响应）。"
#define HTTP_JSON_ERROR_MSG             @"请求数据失败，请稍后再试（json格式错误）。"
#define ERRORMESSAGE_ERROR_MSG          @"请求数据失败，请稍后再试。"
#define ERROR_MESSAGE_NO_DATA_FOUND     @"您好，暂时没有找到相关数据！"
#define ERROR_JSESSIONID_INVALID        @"您的登陆已过期，请重新登陆。"
#define LOADING_DATA_MSG                @"正在加载数据，请稍侯..."


#define BundleVersion ([[[NSBundle mainBundle]infoDictionary] valueForKey:@"CFBundleVersion"])
#define ShortBundleVersion ([[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"])



