//
//  NXHttpRequestManager.h
//  NXNetworkManagerDemo
//
//  Created by Design on 2018/11/7.
//  Copyright © 2018年 Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXHttpConstant.h"

NS_ASSUME_NONNULL_BEGIN

@class NXHttpRequest, NXHttpResponse, AFHTTPSessionManager, AFURLSessionManager;


/**
【 -------------------- USAGE EXAMPLE -------------------- 】
 
 Example for normal request:
     [[NXHttpRequestManager shareManager] sendHttpRequestWithConfigBlock:^(NXHttpRequest *request) {
         request.requestURL = @"satinApi";
         request.params = @{@"type":@"1",
                             @"page":@"1"};
         request.requestMethod = NXHttpMethodTypeGET;
     } complete:^(NXHttpResponse *response) {
         NSLog(@"请求完成:%ld",  (long)response.requestId);
     }];
 
 
 Example for upload file:
 
     NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"wrench" ofType:@"png"];
     UIImage *image = [UIImage imageWithContentsOfFile:path];
     NSData *fileData = UIImagePNGRepresentation(image);
     [[NXHttpRequestManager shareManager] sendHttpRequestWithConfigBlock:^(NXHttpRequest *request) {
         request.baseURL = @"https://httpbin.org/";
         request.requestURL = @"post";
         request.requestType = NXRequestUpload;
     [request addFormDataWithName:@"tag" fileName:@"testImg" mimeType:@"image/jpeg" fileData:fileData];
     } progress:^(NSProgress *progress) {
         NSLog(@"上传进度%.2lf", progress.fractionCompleted);
     } complete:^(NXHttpResponse *response) {
         NSLog(@"===上传完成: %@", response.content);
     }];
 
 
 Example for download file:
 
     [[NXHttpRequestManager shareManager] sendHttpRequestWithConfigBlock:^(NXHttpRequest *request) {
         request.baseURL = @"https://httpbin.org/image/png";
         request.requestType = NXRequestDownload;
         request.downloadSavePath = [NSHomeDirectory() stringByAppendingString:@"/Documents/temp.png"];
     } progress:^(NSProgress *progress) {
         NSLog(@"=======>下载进度：%lf", progress.fractionCompleted);
     } complete:^(NXHttpResponse *response) {
         NSLog(@"=======> 完成：%@", response.content);
     }];
 */


/**
 【 发送单次HTTP网络请求的主类 】
 */
@interface NXHttpRequestManager : NSObject

/// 存放 taskIdentifier : dataTask 字典
@property (nonatomic, strong) NSMutableDictionary<NSString*, NSURLSessionTask*> * _Nullable reqeustDictionary;

@property (nonatomic, weak) AFHTTPSessionManager * httpSecMgr;
@property (nonatomic, weak) AFURLSessionManager *urlSecMgr;

@property (nonatomic, copy) NXProgressBlock progressBlock;

//上传文件相关参数
@property (nonatomic, strong, readonly) NSDictionary <NSString *, NSURL *> *uploadFileDic NS_UNAVAILABLE;


+ (instancetype)shareManager;

/**
 直接进行请求，请求前进行参数及 url 等的包装
 
 @param request 请求实体类
 @param result 请求结果 Block
 @return 请求对应的唯一 task id
 */
- (NSString *)sendHttpRequest:(nonnull NXHttpRequest *)request
                     complete:(NXHttpResponseBlock)result;

/**
 在block中完成请求配置
 
 @param requestBlock 请求配置 Block
 @param result 请求结果 Block
 @return 该请求对应的唯一 task id
 */
- (NSString *)sendHttpRequestWithConfigBlock:(nonnull NXHttpRequestConfigBlock)requestBlock
                                    complete:(NXHttpResponseBlock)result;

/**
 带进度的网络请求 （用于上传下载）
 
 @param progress 请求进度
 */
- (NSString *)sendHttpRequest:(nonnull NXHttpRequest *)request
                     progress:(nullable NXProgressBlock)progress
                     complete:(nullable NXHttpResponseBlock)result;

/**
 带进度的网络请求 （用于上传下载）
 
 @param requestBlock 请求配置 Block
 @param progress 请求进度
 */
- (NSString *)sendHttpRequestWithConfigBlock:(nonnull NXHttpRequestConfigBlock)requestBlock
                     progress:(nullable NXProgressBlock)progress
                     complete:(nullable NXHttpResponseBlock)result;

/**
 根据请求 ID 取消单个任务
 
 @param requestID 任务请求 ID
 */
- (void)cancelRequestWithRequestID:(nonnull NSString *)requestID;

/**
 根据请求 ID 列表 取消多个任务
 
 @param requestIDList 任务请求 ID 列表
 */
- (void)cancelRequestWithRequestIDList:(nonnull NSArray<NSString *> *)requestIDList;

@end

NS_ASSUME_NONNULL_END
