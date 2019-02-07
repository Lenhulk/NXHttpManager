//
//  NXHttpRequestManager.m
//  NXNetworkManagerDemo
//
//  Created by Design on 2018/11/7.
//  Copyright © 2018年 Design. All rights reserved.
//

#import "NXHttpRequestManager.h"
#import "NXNetworkReachability.h"
#import "NXHttpRequest.h"
#import "NXHttpResponse.h"
#import "NXHttpConfigure.h"
#import "NXHttpLogger.h"
#import "NXHttpCookiesManager.h"

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#else
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#endif

@interface NXHttpRequestManager ()

@end

@implementation NXHttpRequestManager

+ (instancetype)shareManager{
    static NXHttpRequestManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[NXHttpRequestManager alloc] init];
        _manager.reqeustDictionary = [[NSMutableDictionary alloc] init];
    });
    return _manager;
}

- (AFHTTPSessionManager *)shareAFNSessionManager{
    static AFHTTPSessionManager *_afnMgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.HTTPMaximumConnectionsPerHost = 4;
        _afnMgr = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
        //TODO:做成可配置接口
        _afnMgr.requestSerializer = [AFJSONRequestSerializer serializer];
        _afnMgr.responseSerializer = [AFHTTPResponseSerializer serializer];
        _afnMgr.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                             @"text/plain",
                                                             @"application/json",
                                                             @"text/json",
                                                             @"text/javascript",
                                                             @"text/html",
                                                             @"application/x-javascript",
                                                             nil];
        _afnMgr.securityPolicy.allowInvalidCertificates = YES;
        _afnMgr.securityPolicy.validatesDomainName = NO;
        self.httpSecMgr = _afnMgr;
    });
    return _afnMgr;
}

- (AFURLSessionManager *)shareSessionManager {
    static AFURLSessionManager *_secMgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _secMgr = [[AFURLSessionManager alloc] initWithSessionConfiguration:nil];
        _secMgr.responseSerializer = [AFHTTPResponseSerializer serializer];
        _secMgr.operationQueue.maxConcurrentOperationCount = 5;
//        _secMgr.completionQueue = xm_request_completion_callback_queue(); //线程
        self.urlSecMgr = _secMgr;
    });
    return _secMgr;
}


#pragma mark - Main Func

- (NSString *)sendHttpRequest:(nonnull NXHttpRequest *)request complete:(NXHttpResponseBlock)result{
    return [self sendHttpRequest:request progress:nil complete:result];
}

- (NSString *)sendHttpRequest:(NXHttpRequest *)request progress:(NXProgressBlock)progress complete:(NXHttpResponseBlock)result{
    return [self requestWithRequest:request progress:progress complete:result];
}

- (NSString *)sendHttpRequestWithConfigBlock:(nonnull NXHttpRequestConfigBlock)requestBlock complete:(NXHttpResponseBlock)result{
    return [self sendHttpRequestWithConfigBlock:requestBlock progress:nil complete:result];
}

- (NSString *)sendHttpRequestWithConfigBlock:(NXHttpRequestConfigBlock)requestBlock progress:(NXProgressBlock)progress complete:(NXHttpResponseBlock)result{
    NXHttpRequest *request = [NXHttpRequest new];
    requestBlock(request);  // 这里是在外部配置参数
    return [self requestWithRequest:request progress:progress complete:result];
}

- (void)cancelRequestWithRequestID:(NSString *)requestID{
    NSURLSessionTask *task = self.reqeustDictionary[requestID];
    [task cancel];
    [self.reqeustDictionary removeObjectForKey:requestID];
}

- (void)cancelRequestWithRequestIDList:(NSArray<NSString *> *)requestIDList{
    for (NSString *reqId in requestIDList) {
        [self cancelRequestWithRequestID:reqId];
    }
}


#pragma mark - Private Func
/**
 【网络请求总方法】发起请求
 
 @param nxRequest 自定义的NXHttpRequest
 @param complete 回调
 @return requestId 网络请求唯一标识
 */
