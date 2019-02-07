//
//  NXHttpResponse.h
//  NXNetworkManagerDemo
//
//  Created by Design on 2018/11/7.
//  Copyright © 2018年 Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXHttpConstant.h"

/**
 网络响应类
 */
@interface NXHttpResponse : NSObject

/// 原responseObject数据
@property (nullable, nonatomic, strong, readonly) NSData *rawData;
/// 返回可使用的数据 数据类型可能为【字典 / 数组 / 字符串】，如果失败默认为nil
@property (nullable, nonatomic, strong, readonly) id content;
/// 网络状态码 （由服务器返回，用于验证，如有网络错误则是错误码NSURLError）
@property (nonatomic, assign, readonly) NSInteger statueCode NS_UNAVAILABLE;
/// 网络请求对象
@property (nonnull, nonatomic, strong, readonly) NSURLRequest *request;
/// 网络请求对象唯一标示ID
@property (nonatomic, assign, readonly) NSInteger requestId;
/// 请求头
@property (nonnull, nonatomic, strong, readonly) NSDictionary *requestHeader;
/// 响应头
@property (nonnull, nonatomic, strong, readonly) NSDictionary *responseHeader;
/// 错误信息
@property (nullable, nonatomic, strong, readonly) NSError *error;
/// 请求状态 0=失败 1=成功 （根据是否有error对象）
@property (nonatomic, assign, readonly) NXHttpResponseStatus status;


/**
 无网络时，创建一个Response对象
 无需手动创建

 @param request NSURLRequest系统请求对象
 @param error 网络请求错误信息
 @return 返回NXHttpResponse对象
 */
- (nonnull instancetype)initWithRequest:(nonnull NSURLRequest *)request
                                  error:(nullable NSError *)error;


/**
 请求成功时，创建一个Response对象
 无需手动创建

 @param task 网络请求任务对象
 @param rspData 请求返回的rawData
 @param error 网络请求错误信息
 @return 返回NXHttpResponse对象
 */
- (nonnull instancetype)initWithSessionTask:(nonnull NSURLSessionTask *)task
                                       data:(nullable id)rspData
                                      error:(nullable NSError *)error;



@end

