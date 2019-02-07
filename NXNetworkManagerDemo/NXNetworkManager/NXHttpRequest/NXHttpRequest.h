//
//  NXHttpRequest.h
//  NXNetworkManagerDemo
//
//  Created by Design on 2018/11/7.
//  Copyright © 2018年 Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXHttpConstant.h"

NS_ASSUME_NONNULL_BEGIN
@class NXHttpConfigure, NXUploadFormData;

/**
 * 网络请求参数配置类
 * 某些参数默认取自HttpConfigure
 */
@interface NXHttpRequest : NSObject

/**
 应用服务器，网络请求的 Base URL （eg: http://ios.12306.com )
 如果未设置该参数，默认会取HttpConfigure的generalServer属性
 如果设置了该参数，generalServer失效
 */
@property (nonatomic, copy) NSString *baseURL;

/// 请求路径，会自动拼接在baseURL或generalServer之后 （eg: /login）
@property (nonatomic, copy) NSString *requestURL;

/*
 HTTP请求头，可在 NXHttpConfigure 中设置默认内容
 如果设置了该参数，则会添加或者覆盖到默认内容下后发送请求
 */
@property (nonatomic, strong) NSDictionary *requestHeader;

/**
 如果设置了，则会为当前请求保存对应cookieName的cookie
 如果设置为@""，则默认保存第一个cookie（不检索cookieName）
 如果不设置，默认为空，则不会保存
 */
@property (nonatomic, readwrite) NSString *saveCookieName;

/// 是否加密请求参数，默认为 NO
 //TODO: 未实现
@property (nonatomic, assign) BOOL isNeedEncrypt;

/// 请求参数，默认为 @{}
@property (nonatomic, strong) NSDictionary *params;

/// 网络请求方式 默认为 Normal
@property (nonatomic, assign) NXRequestType requestType;

/// HTTP请求方式 默认为 Post
@property (nonatomic, assign) NXHttpMethodType requestMethod;

/// 请求方式string 不要手动修改
@property (nonatomic, copy, readonly) NSString *requestTypeName;
/// 请求方式string 不要手动修改
@property (nonatomic, copy, readonly) NSString *requestMethodName;

/// 请求超时时间 默认为 30s
@property (nonatomic, assign) NSTimeInterval reqeustTimeoutInterval;

/// 当网络请求方式为upload时需要的数据 上传文件相关数组
@property (nonatomic, strong, nullable, readonly) NSMutableArray<NXUploadFormData *> *uploadFormDatas;

/// 当网络请求方式为download时需要的数据 存储到本地的路径
@property (nonatomic, copy, nullable) NSString *downloadSavePath;

/// 存储到本地的完整文件路径 自动返回
@property (nonatomic, copy, nullable, readonly) NSURL *downloadFileSavedFullPath;

/// 调试信息：是否仅在控制台输出这个request信息 优先级最高 需要时设置为YES
@property (nonatomic, assign, getter=isLogDebugMsg) BOOL logDebugMsg;

/// 重试次数（暂时不支持Chain/Group/Upload/Download请求）
@property (nonatomic, assign) NSInteger retryCount;


///**
// 生成请求类，不可手动调用！！
//
// @return NSURLRequest
// */
- (NSURLRequest *)generateRequest;

/**
 添加需要上传的文件信息
 */
- (void)addFormDataWithName:(NSString *)name fileData:(NSData *)fileData;
- (void)addFormDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileData:(NSData *)fileData;
- (void)addFormDataWithName:(NSString *)name fileURL:(NSURL *)fileURL;
- (void)addFormDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileURL:(NSURL *)fileURL;


@end

NS_ASSUME_NONNULL_END