- (NSString *)requestWithRequest:(NXHttpRequest *)nxRequest progress:(NXProgressBlock)progressBlock complete:(NXHttpResponseBlock)complete{
    
    NSURLRequest *urlRequest = [nxRequest generateRequest];
    
    // ========= 未通过网络检查 ==========
    if (![[NXNetworkReachability sharedManager] isReachable] || [[NXNetworkReachability sharedManager] networkReachabilityStatus] == AFNetworkReachabilityStatusUnknown)
    {
        NSError *error = [NSError errorWithDomain:@""
                                             code:NSURLErrorNotConnectedToInternet
                                         userInfo:@{NSLocalizedDescriptionKey:@"网络连接失败，请检查网络"}];
        NXHttpResponse *response = [[NXHttpResponse alloc] initWithRequest:urlRequest error:error];
        complete ? complete(response) : nil;
        if (nxRequest.isLogDebugMsg==YES || (NXHttpConfig.enableDebug && !NXHttpConfig.enableDebugOnlyError) || (nil!=error && NXHttpConfig.enableDebug && NXHttpConfig.enableDebugOnlyError)) {
            [NXHttpLogger logDebugInfoWhenNetworkFail];
        }
        return nil;
    }
    
    // ========= 网络有连接 ==========
    __block int startTime = [NSDate timeIntervalSinceReferenceDate];
    
    // 普通网络请求
    if (NXRequestNormal == nxRequest.requestType) {
        __block NSURLSessionDataTask *task = [[self shareAFNSessionManager] dataTaskWithRequest:urlRequest
                                                completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            // 请求完成
            [self.reqeustDictionary removeObjectForKey:[NSString stringWithFormat:@"%ld", [task taskIdentifier]]];
            
            // 保存cookie（可能不需要手动操作？CookieName必须与后端沟通）
            if (nxRequest.saveCookieName != nil) {
                [NXHttpCookiesManager saveCookie:kUserDefaultCookieName(nxRequest.saveCookieName) withHttpResponse:response];
            }
            int endTime = [NSDate timeIntervalSinceReferenceDate];
            int interval = endTime - startTime;
            [self requestFinishedWithRequest:nxRequest responseBlock:complete task:task data:responseObject duration:interval error:error];
        }];
        return [self returnIdWithTaskResume:task];
    
    // 上传文件请求
    } else if (NXRequestUpload == nxRequest.requestType) {
        __block NSURLSessionUploadTask *task = [[self shareSessionManager] uploadTaskWithStreamedRequest:urlRequest progress:^(NSProgress * _Nonnull uploadProgress) {
            if (progressBlock) {
                progressBlock(uploadProgress);
            }
        } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            [self.reqeustDictionary removeObjectForKey:[NSString stringWithFormat:@"%ld", [task taskIdentifier]]];
            int endTime = [NSDate timeIntervalSinceReferenceDate];
            int interval = endTime - startTime;
            [self requestFinishedWithRequest:nxRequest responseBlock:complete task:task data:responseObject duration:interval error:error];
        }];
        return [self returnIdWithTaskResume:task];
     
    // 下载文件请求
    } else if (NXRequestDownload == nxRequest.requestType) {
        __block NSURLSessionDownloadTask *task = [[self shareSessionManager] downloadTaskWithRequest:urlRequest progress:^(NSProgress * _Nonnull downloadProgress) {
            if (progressBlock) {
                progressBlock(downloadProgress);
            }
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return nxRequest.downloadFileSavedFullPath;
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            int endTime = [NSDate timeIntervalSinceReferenceDate];
            int interval = endTime - startTime;
            //TODO:设计一个(data*)responseObject 下载路径 文件类型
            [self requestFinishedWithRequest:nxRequest responseBlock:complete task:task data:filePath duration:interval error:error];
        }];
      return [self returnIdWithTaskResume:task];
    }
    
    //TODO: -requestType错误处理
    return nil;
}
                                                  
- (NSString *)returnIdWithTaskResume:(id)task {
  NSString *taskId = [[NSString alloc] initWithFormat:@"%ld", [task taskIdentifier]];
  self.reqeustDictionary[taskId] = task;
  // 开始请求
  [task resume];
  return taskId;
}


/**
 请求完成的block

 @param resBlock 请求响应block，生成并返回NXHttpResponse
 @param task 网络请求任务
 @param data rawData
 @param error Error
 */
- (void)requestFinishedWithRequest:(NXHttpRequest *)request responseBlock:(NXHttpResponseBlock)resBlock task:(NSURLSessionTask *)task data:(id)data duration:(int)second error:(NSError *)error
{
    /// === 需要重试 ===
    if (error && request.retryCount > 0) {
        //TODO: 如何加入线程排队？?
        request.retryCount --;
        NXLog(@"Task:%ld, 重试请求次数剩余：%ld", task.taskIdentifier ,request.retryCount);
        // retry current request after 2 seconds.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self requestWithRequest:request progress:nil complete:resBlock];
        });
        return;
    }
    
    /// === 不需要重试 ===
    NXHttpResponse *rsp = [[NXHttpResponse alloc] initWithSessionTask:task data:data error:error];
    
    // tips: NXHttpRequest只有在‘generateRequest’之后，才会有最新的该Domaind的请求头信息, 否则只能获取到用户设置的请求头信息或默认请求头信息，NXHttpResponse详细参数, 必须在‘initWithSessionTask’之后，否则可能出现空响应头等空信息    ||| 因此打印DEBUG应该在‘requestFinishedWithRequest’
    [NXHttpLogger logDebugInfoWithRequest:request Task:task ResponseData:data duration:second error:error];
    
    dispatch_async(NXHttpConfig.callbackQueue?NXHttpConfig.callbackQueue:dispatch_get_main_queue(), ^{
        NX_SAFE_BLOCK(resBlock, rsp);
    });
    
}




@end
