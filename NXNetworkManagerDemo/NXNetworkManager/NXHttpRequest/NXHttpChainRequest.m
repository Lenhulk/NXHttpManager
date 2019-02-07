//
//  NXHttpChainRequest.m
//  NXNetworkManagerDemo
//
//  Created by Design on 2019/1/29.
//  Copyright © 2019年 Design. All rights reserved.
//

#import "NXHttpChainRequest.h"

@interface NXHttpChainRequest()

@property (nonatomic, strong) NSMutableArray<NXNextBlock> *nextBlockArray;
@property (nonatomic, strong) NSMutableArray<NXHttpResponse *> *responseArray;

@property (nonatomic, copy) NXGroupResponseBlock completeBlock;
@end

@implementation NXHttpChainRequest
- (instancetype)init{
    self = [super init];
    _responseArray = [NSMutableArray array];
    _nextBlockArray = [NSMutableArray array];
    return self;
}

- (NXHttpChainRequest *)onFirst:(NXHttpRequestConfigBlock)firstBlock{
    NSAssert(firstBlock != nil, @"The first block for chain requests can't be nil.");
    NSAssert(_nextBlockArray.count == 0, @"The `-onFirst:` method must called befault `-onNext:` method");
    _runningRequest = [NXHttpRequest new];
    firstBlock(_runningRequest);
    return self;
}

- (NXHttpChainRequest *)onNext:(NXNextBlock)nextBlock{
    NSAssert(nextBlock != nil, @"The next block for chain requests can't be nil.");
    [_nextBlockArray addObject:nextBlock];
    return self;
}

- (BOOL)onFinishedOneRequest:(NXHttpRequest *)request response:(NXHttpResponse *)responseObject{
    BOOL isFinished = NO;
    [_responseArray addObject:responseObject];
    // 失败
    if (responseObject.status == NXHttpResponseStatusError) {
        _completeBlock(_responseArray.copy, NO);
        [self cleanCallbackBlocks];
        isFinished = YES;
        return isFinished;
    }
    // 正常完成
    if (_responseArray.count > _nextBlockArray.count) {
        _completeBlock(_responseArray.copy, YES);
        [self cleanCallbackBlocks];
        isFinished = YES;
        return isFinished;
    }
    /// 继续运行
    _runningRequest = [NXHttpRequest new];
    NXNextBlock nextBlock = _nextBlockArray[_responseArray.count - 1];
    BOOL isSent = YES;
    nextBlock(_runningRequest, responseObject, &isSent);
    if (!isSent) {
        _completeBlock(_responseArray.copy, YES);
        [self cleanCallbackBlocks];
        isFinished = YES;
    }
    return isFinished;
}

- (void)cleanCallbackBlocks {
    _runningRequest = nil;
    _completeBlock = nil;
    [_nextBlockArray removeAllObjects];
}

@end
