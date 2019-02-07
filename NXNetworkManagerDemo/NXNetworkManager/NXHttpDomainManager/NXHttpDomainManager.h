//
//  NXDomainManager.h
//  NXNetworkManagerDemo
//
//  Created by Design on 2018/11/7.
//  Copyright © 2018年 Design. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NXHttpDomainMgr [NXHttpDomainManager shareInstance]

NS_ASSUME_NONNULL_BEGIN

/**
 域名管理者，提供项目相关的域名服务
 在应用启动时会自动去获取最新的domain
 配置成功自动设置到Configure的generalServer
 */
@interface NXHttpDomainManager : NSObject

+ (instancetype)shareInstance;

/// 备用域名池加密字符串
- (void)requestbackupDomainPoolUrl;

/// 返回解密后的域名池json
- (NSArray *)getDomainPool;

/// 返回主用
- (NSString *)getMainDomain;



@end

NS_ASSUME_NONNULL_END
