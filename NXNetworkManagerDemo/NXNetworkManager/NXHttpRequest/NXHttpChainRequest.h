//
//  NXHttpChainRequest.h
//  NXNetworkManagerDemo
//
//  Created by Design on 2019/1/29.
//  Copyright © 2019年 Design. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NXHttpRequest, NXHttpResponse;
@interface NXHttpChainRequest : NSObject

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, strong, readonly) NXHttpRequest *runningRequest;

- (NXHttpChainRequest *)onFirst:(NXHttpRequestConfigBlock)firstBlock;

- (NXHttpChainRequest *)onNext:(NXNextBlock)nextBlock;

- (BOOL)onFinishedOneRequest:(NXHttpRequest *)request response:(nullable NXHttpResponse *)responseObject;

@end

NS_ASSUME_NONNULL_END
