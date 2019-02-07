//
//  NXHttpGroupRequest.m
//  NXNetworkManagerDemo
//
//  Created by Design on 2019/1/29.
//  Copyright © 2019年 Design. All rights reserved.
//

#import "NXHttpGroupRequest.h"
#import "NXHttpResponse.h"
#import "NXHttpConstant.h"

@interface NXHttpGroupRequest ()
// 已完成的请求数量
@property (nonatomic, assign) NSUInteger finishedCount;
// 批量请求是否全都成功
@property (nonatomic, assign, getter=isSucceed) BOOL succeed;
@property (nonatomic, copy) NXGroupResponseBlock completeBlock;
@end

@implementation NXHttpGroupRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        _succeed = YES;
        _requestArray = [NSMutableArray new];
        _responseArray = [NSMutableArray new];
    }
    return self;
}

- (void)addRequest:(NXHttpRequest *)request {
    [_requestArray addObject:request];
}

- (BOOL)onFinishedOneRequest:(NXHttpRequest *)request response:(nullable NXHttpResponse *)responseObject {
    BOOL isFinished = NO;
    if (responseObject) {
        [_responseArray addObject:responseObject];
    }
//    _failed |= (responseObject.status == NXHttpResponseStatusError);
    _succeed &= (responseObject.status == NXHttpResponseStatusSuccess);
    
    _finishedCount ++;
    if (_finishedCount == _requestArray.count) { // 完成
        if (_completeBlock) {
//            _completeBlock(_responseArray.copy, _failed);
            _completeBlock(_responseArray.copy, _succeed);
        }
        [self cleanCallbackBlocks];
        isFinished = YES;
    }
    return isFinished;
}

- (void)cleanCallbackBlocks {
    _completeBlock = nil;
}


@end
