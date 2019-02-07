//
//  NXNetworkReachability.m
//  NXNetworkManagerDemo
//
//  Created by Lenhulk on 2018/11/9.
//  Copyright © 2018年 Design. All rights reserved.
//

#import "NXNetworkReachability.h"
#import <arpa/inet.h>

@implementation NXNetworkReachability

+ (void)load{
    [[self sharedManager] startMonitoring];
}

+ (void)monitoringNetworkStatusChange:(statusChangedBlock)change{
    [[self sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                change(status, @"无法连接到网络");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                change(status, @"当前使用手机网络");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                change(status, @"已连接到Wifi网络");
                break;
            default:
                change(status, @"未知网络");
                break;
        }
    }];
}

/// 服务器可达返回true
+ (BOOL)socketReachabilityTest {

    // 客户端 AF_INET:ipv4  SOCK_STREAM:TCP链接
    int socketNumber = socket(AF_INET, SOCK_STREAM, 0);
    // 配置服务器端套接字
    struct sockaddr_in serverAddress;
    // 设置服务器ipv4
    serverAddress.sin_family = AF_INET;
    // 百度的ip
    serverAddress.sin_addr.s_addr = inet_addr("202.108.22.5");
    // 设置端口号，HTTP默认80端口
    serverAddress.sin_port = htons(80);
    if (connect(socketNumber, (const struct sockaddr *)&serverAddress, sizeof(serverAddress)) == 0) {
        close(socketNumber);
        return true;
    }
    close(socketNumber);;
    return false;
}

+ (BOOL)checkNetworkValid {
    
    __block BOOL canUse = NO;
    
    NSString *urlString = @"http://captive.apple.com/";
    
    // 使用信号量实现NSURLSession同步请求
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSString* result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        //解析html页面
        NSString *htmlString = [self filterHTML:result];
        //除掉换行符
        NSString *resultString = [htmlString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        if ([resultString isEqualToString:@"SuccessSuccess"]) {
            canUse = YES;
            NXLog(@"手机所连接的网络是可以访问互联网的: %d",canUse);
            
        }else {
            canUse = NO;
            NXLog(@"手机无法访问互联网: %d",canUse);
        }
        dispatch_semaphore_signal(semaphore);
    }] resume];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return canUse;
}

+ (NSString *)filterHTML:(NSString *)html {
    
    NSScanner *theScanner;
    NSString *text = nil;
    
    theScanner = [NSScanner scannerWithString:html];
    
    while ([theScanner isAtEnd] == NO) {
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ;
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
                [NSString stringWithFormat:@"%@>", text]
                                               withString:@""];
    }
    return html;
}



@end
