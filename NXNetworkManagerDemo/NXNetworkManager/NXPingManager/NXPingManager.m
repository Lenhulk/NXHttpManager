//
//  NXPingManager.m
//  NXNetworkManagerDemo
//
//  Created by Design on 2018/11/23.
//  Copyright © 2018年 Design. All rights reserved.
//

#import "NXPingManager.h"
#import "NXPingServices.h"

@implementation NXPingManager

+ (void)pingFastestHost:(nonnull NSArray *)hostList handler:(void (^)(NSString * __Nullable))handler{
    if (hostList.count == 0) {
        NXLog(@"hostList不可为空");
        handler(nil);
        return ;
    }
    // 存储所有域名对应的所有ping值
    NSMutableDictionary<NSString *, NSArray<NSNumber*> *> *pingResult = [NSMutableDictionary dictionary];
    for (NSString *host in hostList) {
        pingResult[host] = @[]; //给pingResult每个域名的值设为空数组
    }
    // 存储所有ping服务对象
    NSMutableDictionary *pingServiceDict = @{}.mutableCopy;
    // 存储ping失败的Host
    NSMutableArray<NSString *> *failHostList = @[].mutableCopy;

    dispatch_group_t group = dispatch_group_create();

    for (NSString *host in hostList) {
        dispatch_group_enter(group);

        pingServiceDict[host] = [NXPingServices pingStartWithHostName:host pingTimes:5 pingCallback:^(NXPingItem *pItem) {
            switch (pItem.status) {

                case NXPingStatusDidStart:
                    break;

                case NXPingStatusDidFailToSendPacket:
                    [failHostList addObject:pItem.hostName];
                    break;

                case NXPingStatusDidReceivePacket: {
                    NSMutableArray *arr = [pingResult[pItem.hostName] mutableCopy];
                    // 添加新ping值
                    [arr addObject:@(pItem.timeMilliseconds)];
                    pingResult[pItem.hostName] = arr.copy;
                    break;
                }

                case NXPingStatusDidFinished:{
                    pingServiceDict[pItem.hostName] = nil;
                    dispatch_group_leave(group);
                    break;
                }

                case NXPingStatusDidTimeout: {
                    //ping 超时则默认为加1s
                    NSMutableArray *arr = [pingResult[pItem.hostName] mutableCopy];
                    [arr addObject:@(pItem.timeMilliseconds)];
                    pingResult[pItem.hostName] = arr.copy;
                    break;
                }

                case NXPingStatusDidError:
                    [failHostList addObject:pItem.hostName];
                    break;

                case NXPingStatusDidReceiveUnexpectedPacket:
                    break;

                default:
                    break;
            }
        }];
    }

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NXLog(@"开始计算延迟..");
        // 数据验证
        for (NSString *host in failHostList) {
            NXLog(@"ping失败的域名: [%@]", host);
            [pingResult removeObjectForKey:host];
        }
        for (NSString *host in pingResult.allKeys) {
            if (pingResult[host].count == 0) {
                NXLog(@"ping出现异常的域名: [%@]", host);
                [pingResult removeObjectForKey:host];
            }
        }
        // 无可用数据
        if (pingResult.count == 0) {
            handler(nil);
            return ;
        }
        // 数据可用
        NSString *fastestHost = @"";
        float minAvg = MAXFLOAT;
        for (NSString * host in pingResult.allKeys) {
            float sum = 0.0;
            for (NSNumber *time in pingResult[host]) {
                sum += [time floatValue];
            }
            float avg = sum / (float)[pingResult[host] count];
            NXLog(@"[%@] 平均延迟 >>> %.3lfms", host, avg);

            if (minAvg > avg) {
                minAvg = avg;
                fastestHost = host;
            }
        }
        NXLog(@"❀~完结撒花~❀ Ping最快的地址是：%@, 平均延迟：%.3lfms", fastestHost, minAvg);
        handler(fastestHost);
    });
}

