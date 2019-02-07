//
//  NXHttpLogger.m
//  NXNetworkManagerDemo
//
//  Created by Design on 2018/11/8.
//  Copyright © 2018年 Design. All rights reserved.
//

#import "NXHttpLogger.h"
#import "NXHttpRequest.h"
#import "NSString+Base64.h"
#import "NXHttpConfigure.h"

@implementation NXHttpLogger

/**
 输出签名
 */
+ (void)logSignInfoWithString:(NSString *)sign
{
    NSMutableString *logString = [NSMutableString stringWithString:@"\n\n**************************************************************\n*                       签名参数          "
                                  @"                    *\n**************************************************************\n\n"];
    
    [logString appendFormat:@"%@", sign];
    [logString appendFormat:@"\n\n**************************************************************\n*                         签名参数                            "
     @"*\n**************************************************************\n\n\n\n"];
    
    NXLog(@"%@", logString);
}


+ (void)logDebugInfoWhenNetworkFail{
    NSString *logString = @"\n\n**************************************************************\n*                      无网络连接 请求失败         "
                                  @"              *\n**************************************************************\n\n";
    NXLog(@"%@", logString);
}


+ (void)logDebugInfoWithRequest:(NXHttpRequest *)request Task:(NSURLSessionTask *)sessionTask ResponseData:(id)data duration:(int)interval error:(NSError *)error{
    
    if (!request.logDebugMsg) {
        //当前请求 “不需要直接打印”
        if (!NXHttpConfig.enableDebug || (NXHttpConfig.enableDebug && NXHttpConfig.enableDebugOnlyError && error==nil)) {
            //请求配置 “不允许debug” 或 “只允许在有错误的时候debug但是当前无错误(error)”
            return;
        }
    }
    
    NSMutableString *logString = [[NSMutableString alloc] initWithFormat:@"\n\n**************************************************************\n*                 Request Start (TaskId:%lu)  "
                                  @"                 *\n**************************************************************", (unsigned long)sessionTask.taskIdentifier];
    [logString appendFormat:@"\n\nRequest Type:\t\t%@", [request requestTypeName]];
    [logString appendFormat:@"\n\nRequest Method:\t\t%@", [request requestMethodName]];
    [logString appendFormat:@"\n\n请求耗时:\t\t\t\t%d秒", interval];
    [logString appendFormat:@"\n\nBase URL:\t\t\t%@", request.baseURL];
    [logString appendFormat:@"\nURL Path:\t\t\t%@", request.requestURL];
    [logString appendFormat:@"\n\nRequest Raw Params:\n%@", request.params];
    NSMutableDictionary *mHeaderDic = [NXHttpConfigure shareInstance].generalHeaders.mutableCopy;
    [mHeaderDic addEntriesFromDictionary:request.requestHeader];
//    [logString appendFormat:@"\n\nRequset Header defined by User:\n%@", mHeaderDic];
    
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)sessionTask.response;
    NSURLRequest *finalRequest = sessionTask.originalRequest;
    
//    [logString appendFormat:@"\n\nHTTP URL:\n\t%@", finalRequest.URL];
    [logString appendFormat:@"\n\nHTTP Request Header:\n%@", finalRequest.allHTTPHeaderFields ? finalRequest.allHTTPHeaderFields : @"\t\t\t\t\tN/A"];
    [logString appendFormat:@"\n\nHTTP Response Header:\n%@", response.allHeaderFields ? response.allHeaderFields : @"\t\t\t\t\tN/A"];
    
#warning 需要与后端协议
    NSString *jsonString = [[NSString alloc] initWithData:finalRequest.HTTPBody encoding:NSUTF8StringEncoding];
//    if (jsonString.length > 0)
//    {
//        NSArray *pas = [jsonString componentsSeparatedByString:@"&"];
//        for (NSString *key in pas)
//        {
//            NSArray *p2 = [key componentsSeparatedByString:@"="];
//            // 解密 加密参数
//            if (p2.count >= 2 && [p2[0] isEqualToString:@"params2"])
//            {
//                jsonString = p2[1];
//                jsonString = [jsonString base64DecodedString];
//            }
//            // 公共参数
//            else
//            {
//            }
//        }
//    }
    [logString appendFormat:@"\n\nHTTP Body:\n\t%@", jsonString.stringByRemovingPercentEncoding ? jsonString.stringByRemovingPercentEncoding : @"\t\t\t\tN/A"];
    [logString appendFormat:@"\n\nHTTP Status:\t%ld\t(%@)", (long)response.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode]];
    [logString appendFormat:@"\n\nContent(String):\n\t%@",  [data isKindOfClass:[NSData class]] ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : data]; //容错？
    if (error)
    {
        [logString appendFormat:@"Error Domain:\t\t\t\t\t\t\t%@\n", error.domain];
        [logString appendFormat:@"Error Domain Code:\t\t\t\t\t\t%ld\n", (long)error.code];
        [logString appendFormat:@"Error Localized Description:\t\t\t%@\n", error.localizedDescription];
        [logString appendFormat:@"Error Localized Failure Reason:\t\t\t%@\n", error.localizedFailureReason];
        [logString appendFormat:@"Error Localized Recovery Suggestion:\t%@\n", error.localizedRecoverySuggestion];
    }
    
    [logString appendFormat:@"\n\n==============================================================\n=                    Request End (TaskId:%lu)                  "
     @"=\n==============================================================\n\n\n", (unsigned long)sessionTask.taskIdentifier];
    
    NXLog(@"%@", logString);
}

@end
