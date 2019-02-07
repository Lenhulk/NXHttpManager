//
//  NXHttpRequestManager+Group.m
//  NXNetworkManagerDemo
//
//  Created by Design on 2019/1/29.
//  Copyright © 2019年 Design. All rights reserved.
//

#import "NXHttpRequestManager+Group.h"
#import "NXHttpGroupRequest.h"
#import "NXHttpRequest.h"
#import "NXHttpResponse.h"
#import <objc/runtime.h>

@implementation NXHttpRequestManager (Group)

- (NSMutableDictionary *)groupRequestDictionary {
    return objc_getAssociatedObject(self, @selector(groupRequestDictionary));
}

- (void)setGroupRequestDictionary:(NSMutableDictionary *)mutableDictionary {
    objc_setAssociatedObject(self, @selector(groupRequestDictionary), mutableDictionary, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)sendGroupRequest:(NXGroupRequestConfigBlock)configBlock complete:(NXGroupResponseBlock)completeBlock{
    if (![self groupRequestDictionary]) {
        [self setGroupRequestDictionary:[NSMutableDictionary dictionary]];
    }
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    NXHttpGroupRequest *groupRequest = [[NXHttpGroupRequest alloc] init];
    configBlock(groupRequest);
    
    if (groupRequest.requestArray.count > 0) {
        if (completeBlock) {
            [groupRequest setValue:completeBlock forKey:@"completeBlock"];
        }
        
        [groupRequest.responseArray removeAllObjects];
        for (NXHttpRequest *request in groupRequest.requestArray) {
            
            NSString *taskID = [self sendHttpRequest:request complete:^(NXHttpResponse * _Nullable response) { //执行请求
                if ([groupRequest onFinishedOneRequest:request response:response]) { //判断是否结束
                    NXLog(@"<===== Group Requests all finished! =====>");
                }
            }];
            [tempArray addObject:taskID];
        }
        NSString *uuid = [[NSUUID UUID].UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [self groupRequestDictionary][uuid] = tempArray.copy;
        return uuid;
    }
    return nil;
}

- (void)cancelGroupRequest:(NSString *)taskID{
    NSArray *group = [self groupRequestDictionary][taskID];
    for (NSString *tid in group) {
        [self cancelRequestWithRequestID:tid];
    }
}

@end
