//
//  ViewController.m
//  NXNetworkManagerDemo
//
//  Created by Design on 2018/11/7.
//  Copyright © 2018年 Design. All rights reserved.
//

#import "ViewController.h"
#import "Common.h"
#import "AESCipher.h"

@interface ViewController ()
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    /// 发送请求前可进行配置
    NXHttpConfig.generalServer = @"https://www.apiopen.top/";
    NXHttpConfig.enableDebugOnlyError = NO;
    
    /// 监听网络环境变化
//    [self monitingNetwork];
    
    /// 加密 & 解密 & ping测试
//    [self testPing];
    
    /// 简单发送某个请求
//    [self sendFirstRequest];
    
    /// 使用block配置参数发送请求
//    [self sendFirstRequestWithBlock];
    
    //// UPLOAD
//    [self uploadFile];
    
    //// DOWNLOAD
//    [self downloadFile];
    
    //// GROUP
//    [self sendGroupRequests];
    
    //// CHAIN
    [self sendChainRequests];
}


- (void)monitingNetwork{
    [NXNetworkReachability monitoringNetworkStatusChange:^(AFNetworkReachabilityStatus status, NSString *statusString) {
        NSLog(@"网络状态改变：%@", statusString);
    }];

}

- (void)testPing{
    NSString *rawStr = @"{\"aaa\" : [\"http://www.baidu.com\", \"https://www.alibabagroup.com\", \"https://www.qq.com\"],\"bbb\" : [\"https://www.tmall.com\", \"https://www.jd.com\", \"https://www.suning.com\"],\"ccc\" : [\"http://www.ctrip.com\", \"https://www.booking.com\"]}";
    NSString *encStr = aesEncryptString(rawStr, Backup_DmPool_Key);
    NSLog(@"\n\n加密的密文：%@\n", encStr);
    NSString *sssd = aesDecryptString(encStr, Backup_DmPool_Key);
    NSData *data = [sssd dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonD = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"\n\n解密密文：%@", jsonD);
    
    //    NSArray *hosts = [[NXHttpDomainManager shareInstance] getDomainPool];
    //    NSLog(@"%@", hosts);
    // ping
    [NXPingManager pingFastestHost:jsonD[Brand] progress:^(CGFloat progress) {
        NXLog(@"=======> 进度%.2lf%%…", progress*100);
    } handler:^(NSString * _Nonnull host) {
        
    }];

}

- (void)sendFirstRequest{
    NXHttpRequest *request = [[NXHttpRequest alloc] init];
    request.baseURL = @"https://www.apiopen.top/";
    request.requestURL = @"satinApi";
    request.params = @{@"type":@"1",
                       @"page":@"1"};
    request.requestMethod = NXHttpMethodTypeGET;
    request.logDebugMsg = YES;
    [[NXHttpRequestManager shareManager] sendHttpRequest:request complete:^(NXHttpResponse *response) {
        NSLog(@"请求完成:%ld",  (long)response.requestId);
    }];
    
}

- (void)sendFirstRequestWithBlock{
    [[NXHttpRequestManager shareManager] sendHttpRequestWithConfigBlock:^(NXHttpRequest *request) {
        request.requestURL = @"satinApi";
        request.params = @{@"type":@"1",
                           @"page":@"1"};
        request.requestMethod = NXHttpMethodTypeGET;
    } complete:^(NXHttpResponse *response) {
        NSLog(@"请求完成:%ld",  (long)response.requestId);
    }];
    
}

- (void)uploadFile{
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"testImage" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    NSData *fileData = UIImageJPEGRepresentation(image, 1.0);
    
    [[NXHttpRequestManager shareManager] sendHttpRequestWithConfigBlock:^(NXHttpRequest *request) {
        request.baseURL = @"https://httpbin.org/";
        request.requestURL = @"post";
        request.requestType = NXRequestUpload;
        [request addFormDataWithName:@"tag" fileName:@"testImg" mimeType:@"image/jpeg" fileData:fileData];
    } progress:^(NSProgress *progress) {
        NSLog(@"=======>上传进度：%.2lf", progress.fractionCompleted);
    } complete:^(NXHttpResponse *response) {
        NSLog(@"=======>上传完成");
    }];
    
}

