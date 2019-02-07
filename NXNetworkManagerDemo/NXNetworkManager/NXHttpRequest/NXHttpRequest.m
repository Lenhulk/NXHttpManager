//
//  NXHttpRequest.m
//  NXNetworkManagerDemo
//
//  Created by Design on 2018/11/7.
//  Copyright © 2018年 Design. All rights reserved.
//

#import "NXHttpRequest.h"
#import "NXHttpConfigure.h"
#import "NXUploadFormData.h"

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#else
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#endif

@interface NXHttpRequest()
@property (nonatomic, copy, readwrite) NSString *requestTypeName;
@property (nonatomic, copy, readwrite) NSString *requestMethodName;
@property (nonatomic, strong, nullable, readwrite) NSMutableArray<NXUploadFormData *> *uploadFormDatas;
@property (nonatomic, copy, nullable, readwrite) NSURL *downloadFileSavedFullPath; //存储到本地的完整路径
@end

@implementation NXHttpRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        _requestType = NXRequestNormal;
        _requestMethod = NXHttpMethodTypePOST;
        _reqeustTimeoutInterval = 30.0;
        _params = @{};
        _requestHeader = @{};
        _isNeedEncrypt = NO;
        _requestURL = @"";
        _logDebugMsg = NO;
        _retryCount = 0;
    }
    return self;
}


#pragma mark - Interface

/**
 根据配置好的信息 生成网络请求对象

 @return NSURLRequest
 */
- (NSURLRequest *)generateRequest{
    
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    serializer.timeoutInterval = [self reqeustTimeoutInterval];
    serializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    
    __block NSError *someError = nil;
    NSMutableURLRequest *urlRequest = nil;
    
    // 普通HTTP请求
    if (NXRequestNormal == self.requestType) {
        NSDictionary *param = [self generateRequestParameters];
        urlRequest = [serializer requestWithMethod:[self requestMethodName]
                                         URLString:[self.baseURL stringByAppendingString:self.requestURL]
                                        parameters:param
                                             error:&someError];
        //        [request HTTPShouldHandleCookies]; // dafault to YES
        
        // * 添加自定义请求头
        NSMutableDictionary *header = urlRequest.allHTTPHeaderFields.mutableCopy;
        if (!header){
            header = [[NSMutableDictionary alloc] init];
        }
        [header addEntriesFromDictionary:[NXHttpConfigure shareInstance].generalHeaders]; //默认全局的请求头
        [header addEntriesFromDictionary:self.requestHeader]; //当前请求自定义的请求头
        [urlRequest setAllHTTPHeaderFields:header.copy]; //拼接完成的请求头
        
    // 上传文件请求
    } else if (NXRequestUpload == self.requestType) {
         urlRequest = [serializer multipartFormRequestWithMethod:@"POST"
                                                       URLString:[self.baseURL stringByAppendingString:self.requestURL]
                                                      parameters:self.params
                                       constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
              //遍历创建上传文件数据
              [self.uploadFormDatas enumerateObjectsUsingBlock:^(NXUploadFormData *obj, NSUInteger idx, BOOL *stop) {
                  if (obj.fileData) {
                      if (obj.fileName && obj.mimeType) {
                          [formData appendPartWithFileData:obj.fileData name:obj.name fileName:obj.fileName mimeType:obj.mimeType];
                      } else {
                          [formData appendPartWithFormData:obj.fileData name:obj.name];
                      }
                  } else if (obj.fileURL) {
                      NSError *fileError = nil;
                      if (obj.fileName && obj.mimeType) {
                          [formData appendPartWithFileURL:obj.fileURL name:obj.name fileName:obj.fileName mimeType:obj.mimeType error:&fileError];
                      } else {
                          [formData appendPartWithFileURL:obj.fileURL name:obj.name error:&fileError];
                      }
                      if (fileError) {
                          someError = fileError;
                          *stop = YES;
                      }
                  }
              }];
                                       } error:&someError];
    
    // 下载文件请求
    } else if (NXRequestDownload == self.requestType) {
        urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self.baseURL stringByAppendingString:self.requestURL]]];
        NSURL *downloadFileSavePath;
        BOOL isDirectory;
        if(![[NSFileManager defaultManager] fileExistsAtPath:self.downloadSavePath isDirectory:&isDirectory]) {
            isDirectory = NO;
        }
        if (isDirectory) {
            NSString *fileName = [urlRequest.URL lastPathComponent];
            downloadFileSavePath = [NSURL fileURLWithPath:[NSString pathWithComponents:@[self.downloadSavePath, fileName]] isDirectory:NO];
        } else {
            downloadFileSavePath = [NSURL fileURLWithPath:self.downloadSavePath isDirectory:NO];
        }
        self.downloadFileSavedFullPath = downloadFileSavePath;
    }
    
    return someError ? nil : urlRequest.copy;
    
}


