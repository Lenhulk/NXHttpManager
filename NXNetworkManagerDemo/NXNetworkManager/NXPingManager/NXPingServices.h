//
//  NXPingServices.h
//  NXNetworkManagerDemo
//
//  Created by Design on 2018/11/23.
//  Copyright © 2018年 Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimplePing.h"

/// ping状态
///
/// - didStart: 开始ping
/// - didSuccessToSendPacket: 发包成功
/// - didFailToSendPacket: 发包失败
/// - didReceivePacket: 接收到正常包
/// - didReceiveUnexpectedPacket: 接收到异常包
/// - didTimeout: 超时
/// - didError: 错误
/// - didFinished: 完成
typedef NS_ENUM(NSUInteger, NXPingStatus) {
    NXPingStatusDidStart = 0,
    NXPingStatusDidSuccessToSendPacket,
    NXPingStatusDidFailToSendPacket,
    NXPingStatusDidReceivePacket,
    NXPingStatusDidReceiveUnexpectedPacket,
    NXPingStatusDidTimeout,
    NXPingStatusDidError,
    NXPingStatusDidFinished,
};


@interface NXPingItem : NSObject
// 域名
@property(nonatomic, strong) NSString *hostName;
// 单次耗时
@property(nonatomic, assign) double timeMilliseconds;
// 状态
@property(nonatomic, assign) NXPingStatus status;
@end


@interface NXPingServices : NSObject
+ (NXPingServices *)pingStartWithHostName:(NSString *)host pingTimes:(int)times pingCallback:(void (^)(NXPingItem *))callback;
@end


