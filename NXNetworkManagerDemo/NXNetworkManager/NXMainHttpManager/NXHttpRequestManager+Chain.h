//
//  NXHttpRequestManager+Chain.h
//  NXNetworkManagerDemo
//
//  Created by Design on 2019/1/30.
//  Copyright © 2019年 Design. All rights reserved.
//

#import "NXHttpRequestManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
【 -------------------- USAGE EXAMPLE -------------------- 】

     NXHttpConfig.generalServer = @"https://www.apiopen.top/";
     [[NXHttpRequestManager shareManager] sendChainRequest:^(NXHttpChainRequest *cRequest) {
         [cRequest onFirst:^(NXHttpRequest *request) {
             request.requestURL = @"getImages";
             request.params = @{@"page":@"1"
                                 };
             request.logDebugMsg = YES;
         }];
         [cRequest onNext:^(NXHttpRequest * _Nullable request, NXHttpResponse * _Nullable responseObject, BOOL * _Nullable isSent) {
             request.requestURL = @"getImages";
             request.params = @{@"page":@"2"
             };
             NXLog(@"%@, 2 == %@", isSent?@"YES":@"NO", responseObject.content);
         }];
         [cRequest onNext:^(NXHttpRequest * _Nullable request, NXHttpResponse * _Nullable responseObject, BOOL * _Nullable isSent) {
             request.requestURL = @"getImages";
             request.params = @{@"page":@"3"
             };
             NXLog(@"%@, 3 == %@", isSent?@"YES":@"NO", responseObject.content);
         }];
         [cRequest onNext:^(NXHttpRequest * _Nullable request, NXHttpResponse * _Nullable responseObject, BOOL * _Nullable isSent) {
             request.requestURL = @"getImages";
             request.params = @{@"page":@"4"
             };
             NXLog(@"%@, 4 == %@", isSent?@"YES":@"NO", responseObject.content);
         }];
         [cRequest onNext:^(NXHttpRequest * _Nullable request, NXHttpResponse * _Nullable responseObject, BOOL * _Nullable isSent) {
             request.requestURL = @"getImages";
             request.params = @{@"page":@"5"
             };
             NXLog(@"%@, 5 == %@", isSent?@"YES":@"NO", responseObject.content);
         }];
     } complete:^(NSArray<NXHttpResponse *> * _Nullable responseObjects, BOOL isSuccess) {
         if (isSuccess) {
             for (int i=0; i<responseObjects.count; i++) {
                 NXHttpResponse *resp = responseObjects[i];
                 NXLog(@"%d ==FINISH== %ld", i, resp.requestId);
             }
         }
     }];
    
 */

/**
 【 发送 同步请求 】
 同时发一组同步请求，这组请求在业务逻辑上相关，请求本身是互相依赖的，只有上个请求成功完成才会执行下个请求。会在所有请求都成功结束时执行状态才是success，而一旦有一个请求失败，则会 fail。注：回调 Block 中的 `responseObjects` 和 `errors` 中元素的顺序与每个 XMRequest 对象在 `batchRequest.requestArray` 中的顺序一致。
 */
@interface NXHttpRequestManager (Chain)

- (NSString *)sendChainRequest:(nullable NXChainRequestConfigBlock)configBlock
                      complete:(nullable NXGroupResponseBlock)completeBlock;


- (void)cancelChainRequest:(NSString *)taskID;

@end

NS_ASSUME_NONNULL_END