#pragma mark - Private Func
/**
 配置请求参数
 
 @return General设置的默认参数及当次请求传入的参数
 */
- (NSDictionary *)generateRequestParameters{
    // 这是在HttpConfigure配置的默认参数
    NSMutableDictionary *commonDic = [NXHttpConfigure shareInstance].generalParameters.mutableCopy;
    if (nil == commonDic) {
        commonDic = [NSMutableDictionary dictionary];
    }
    [commonDic addEntriesFromDictionary:self.params];
    
#warning 加密方式要看后台要求
    if (_isNeedEncrypt) {
        //未完成：对传入字典参数加密
//        NSLog(@"加密后的字典%@", commonDic);
    }
    return commonDic;
}

- (void)addFormDataWithName:(NSString *)name fileData:(NSData *)fileData {
    NXUploadFormData *formData = [NXUploadFormData formDataWithName:name fileData:fileData];
    [self.uploadFormDatas addObject:formData];
}

- (void)addFormDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileData:(NSData *)fileData {
    NXUploadFormData *formData = [NXUploadFormData formDataWithName:name fileName:fileName mimeType:mimeType fileData:fileData];
    [self.uploadFormDatas addObject:formData];
}

- (void)addFormDataWithName:(NSString *)name fileURL:(NSURL *)fileURL {
    NXUploadFormData *formData = [NXUploadFormData formDataWithName:name fileURL:fileURL];
    [self.uploadFormDatas addObject:formData];
}

- (void)addFormDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileURL:(NSURL *)fileURL {
    NXUploadFormData *formData = [NXUploadFormData formDataWithName:name fileName:fileName mimeType:mimeType fileURL:fileURL];
    [self.uploadFormDatas addObject:formData];
}


#pragma mark - Getter
- (NSString *)requestTypeName{
    NXRequestType rType = [self requestType];
    switch (rType) {
        case NXRequestNormal:
            return @"Noraml Request";
        case NXRequestDownload:
            return @"Download Request";
        case NXRequestUpload:
            return @"Upload Request";
        default:
            break;
    }
    return @"GET";
}

- (NSString *)requestMethodName{
    NXHttpMethodType mType = [self requestMethod];
    switch (mType) {
        case NXHttpMethodTypePOST:
            return @"POST";
        case NXHttpMethodTypeGET:
            return @"GET";
        case NXHttpMethodTypePUT:
            return @"PUT";
        case NXHttpMethodTypeDELETE:
            return @"DELETE";
        case NXHttpMethodTypePATCH:
            return @"PATCH";
        default:
            break;
    }
    return @"GET";
}

- (NSString *)baseURL{
    if (!_baseURL) {
        _baseURL = [NXHttpConfigure shareInstance].generalServer;
    }
    return _baseURL;
}

- (NSMutableArray<NXUploadFormData *> *)uploadFormDatas {
    if (!_uploadFormDatas) {
        _uploadFormDatas = [NSMutableArray array];
    }
    return _uploadFormDatas;
}


@end
