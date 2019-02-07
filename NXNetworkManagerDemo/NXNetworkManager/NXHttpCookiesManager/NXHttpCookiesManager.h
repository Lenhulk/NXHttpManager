//
//  NXHttpCookiesManager.h
//  NXNetworkManagerDemo
//
//  Created by Design on 2018/11/7.
//  Copyright © 2018年 Design. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kUserDefaultCookieName(name) [NSString stringWithFormat:@"%@", name]

NS_ASSUME_NONNULL_BEGIN


/**
 Cookies管理者
 通过类方法调用
 */
@interface NXHttpCookiesManager : NSObject

/**
在请求时，NSURLSession 和 NSURLConnection 会自动帮我们管理 cookie 的，但并不完善。AFNetworking 默认设置了 NSURLRequest 的 HTTPShouldHandleCookies 属性为 YES。
 
如果服务器设置了 Cookie 失效时间 expiresDate，并且 sessionOnly 为 FALSE，Cookie 就会被持久化到文件中，下次启动app会自动加载沙盒中的 Cookies。如果 sessionOnly 为 TRUE 或者 expiresDate 为空，则不会自动持久化到沙盒。
只要服务器在请求返回时带了 cookie，NSHTTPCookieStorage 就会自动帮我们管理 cookie。
 
手动设置的 Cookie 不会被 NSHTTPCookieStorage 自动持久化到沙盒。
 
不能简单地依赖 NSHTTPCookieStorage 的 setCookie: 方法来做 cookie 的存储，因为在执行 setCookie：时， cookie 并不是马上就更新了。参考： NSHTTPCookieStorage state not saved on app exit. Any definitive knowledge/documentation out there?
 
cookie 的 httpOnly 属性是用来设置 cookie 是否能通过 js 去访问。默认情况下，cookie不会带httpOnly选项(即为空)，所以默认情况下，客户端是可以通过 js 代码去访问（包括读取、修改、删除等）这个cookie的。当cookie带 httpOnly 选项时，客户端则无法通过js代码去访问（包括读取、修改、删除等）这个cookie。
 
 NSHTTPCookieStorage此类最有趣和最有用的功能是OS（iOS）会自动将cookie放入网络请求中，前提是cookie与请求的URL之间存在域匹配。假设cookie有一个域“.example.com”，请求的URL是www.test.example.com，那么cookie会自动添加到请求中而不需要任何额外的代码。
*/

/**
 *  通过 url 获取 cookie
 */
+ (NSDictionary *)cookieForURLString:(NSString *)urlString;

/**
 *  通过 url 删除 cookie
 */
+ (void)deleteCookieWithURLString:(NSString *)urlString;

/**
 *  查看所有cookies
 */
+ (NSArray<NSHTTPCookie *> *)allHTTPCookies;

/**
 *  清空所有 cookie
 */
+ (void)cleanAllHTTPCookies;

/**
 *  设置一个默认cookie
 */
+ (void)setupDefaultCookieForName:(NSString *)name value:(NSString *)value Domain:(nullable NSString *)domain path:(nullable NSString *)path;

/**
 *  通过网络请求保存一个cookie
 */
+ (void)saveCookie:(nullable NSString *)cookieName withHttpResponse:(NSURLResponse *)response;


@end

NS_ASSUME_NONNULL_END
