//
//  Common.h
//

//  Copyright (c) 2015年  All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Common : NSObject

/** MD5加密 */
+ (NSString *)md5:(NSString *)str;

/** 时间转换函数 */
+ (NSString *)timeFormatted:(long long)totalSeconds;

/** 将16进制颜色代码转换成 UIColor */
+ (UIColor *)getColor:(NSString *)hexColor;

/** 判断字典是否为空 */
+(BOOL)dictIsEmpty:(NSDictionary *)dict;

/** 组合算法 */
+ (NSMutableArray *)zuHeSuanFaDan:(NSMutableArray *)array chooseCount:(int)chooseCount  dan:(NSArray *)dan;

/** 判断是否手机号码 */
+ (BOOL)isMobileNumber:(NSString *)mobileNum;

/** 判断身份证是否合法 */
+ (BOOL)validateIDCardNumber:(NSString *)value;

+ (BOOL)IsChinese:(NSString *)str;

/** 判断字符串是否为空 */
+ (BOOL) isBlankString:(NSString *)string ;
@end
