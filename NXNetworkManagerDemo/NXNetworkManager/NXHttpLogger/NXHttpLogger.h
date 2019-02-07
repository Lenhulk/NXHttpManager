//
//  NXHttpLogger.h
//  NXNetworkManagerDemo
//
//  Created by Design on 2018/11/8.
//  Copyright © 2018年 Design. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NXHttpRequest;

/**
 打印网络的请求及响应等系列信息，用于调试
 */
@interface NXHttpLogger : NSObject

/**
 输出签名 NOT USE
 */
+ (void)logSignInfoWithString:(NSString *)sign;

/**
 打印网络错误
 */
+ (void)logDebugInfoWhenNetworkFail;

/**
 打印请求 及 响应 相关信息
 */
+ (void)logDebugInfoWithRequest:(NXHttpRequest *)request Task:(NSURLSessionTask *)sessionTask ResponseData:(id)data duration:(int)interval error:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
