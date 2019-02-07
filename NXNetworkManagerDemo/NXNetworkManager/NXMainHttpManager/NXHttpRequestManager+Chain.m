//
//  NXHttpRequestManager+Chain.m
//  NXNetworkManagerDemo
//
//  Created by Design on 2019/1/30.
//  Copyright © 2019年 Design. All rights reserved.
//

#import "NXHttpRequestManager+Chain.h"
#import <objc/runtime.h>
#import "NXHttpChainRequest.h"

@implementation NXHttpRequestManager (Chain)
- (NSMutableDictionary *)chainRequestDictionary{
    return objc_getAssociatedObject(self, @selector(chainRequestDictionary));
}

- (void)setChainRequestDictionary:(NSMutableDictionary *)dict{
    objc_setAssociatedObject(self, @selector(chainRequestDictionary), dict, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)sendChainRequest:(NXChainRequestConfigBlock)configBlock complete:(NXGroupResponseBlock)completeBlock{
    NXHttpChainRequest *chainRequest = [[NXHttpChainRequest alloc] init];
    if (configBlock) {
        configBlock(chainRequest);
    }
    
    if (chainRequest.runningRequest) {
        if (completeBlock) {
            [chainRequest setValue:completeBlock forKey:@"completeBlock"];
        }
        
        NSString *uuid = [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [self __sendChainRequest:chainRequest uuid:uuid];
        return uuid;
    }
    return nil;
}

- (void)__sendChainRequest:(NXHttpChainRequest *)chainRequest uuid:(NSString *)uuid{
    if (chainRequest.runningRequest != nil) {
        if (![self chainRequestDictionary]) {
            [self setChainRequestDictionary:[NSMutableDictionary dictionary]];
        }
        
        __weak __typeof(self) wSelf = self;
        NSString *tId = [self sendHttpRequest:chainRequest.runningRequest complete:^(NXHttpResponse *response) {
            __weak __typeof(self) sSelf = wSelf;
            if ([chainRequest onFinishedOneRequest:chainRequest.runningRequest response:response]) {
                NXLog(@"<===== Chain Requests all finished! =====>");
            } else {
                if (chainRequest.runningRequest != nil) {
                    [sSelf __sendChainRequest:chainRequest uuid:uuid];
                }
            }
        }];
        [self chainRequestDictionary][uuid] = tId;
    }
}

- (void)cancelChainRequest:(NSString *)taskID{
    NSString *tId = [self chainRequestDictionary][taskID];
    [self cancelRequestWithRequestID:tId];
}

@end
