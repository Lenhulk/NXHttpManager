//
//  HKHttpConfigure.m
//  NXNetworkManagerDemo
//
//  Created by Design on 2018/11/8.
//  Copyright © 2018年 Design. All rights reserved.
//

#import "NXHttpConfigure.h"
@interface NXHttpConfigure()
@property (nonnull, nonatomic, copy, readwrite)NSString *respondeSuccessCode;
@end

@implementation NXHttpConfigure

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    static NXHttpConfigure *_configure = nil;
    dispatch_once(&onceToken, ^{
        _configure = [[NXHttpConfigure alloc] init];
#ifdef DEBUG
        _configure.enableDebug = YES;
        _configure.enableDebugOnlyError = YES;
#else
        _configure.enableDebug = NO;
        _configure.enableDebugOnlyError = YES;
#endif
    });
    return _configure;
}


#pragma mark - interface
/**
 添加公共请求参数
 */
+ (void)addGeneralParameterValue:(NSString * _Nonnull)value forKey:(id _Nonnull)key {
    NXHttpConfigure *manager = [NXHttpConfigure shareInstance];
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] init];
    mDict[key] = value;
    [mDict addEntriesFromDictionary:manager.generalParameters];
    manager.generalParameters = mDict.copy;
}

/**
 移除请求参数
 */
+ (void)removeGeneralParameterForKey:(NSString * _Nonnull)key {
    NXHttpConfigure *manager = [NXHttpConfigure shareInstance];
    NSMutableDictionary *mDict = manager.generalParameters.mutableCopy;
    [mDict removeObjectForKey:key];
    manager.generalParameters = mDict.copy;
}

+ (void)addGeneralHeaderValue:(NSString *)value forField:(NSString *)field {
    //TODO: -
}

#pragma mark - 运行项目前配置的信息

//- (NSString *)respondeSuccessCode{
//    if (!_respondeSuccessCode) {
//        _respondeSuccessCode = @"200";
//    }
//    return _respondeSuccessCode;
//}

- (NSDictionary<NSString *,NSString *> *)generalHeaders{
#warning 需要与后端协议
    return @{
             @"User-Agent" : @"iPhone",
             //             @"Charset" : @"UTF-8",
//             @"Accept-Encoding" : @"gzip"
             };
}


@end
