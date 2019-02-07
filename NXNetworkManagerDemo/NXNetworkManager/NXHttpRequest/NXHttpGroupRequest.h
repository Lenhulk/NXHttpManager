//
//  NXHttpGroupRequest.h
//  NXNetworkManagerDemo
//
//  Created by Design on 2019/1/29.
//  Copyright © 2019年 Design. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NXHttpRequest, NXHttpResponse;
@interface NXHttpGroupRequest : NSObject

@property (nonatomic, strong, readonly) NSMutableArray<NXHttpRequest *> *requestArray;
@property (nonatomic, strong, readonly) NSMutableArray<NXHttpResponse *> *responseArray;

- (void)addRequest:(NXHttpRequest *)request;

- (BOOL)onFinishedOneRequest:(NXHttpRequest *)request response:(nullable NXHttpResponse *)responseObject;

@end

NS_ASSUME_NONNULL_END
