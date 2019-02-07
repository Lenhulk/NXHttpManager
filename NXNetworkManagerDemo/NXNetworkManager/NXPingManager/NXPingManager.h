//
//  NXPingManager.h
//  NXNetworkManagerDemo
//
//  Created by Design on 2018/11/23.
//  Copyright © 2018年 Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NXPingManager : NSObject

+ (void)pingFastestHost:(nonnull NSArray *)hostList handler:(void (^)(NSString * __Nullable))handler;

/**
 ping通则block中返回响应最快的String域名，如果没有地址ping通则返回nil，如果所有地址超时则返回@""

 @param hostList 域名数组（带"http://"&"https://"前缀的字符串数组）
 @param progress 进度 (0.00 - 1.00)
 @param handler host中返回最快的域名(带前缀)
 */
+ (void)pingFastestHost:(nonnull NSArray *)hostList progress:(void(^)(CGFloat progress))progress handler:(void(^)(NSString * host))handler;

@end

NS_ASSUME_NONNULL_END
