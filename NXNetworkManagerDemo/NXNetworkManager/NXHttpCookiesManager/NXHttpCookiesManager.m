//
//  NXHttpCookiesManager.m
//  NXNetworkManagerDemo
//
//  Created by Design on 2018/11/7.
//  Copyright © 2018年 Design. All rights reserved.
//

#import "NXHttpCookiesManager.h"

@implementation NXHttpCookiesManager

#pragma mark - 处理已存在的cookie

+ (NSDictionary *)cookieForURLString:(NSString *)urlString{
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    cookieStorage.cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways; //安全性存疑
    NSArray *cookiesArr = [cookieStorage cookiesForURL:[NSURL URLWithString:urlString]];
    NSDictionary *cookiesDict = @{};
    if (cookiesArr) {
        cookiesDict = [NSHTTPCookie requestHeaderFieldsWithCookies:cookiesArr];
    }
    return cookiesDict;
}

+ (void)deleteCookieWithURLString:(NSString *)urlString{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookieStorageArr = [cookieStorage cookiesForURL:[NSURL URLWithString:urlString]];
    for (NSHTTPCookie *cookie in cookieStorageArr) {
        [cookieStorage deleteCookie:cookie];
    }
}

+ (NSArray<NSHTTPCookie *> *)allHTTPCookies{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    return [cookieStorage cookies];
}

+ (void)cleanAllHTTPCookies{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieStorage cookies]) {
        [cookieStorage deleteCookie:cookie];
    }
}

#pragma mark - 生成新的cookie

// cookie有四个必需参数，名称，域，值和路径。但根据RFC文档，Domain可以是可选的，这意味着Cookie可能有时会有一个空域
+ (void)setupDefaultCookieForName:(NSString *)name value:(NSString *)value Domain:(nullable NSString *)domain path:(nullable NSString *)path{
    
    NSMutableDictionary* cookieProperties = [NSMutableDictionary dictionary];
    
    //set rest of the properties   eg:
//    [cookieProperties setObject:@"cookie12345ytehdsfksdf" forKey:NSHTTPCookieValue];
//    [cookieProperties setObject:@".example.com" forKey:NSHTTPCookieDomain];
//    [cookieProperties setObject:@"MyCookie" forKey:NSHTTPCookieName];
//    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties setObject:path?path:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties setObject:domain forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:value forKey:NSHTTPCookieValue];
    [cookieProperties setObject:name forKey:NSHTTPCookieName];
    
    //create a NSDate for some future time
    NSDate* expiryDate = [[NSDate date] dateByAddingTimeInterval:2629743];
    [cookieProperties setObject:expiryDate forKey:NSHTTPCookieExpires];
    [cookieProperties setObject:@"TRUE" forKey:NSHTTPCookieSecure];
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
}

#pragma mark - 保存一个cookie

+ (void)saveCookie:(nullable NSString *)cookieName withHttpResponse:(NSURLResponse *)response{
    if (nil == cookieName) {
        return;
    }
    
    // 获取到response对应的cookies
    NSDictionary *headerFields = [(NSHTTPURLResponse *)response allHeaderFields];
    if (![headerFields.allKeys containsObject:@"Set-Cookie"]) {
        return ;
    }

    // 保存一条cookie
    NSArray <NSHTTPCookie *> *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:headerFields forURL:response.URL];
    NXLog(@"\n 可设置的 Set-Cookie: %@\n", cookies);
    NSHTTPCookie *cookie = [NSHTTPCookie new];
    if ([@"" isEqualToString:cookieName]) {
        cookie = cookies.firstObject;
    } else {
        for (NSHTTPCookie *aCookie in cookies) {
            if ([aCookie.name isEqualToString:cookieName]) {
                cookie = aCookie;
            }
        }
    }
    // 保存到系统配置
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    // 自己做持久化存储
    [[NSUserDefaults standardUserDefaults] setObject:cookie.properties forKey:kUserDefaultCookieName(cookieName)];
    
}


@end
