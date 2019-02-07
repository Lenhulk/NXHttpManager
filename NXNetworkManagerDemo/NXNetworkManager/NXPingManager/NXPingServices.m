//
//  NXPingServices.m
//  NXNetworkManagerDemo
//
//  Created by Design on 2018/11/23.
//  Copyright © 2018年 Design. All rights reserved.
//

#import "NXPingServices.h"

@implementation NXPingItem

@end


@interface NXPingServices () <SimplePingDelegate>
@property (nonatomic, strong) SimplePing *pinger;
@property (nonatomic, assign) int times;
@property (nonatomic, strong) NSString *hostName;
@property (nonatomic, weak)   NSTimer *timer;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, copy)   void(^pingCallback)(NXPingItem *pingItem);
@end

@implementation NXPingServices

- (instancetype)initWithHostName:(NSString *)host pingTimes:(int)times pingCallback:(void (^)(NXPingItem *))callback{
    if (self = [super init]) {
        self.hostName = host;
        self.times = times;
        self.pingCallback = callback;
        
        SimplePing *pinger = [[SimplePing alloc] initWithHostName:host];
        pinger.delegate = self;
        pinger.addressStyle = SimplePingAddressStyleAny;
        self.pinger = pinger;
        [pinger start];
    };
    return self;
}


#pragma mark - Interface
/**
 开始ping服务

 @param host ping域名
 @param times ping次数
 @param callback ping回调
 @return 返回PingServices对象
 */
+ (NXPingServices *)pingStartWithHostName:(NSString *)host pingTimes:(int)times pingCallback:(void (^)(NXPingItem *))callback{
    return [[NXPingServices alloc] initWithHostName:host pingTimes:times pingCallback:callback];
}

/// 发送Ping包
- (void)sendPing{
    // 发送次数是否完了
    if (self.times < 1) {
        [self pingStop];
        return;
    }
    self.times --;
    self.startDate = [NSDate date];
    [self.pinger sendPingWithData:nil];
    // 1秒后 如果未有任何响应判定为 【超时】
    [self performSelector:@selector(pingTimeout) withObject:nil afterDelay:1];
}

/// 停止
- (void)pingStop{
    NXLog(@"Ping 域名 [%@] 停止。",self.hostName);
    [self CleanAll:NXPingStatusDidFinished];
}

/// 超时
- (void)pingTimeout{
    NXLog(@"Ping 域名 [%@] 超时！",self.hostName);
//    [self CleanAll:NXPingStatusDidTimeout]; //单次超时不算失败
    NXPingItem *item = [[NXPingItem alloc] init];
    item.hostName = self.hostName;
    item.status = NXPingStatusDidTimeout;
    item.timeMilliseconds = 1000;
    self.pingCallback(item);
}

/// 失败
- (void)pingFail{
    NXLog(@"Ping 域名 [%@] 失败！",self.hostName);
    [self CleanAll:NXPingStatusDidError];
}

/// 清理数据
- (void)CleanAll:(NXPingStatus)status{
    NXPingItem *item = [[NXPingItem alloc] init];
    item.hostName = self.hostName;
    item.status = status;
    self.pingCallback(item);
    
    [self.pinger stop];
    self.pinger = nil;
    
    [self.timer invalidate];
    self.timer = nil;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pingTimeout) object:nil];
    
    self.hostName = nil;
    self.startDate = nil;
    self.pingCallback = nil;
}


#pragma mark - SimplePingDelegate
/// 开始ping
- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address{
    NXLog(@"Ping 域名 [%@] 开始..",self.hostName);
    [self sendPing];
    
    // 创建定时器重复ping
    self.timer = nil;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(sendPing) userInfo:nil repeats:YES];
    
    // 返回开始回调
    NXPingItem *item = [[NXPingItem alloc] init];
    item.status = NXPingStatusDidStart;
    item.hostName = self.hostName;
    self.pingCallback(item);
}

/// 发包成功
- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber{
    NXLog(@"[%@] 发包<%hu> [成功]", self.hostName, sequenceNumber);
    
    // 返回发包回调
    NXPingItem *item = [[NXPingItem alloc] init];
    item.status = NXPingStatusDidSuccessToSendPacket;
    item.hostName = self.hostName;
    self.pingCallback(item);
}

/// 接收到正常包
- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pingTimeout) object:nil];
    
    // 开始时间与当前时间的间距
    NSTimeInterval timeMilliseconds = [[NSDate date] timeIntervalSinceDate:self.startDate] * 1000;
    NXLog(@"[%@] 接收到<%hu> [成功]: size=%ldbit, time=%.3fms", self.hostName, sequenceNumber, packet.length, timeMilliseconds);
    
    // 返回成功回调
    NXPingItem *item = [[NXPingItem alloc] init];
    item.status = NXPingStatusDidReceivePacket;
    item.hostName = self.hostName;
    item.timeMilliseconds = timeMilliseconds;
    self.pingCallback(item);
}

/// ping失败
- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pingTimeout) object:nil];
    NXLog(@"[%@] PING【ERROR: %@】[失败]", self.hostName, error.localizedDescription);
    [self pingFail];
}

/// 发包失败
- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pingTimeout) object:nil];
    NXLog(@"[%@] 发包<%hu>【ERROR: %@】[失败]", self.hostName, sequenceNumber, error.localizedDescription);
    [self CleanAll:NXPingStatusDidFailToSendPacket];
}

/// 接收到异常包
/// 只能证明服务器有响应，但是ping不通?
- (void)simplePing:(SimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pingTimeout) object:nil];
//    NXLog(@"[%@] 接收到<异常包> [丢弃]", self.hostName);
    
//    NXPingItem *item = [[NXPingItem alloc] init];
//    item.status = NXPingStatusDidReceiveUnexpectedPacket;
//    item.hostName = self.hostName;
//    self.pingCallback(item);
}


@end
