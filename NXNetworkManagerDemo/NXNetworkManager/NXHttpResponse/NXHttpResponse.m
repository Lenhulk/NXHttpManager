//
//  NXHttpResponse.m
//  NXNetworkManagerDemo
//
//  Created by Design on 2018/11/7.
//  Copyright © 2018年 Design. All rights reserved.
//

#import "NXHttpResponse.h"

@interface NXHttpResponse ()
@property (nullable, nonatomic, strong, readwrite)    NSData *rawData;
@property (nullable, nonatomic, strong, readwrite)          id content;
@property (nonatomic, assign, readwrite)            NSInteger statueCode;
@property (nonnull, nonatomic, strong, readwrite)     NSURLRequest *request;
@property (nonatomic, assign, readwrite)            NSInteger requestId;
@property (nonnull, nonatomic, strong, readwrite)   NSDictionary *requestHeader;
@property (nonnull, nonatomic, strong, readwrite)   NSDictionary *responseHeader;
@property (nullable, nonatomic, strong, readwrite)  NSError *error;
@property (nonatomic, assign, readwrite)            NXHttpResponseStatus status;

@end

@implementation NXHttpResponse

#pragma mark - Main Func

- (instancetype)initWithRequest:(NSURLRequest *)request error:(NSError *)error{
    if (self = [super init]) {
        self.error = nil;
        self.request = request;
        self.requestId = -1;
        self.requestHeader = self.request.allHTTPHeaderFields;
        self.rawData = nil;
        [self dealWithResponseWithStatus:error];
    }
    return self;
}

- (instancetype)initWithSessionTask:(NSURLSessionTask *)task data:(id)rspData error:(NSError *)error{
    if (self = [super init]) {
        self.error = nil;
        self.request = task.originalRequest;
        self.requestId = task.taskIdentifier;
        self.requestHeader = self.request.allHTTPHeaderFields;
        NSHTTPURLResponse * response = (NSHTTPURLResponse *)task.response;
        self.responseHeader = response.allHeaderFields;
        if (![rspData isKindOfClass:[NSData class]]) {
            self.content = rspData;
        } else {
            self.rawData = rspData;
        }
        [self dealWithResponseWithStatus:error];
    }
    return self;
}

#pragma mark - Private Func

- (void)dealWithResponseWithStatus:(nullable NSError *)error{
    
    // ********* 网络请求有错误信息 *********
    if (nil != error) {
        self.error = error;
        self.status = NXHttpResponseStatusError;
        self.statueCode = error.code;
        return;
    }
    
    // ********* 网络请求无错误信息 *********
    self.status = NXHttpResponseStatusSuccess;
    
    if (nil == self.rawData) {
        self.statueCode = NSURLErrorUnknown;
        NSError *error = [NSError errorWithDomain:self.request.URL.absoluteString
                                             code:NSURLErrorUnknown
                                         userInfo:@{NSLocalizedDescriptionKey:@"网络请求成功但返回数据为空，请与后端联系"}];
        self.error = error;
        
    } else {
        // 这里可以根据后端返回的安全码做成功请求判断并传回给statueCode
        //    [NXHttpConfigure shareInstance] respondeSuccessCode;
#warning 后端返回的响应码
        self.statueCode = 200;
        if (self.rawData) {
            id jsonData = [self jsonWithData:self.rawData];
            //        [self removeNullValue:jsonData];
            self.content = jsonData;
        }
    }
}

/**
 将responseData转为Json
 */
- (instancetype)jsonWithData:(NSData *)data {
    id jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
    // 无法解析成为字典/数组, 则尝试转为字符串
    if (nil == jsonData) {
        //Returns nil if the initialization fails for some reason
        jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    //TODO: 无法解析成为字符串，则标识错误码
    if (nil == jsonData) {
//        jsonData = @"";
        self.statueCode = 999;
    }
    return jsonData;
}

#warning  ！！！可能有不严谨的地方，时间复杂度太高！！！
/**
 移除json字典的空值
 @param dic 传入json字典对象
 */
- (void)removeNullValue:(id)dic{
    if ([dic isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *muDict = [(NSDictionary *)dic mutableCopy];
        for (NSString *dicKey in [muDict allKeys]) {
            id value = muDict[dicKey];
            if (value == [NSNull null]) {
                [muDict setObject:@"" forKey:dicKey];
            }
            if ([value isKindOfClass:[NSDictionary class]]){
                [self removeNullValue:value];
            }
            if ([value isKindOfClass:[NSArray class]]) {
                NSMutableArray *muArr = [value mutableCopy];
                for (int i=0; i<[muArr count]; i++) {
                    if (muArr[i] == [NSNull null]) {
                        [muArr replaceObjectAtIndex:i withObject:@""];
                    }
                    if ([muArr[i] isKindOfClass:[NSDictionary class]]) {
                        [self removeNullValue:muArr[i]];
                    }
                }
                [muDict setObject:muArr.copy forKey:dicKey];
            }
        }
        dic = muDict.copy;
    }
}


@end