- (void)downloadFile{
    [[NXHttpRequestManager shareManager] sendHttpRequestWithConfigBlock:^(NXHttpRequest *request) {
        request.baseURL = @"https://httpbin.org/image/png";
        request.requestType = NXRequestDownload;
        request.downloadSavePath = [NSHomeDirectory() stringByAppendingString:@"/Documents/temp.png"];
        request.retryCount = 2;
    } progress:^(NSProgress *progress) {
        NSLog(@"=======>下载进度：%.2lf", progress.fractionCompleted);
    } complete:^(NXHttpResponse *response) {
        NSLog(@"=======> 文件存储路径：%@", response.content);
    }];

}

- (void)sendGroupRequests{
    NSString *uuid = [[NXHttpRequestManager shareManager] sendGroupRequest:^(NXHttpGroupRequest *gRequest) {
        
        for (NSInteger i = 0; i < 8; i ++) {
            NXHttpRequest *request = [[NXHttpRequest alloc] init];
            request.requestURL = @"/getImages";
            request.params = @{@"page":[NSString stringWithFormat:@"%ld", i],
                               @"count":@"2"
                               };
            [gRequest addRequest:request];
        }
        
    } complete:^(NSArray<NXHttpResponse *> * _Nullable responseObjects, BOOL isSuccess) {
        if (isSuccess) { // 所有请求都完成
            for (int i=0; i<responseObjects.count; i++) {
                NXHttpResponse *resp = responseObjects[i];
                NXLog(@"%d ==FINISH== %ld", i, (long)resp.requestId);
            }
        }
    }];
    NXLog(@"ID: %@", uuid);

}

- (void)sendChainRequests{
    [[NXHttpRequestManager shareManager] sendChainRequest:^(NXHttpChainRequest *cRequest) {
        [cRequest onFirst:^(NXHttpRequest *request) {
            request.requestURL = @"/singlePoetry";
            request.logDebugMsg = YES;
        }];
        [cRequest onNext:^(NXHttpRequest * _Nullable request, NXHttpResponse * _Nullable responseObject, BOOL * _Nullable isSent) {
            request.requestURL = @"/singlePoetry";
            NXLog(@"%@, 2 == %@", isSent?@"YES":@"NO", responseObject.content);
        }];
        [cRequest onNext:^(NXHttpRequest * _Nullable request, NXHttpResponse * _Nullable responseObject, BOOL * _Nullable isSent) {
            request.requestURL = @"/singlePoetry";
            NXLog(@"%@, 3 == %@", isSent?@"YES":@"NO", responseObject.content);
        }];
        [cRequest onNext:^(NXHttpRequest * _Nullable request, NXHttpResponse * _Nullable responseObject, BOOL * _Nullable isSent) {
            request.requestURL = @"/singlePoetry";
            NXLog(@"%@, 4 == %@", isSent?@"YES":@"NO", responseObject.content);
        }];
        [cRequest onNext:^(NXHttpRequest * _Nullable request, NXHttpResponse * _Nullable responseObject, BOOL * _Nullable isSent) {
            request.requestURL = @"/singlePoetry";
            NXLog(@"%@, 5 == %@", isSent?@"YES":@"NO", responseObject.content);
        }];
    } complete:^(NSArray<NXHttpResponse *> * _Nullable responseObjects, BOOL isSuccess) {
        if (isSuccess) {
            for (int i=0; i<responseObjects.count; i++) {
                NXHttpResponse *resp = responseObjects[i];
                NXLog(@"%d ==FINISH== %ld", i, resp.requestId);
            }
        }
    }];

}

@end
