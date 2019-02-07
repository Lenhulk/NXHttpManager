//
//  NXHttpRequestManager+Group.h
//  NXNetworkManagerDemo
//
//  Created by Design on 2019/1/29.
//  Copyright © 2019年 Design. All rights reserved.
//

#import "NXHttpRequestManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
【 -------------------- USAGE EXAMPLE -------------------- 】
 
  Example for group request:
    NSString *iiid = [[NXHttpRequestManager shareManager] sendGroupRequest:^(NXHttpGroupRequest *gRequest) {
        for (NSInteger i = 0; i < 3; i ++) {
            NXHttpRequest *request = [[NXHttpRequest alloc] init];
            request.baseURL = @"https://www.apiopen.top/";
            request.requestURL = @"satinApi";
            request.params = @{@"type":@"1",
                               @"page":@"1"
                               };
            request.requestMethod = NXHttpMethodTypeGET;
            [gRequest addRequest:request];
        }
    } complete:^(NSArray<NXHttpResponse *> * _Nullable responseObjects, BOOL isSuccess) {
        if (isSuccess) {
            for (int i=0; i<responseObjects.count; i++) {
                NXHttpResponse *resp = responseObjects[i];
                NSLog(@"%d === %@", i, resp.content);
            }
        }
    }];
 
*/


/**
 【 发送 批量请求 】
  同时发一组批量请求，这组请求在业务逻辑上相关，但请求本身是互相独立的，会在所有请求都成功结束时执行状态才是success，而一旦有一个请求失败，则会 fail。注：回调 Block 中的 `responseObjects` 和 `errors` 中元素的顺序与每个 XMRequest 对象在 `batchRequest.requestArray` 中的顺序一致。
 */
@interface NXHttpRequestManager (Group)

- (NSString *)sendGroupRequest:(nullable NXGroupRequestConfigBlock)configBlock
                      complete:(nullable NXGroupResponseBlock)completeBlock;


- (void)cancelGroupRequest:(NSString *)taskID;

@end

NS_ASSUME_NONNULL_END