+ (void)pingFastestHost:(NSArray *)hostList progress:(void (^)(CGFloat))progress handler:(void (^)(NSString *))handler{
    
    if (hostList.count == 0) {
        NXLog(@"hostList不可为空");
        progress(1.0);
        handler(nil);
        return ;
    }
    
    // 如果有就去掉 "http://" & "https://" 前缀
    NSMutableArray *pingHostList = @[].mutableCopy;
    for (NSString *fullHost in hostList) {
        NSString *bareHost = fullHost;
        if ([fullHost hasPrefix:@"https://"]) {
            bareHost = [fullHost stringByReplacingOccurrencesOfString:@"https://" withString:@""];
        }
        if ([fullHost hasPrefix:@"http://"]) {
            bareHost = [fullHost stringByReplacingOccurrencesOfString:@"http://" withString:@""];
        }
        [pingHostList addObject:bareHost];
    }
    
    //给pingResult添加每个域名，并把ping值数组设为空
    NSMutableDictionary<NSString *, NSArray<NSNumber*> *> *pingResult = [NSMutableDictionary dictionary];
    for (NSString *host in pingHostList) {
        pingResult[host] = @[];
    }
    
    //计数百分比rate规则：开始每个包+1 发包+5 收到包+5(各ping5次,不丢包的情况下,丢包则rate不加) 结束+1 ==> total=7次
    __block CGFloat totalCount = hostList.count*(1+5+5+1);
    __block CGFloat rateCount = 0.0;
    
    // 存储所有ping服务对象
    NSMutableDictionary *pingServiceDict = @{}.mutableCopy;
    // 存储ping失败的Host
    NSMutableArray<NSString *> *failHostList = @[].mutableCopy;
    
    // 开启任务组
    dispatch_group_t group = dispatch_group_create();
    
    for (NSString *host in pingHostList) {
        dispatch_group_enter(group);
        
        pingServiceDict[host] = [NXPingServices pingStartWithHostName:host pingTimes:5 pingCallback:^(NXPingItem *pItem) {
            switch (pItem.status) {
                    
                case NXPingStatusDidStart: {
                    rateCount ++;
                    progress(rateCount/totalCount);
                    break;
                }
                    
                case NXPingStatusDidReceivePacket: {
                    // 添加新ping值
                    NSMutableArray *arr = [pingResult[pItem.hostName] mutableCopy];
                    [arr addObject:@(pItem.timeMilliseconds)];
                    pingResult[pItem.hostName] = arr.copy;
                    rateCount++;
                    progress(rateCount/totalCount);
                    break;
                }
                    
                // 超时则默认为加1s 也rate+
                case NXPingStatusDidTimeout: {
                    NSMutableArray *arr = [pingResult[pItem.hostName] mutableCopy];
                    [arr addObject:@(pItem.timeMilliseconds)];
                    pingResult[pItem.hostName] = arr.copy;
                    rateCount ++;
                    progress(rateCount/totalCount);
                    break;
                }
                    
                case NXPingStatusDidFinished:{
                    pingServiceDict[pItem.hostName] = nil;
                    rateCount ++;
                    progress(rateCount/totalCount);
                    dispatch_group_leave(group);
                    break;
                }
                    
                case NXPingStatusDidError: {
                    [failHostList addObject:pItem.hostName];
                    rateCount ++;
                    progress(rateCount/totalCount);
                    dispatch_group_leave(group);
                    break;
                }
                    
                case NXPingStatusDidSuccessToSendPacket:{
                    rateCount ++;
                    progress(rateCount/totalCount);
                    break;
                }
                    
                case NXPingStatusDidFailToSendPacket:{
                    rateCount ++;
                    progress(rateCount/totalCount);
                    break;
                }
                    
                case NXPingStatusDidReceiveUnexpectedPacket:
                    break;
                
                default:
                    break;
            }
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NXLog(@"开始计算延迟..");
        // 0. 数据验证
        for (NSString *host in failHostList) {
            NXLog(@"ping失败(Error)的域名: [%@]", host);
            [pingResult removeObjectForKey:host];
        }
        for (NSString *host in pingResult.allKeys) {
            if (pingResult[host].count == 0) {
                NXLog(@"ping异常(100%%返回异常包)的域名: [%@]", host);
                [pingResult removeObjectForKey:host];
            }
        }
        // 无可用数据: 证明所有域名都出现错误/异常
        if (pingResult.count == 0) {
            NXLog(@"完成步数%f / 总步数%f", rateCount, totalCount);
            NXLog(@" ❀-- 完结：所有域名都出现错误/异常，默认不切换域名 --❀");
            progress(1.0);
            handler(nil);
            return ;
        }
        // 1. 数据可用
        NSString *fastestHost = @"";
        float minAvg = 1000;
        for (NSString * host in pingResult.allKeys) {
            float sum = 0.0;
            for (NSNumber *time in pingResult[host]) {
                sum += [time floatValue];
            }
            float avg = sum / (float)[pingResult[host] count];
            if (minAvg > avg) {
                minAvg = avg;
                fastestHost = host;
            }
            
            // 给出全长
            NSString *fHost = host;
            for (NSString *fullHost in hostList) {
                if ([fullHost containsString:host]) {
                    fHost = fullHost;
                }
            }
            NXLog(@"[%@] 平均延迟 >>> %.3lfms", fHost, avg);
        }
        
        NXLog(@"完成步数%f / 总步数%f", rateCount, totalCount);
        // 1.1 所有域名都超时
        if (minAvg == 1000 || [fastestHost isEqualToString:@""]) {
            NXLog(@" ❀-- 完结：所有可用域名都超时，默认不切换域名 --❀");
            progress(1.0);
            handler(fastestHost);
            
        } else {
            // 1.2 有可用域名
            for (NSString *fullHost in hostList) { // 给出最快的域名的全长
                if ([fullHost containsString:fastestHost]) {
                    fastestHost = fullHost;
                }
            }
            NXLog(@" ❀~~完结撒花~~❀ Ping最快的地址是：%@, 平均延迟：%.3lfms", fastestHost, minAvg);
            progress(1.0);
            handler(fastestHost);
        }
        
    });
}

@end
