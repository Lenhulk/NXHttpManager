//
//  NXHttpConstant.h
//  NXNetworkManagerDemo
//
//  Created by Design on 2018/11/7.
//  Copyright © 2018年 Design. All rights reserved.
//

#ifndef NXHttpConstant_h
#define NXHttpConstant_h

@class NXHttpResponse, NXHttpRequest, NXHttpGroupRequest, NXHttpChainRequest;

//备用池KEY
#define Backup_DmPool_Key @"1234567890abcdef"

#define NX_SAFE_BLOCK(BlockName, ...) ({ !BlockName ? nil : BlockName(__VA_ARGS__); })

#ifdef DEBUG
#define NXLog(FORMAT, ...) fprintf(stderr, "\n%s : line %d\n%s", [[[NSString stringWithUTF8String: __FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat: FORMAT, ## __VA_ARGS__] UTF8String]);
#else
#define NXLog(FORMAT, ...) nil
#endif

typedef NS_ENUM(NSInteger, NXRequestType) {
    NXRequestNormal    = 0,    //!< Normal HTTP request type, such as GET, POST, ...
    NXRequestUpload    = 1,    //!< Upload request type
    NXRequestDownload  = 2,    //!< Download request type
};

typedef NS_ENUM(NSUInteger, NXHttpMethodType) {
    NXHttpMethodTypeGET = 0,
    NXHttpMethodTypePOST,
    NXHttpMethodTypeHEAD,
    NXHttpMethodTypePUT,
    NXHttpMethodTypeDELETE,
    NXHttpMethodTypePATCH
};

typedef NS_ENUM(NSUInteger, NXHttpResponseStatus) {
    NXHttpResponseStatusError = 0,
    NXHttpResponseStatusSuccess
};

typedef void(^NXProgressBlock)(NSProgress *progress);

typedef void(^NXHttpResponseBlock)(NXHttpResponse *response);
typedef void(^NXGroupResponseBlock)(NSArray<NXHttpResponse *> * _Nullable responseObjects, BOOL isSuccess);

/// isSent: 上个网络请求是否完成
typedef void(^NXNextBlock)(NXHttpRequest * _Nullable request, NXHttpResponse * _Nullable responseObject, BOOL * _Nullable isSent);

typedef void(^NXHttpRequestConfigBlock)(NXHttpRequest *request);
typedef void(^NXGroupRequestConfigBlock)(NXHttpGroupRequest *gRequest);
typedef void(^NXChainRequestConfigBlock)(NXHttpChainRequest *cRequest);

#endif /* NXHttpConstant_h */
