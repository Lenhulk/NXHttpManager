//
//  HKHttpConfigure.h
//  NXNetworkManagerDemo
//
//  Created by Design on 2018/11/8.
//  Copyright © 2018年 Design. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NXHttpConfig [NXHttpConfigure shareInstance]

NS_ASSUME_NONNULL_BEGIN

/**
 网络请求的参数配置类
 包括服务器默认地址，公共参数，公共请求头
 在HttpRequest前可设置
 */
@interface NXHttpConfigure : NSObject

/**
 默认服务器地址，与DomainManager，PingManager配合使用
 （可不使用，如使用应该在网络请求前设置）
 */
@property (nonatomic, copy, nonnull) NSString *generalServer;

/**
 公共参数
 （可不使用，如使用应该在网络请求前设置）
 */
@property (nullable, nonatomic, strong) NSDictionary<NSString *, id> *generalParameters;

/**
 公共请求头 必须与后端沟通 默认 @{}
 （可不使用，如使用应该在运行项目前设置）
 */
@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSString *> *generalHeaders;

/**
 是否为调试模式 会输出“网络请求日志”
 （默认在DEBUG模式都为YES，即有错误时（OnlyError）才打印，可手动设置为NO）
 */
@property (nonatomic, readwrite) BOOL enableDebug;
@property (nonatomic, readwrite) BOOL enableDebugOnlyError;

/// 网络成功验证码  必须与后端沟通（可不使用，运行项目前设置）
//@property (nonnull, nonatomic, copy, readonly)NSString *respondeSuccessCode;

/**
 callback执行的线程
 （可不使用，项目中默认为主线程）
 */
@property (nonatomic, strong, nullable) dispatch_queue_t callbackQueue;



+ (_Nonnull instancetype)shareInstance;

/**
 添加单条公共请求参数
 */
+ (void)addGeneralParameterValue:(NSString * _Nonnull)value forKey:(id _Nonnull)key;

/**
 移除请求参数
 */
+ (void)removeGeneralParameterForKey:(NSString * _Nonnull)key;

/**
 添加单条公共请求头
 */
+ (void)addGeneralHeaderValue:(nullable NSString *)value forField:(NSString *)field;

@end

NS_ASSUME_NONNULL_END
