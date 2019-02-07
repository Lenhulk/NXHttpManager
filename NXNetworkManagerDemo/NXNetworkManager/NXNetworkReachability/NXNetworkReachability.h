//
//  NXNetworkReachability.h
//  NXNetworkManagerDemo
//
//  Created by Lenhulk on 2018/11/9.
//  Copyright © 2018年 Design. All rights reserved.
//

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworkReachabilityManager.h>
#else
#import "AFNetworkReachabilityManager.h"
#endif

/**
 网络状况监测类
 不要手动实现单例
 继承自AFNetworkReachabilityManager
 默认开启监听
  */
@interface NXNetworkReachability : AFNetworkReachabilityManager

typedef void(^statusChangedBlock)(AFNetworkReachabilityStatus status, NSString *statusString);


/**
 在某个控制器或者appdelegate监听网络状态变化

 @param change 回传status和描述string
 */
+ (void)monitoringNetworkStatusChange:(statusChangedBlock)change;


/**
 （暂不可用）
 监测是否服务器真实可达，如果网络环境差，connect函数会阻塞，所以最后不要在主线程下
 */
+ (BOOL)socketReachabilityTest;


/*
 监测服务器是否真实可达
 */
+ (BOOL)checkNetworkValid;

@end
