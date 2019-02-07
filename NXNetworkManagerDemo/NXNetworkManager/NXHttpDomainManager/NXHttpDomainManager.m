//
//  NXDomainManager.m
//  NXNetworkManagerDemo
//
//  Created by Design on 2018/11/7.
//  Copyright © 2018年 Design. All rights reserved.
//

#import "NXHttpDomainManager.h"
#import "NXHttpConfigure.h"

@interface NXHttpDomainManager()
@property (nonatomic, strong) NSMutableDictionary *currentDomainDic;
@property (nonatomic, strong) NSString *backupDmPool;
@end

@implementation NXHttpDomainManager

+ (void)load{
    // 启动时配置
//    [NXHttpDomainMgr setupDomainWhenLaunch];
    // 配置主域名
//    NSString *useDomain = [NXHttpDomainMgr getMainDomain];
//    NXLog(@" =====> GeneralServer:%@", useDomain);
//    [NXHttpConfig setGeneralServer:useDomain];
//    // 配置备用域名池
//    [NXHttpDomainMgr requestbackupDomainPoolUrl];
}

+ (instancetype)shareInstance{
    static NXHttpDomainManager *instance = nil;
    if (!instance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[NXHttpDomainManager alloc] init];
            instance.currentDomainDic = [NSMutableDictionary dictionary];
            
        });
    }
    return instance;
}


#pragma mark - REQUEST
/// 获取配置文件  启动时自动
- (void)setupDomainWhenLaunch{
    BOOL fetchDomainSuccess = NO;
    
    NSString *url = [self domainConfigUrl];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    NSError *e;
    NSURLResponse *response = [[NSURLResponse alloc] init];
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&e];
    if (!e && received) {
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingAllowFragments error:nil];
        NSDictionary *domains = dictionary[@"data"];
        if (domains) {
            [self saveNewestDomainDic:domains];
            fetchDomainSuccess = YES;
            NXLog(@"\n\n ********************** fetch domain success : \n%@\n\n", domains);
            
        }else{
            NXLog(@"\n\n ********************** fetch domain fail, use default domain : \n%@\n\n", DefaultDomain);
        }
    }else{
        NXLog(@"\n\n ********************** fetch domain fail, error is : \n%@\n\n", e.localizedDescription);
    }
    
    if (fetchDomainSuccess == NO) {
        NSString *url = [self backupDomainConfigUrl];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
        NSError *e;
        NSURLResponse *response = [[NSURLResponse alloc] init];
        NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&e];
        NXLog(@"%@", response);
        if (!e && received) {
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingAllowFragments error:nil];
            NSDictionary *domains = dictionary[@"data"];
            if (domains) {
                [self saveNewestDomainDic:domains];
                fetchDomainSuccess = YES;
                NXLog(@"\n\n ********************** fetch backup domain success : \n%@\n\n", domains);
            }else{
                NXLog(@"\n\n ********************** fetch backup domain fail, use default domain : \n%@\n\n", DefaultDomain);
            }
        }
    }
}

/// 获取备用域名  启动时自动
- (void)requestbackupDomainPoolUrl{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *buUrl = [self backupDomainPoolUrl];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:buUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_semaphore_signal(semaphore);
        if (error) {
            NXLog(@"\n\n  ******************* fetch DomainPool fail, error is : \n%@\n\n", error.localizedDescription);
        } else {
            NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            self.backupDmPool = dataStr;
            NXLog(@"\n\n  ******************* fetch DomainPool Success : \n%@\n\n", dataStr);
        }
    }];
    [task resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)saveNewestDomainDic:(NSDictionary *)dic{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *keys = [dic allKeys];
        for (id eachKey in keys) {
            self->_currentDomainDic[eachKey] = dic[eachKey];
        }
    });
}


#pragma mark - GET

- (NSString *)getMainDomain{
    NSString *url = (self.currentDomainDic[USING_DOMAIN_MODE]) ? (self.currentDomainDic[USING_DOMAIN_MODE]) : DefaultDomain;
    return url;
}

- (NSArray *)getDomainPool{
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        if (!self.backupDmPool) {
            [self requestbackupDomainPoolUrl];
        }
    });
    
    if (self.backupDmPool == nil) {
        // 外部处理 未能成功获取到备用线路
        return nil;
    }
    
    NSString *decStr = aesDecryptString(self.backupDmPool, Backup_DmPool_Key);
    NSData *hostData = [decStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *hostDict = [[NSJSONSerialization JSONObjectWithData:hostData options:NSJSONReadingAllowFragments error:nil] mutableCopy];
    NSMutableArray *hostPool = hostDict[Brand];
    NXLog(@"\n\n  *************************  域名池数据: \n\n%@\n\n", hostPool);
    return hostPool;
}

- (BOOL)isChatroomOn{
    return [self.currentDomainDic[@"chatroomOn"] boolValue];
}
            
- (NSInteger)getChatroomLowestVIPLevel{
    return [self.currentDomainDic[@"chatroomVIPLevel"] integerValue];
}


#pragma mark - URL
- (NSString *)backupDomainPoolUrl{
    return BackupDomainPoolUrl;
}

- (NSString *)domainConfigUrl{
    return DomainUrl;
}

- (NSString *)backupDomainConfigUrl{
    return BackupDomainUrl;
}

@end
