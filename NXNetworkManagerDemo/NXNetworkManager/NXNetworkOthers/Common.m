//
//  Common.m
//
//
// 
//  Copyright (c) 2015年 All rights reserved.
//

#import "Common.h"
//#import "JCTZModel.h"
#import <CommonCrypto/CommonDigest.h>

@implementation Common


#pragma mark - MD5加密
/**
 *  MD加密
 *
 *  @param str 加密字符串
 *
 *  @return 加密后的字符串
 */
+ (NSString *)md5:(NSString *)str
{
    
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    uint32_t leng = (uint32_t)strlen(cStr);
    
    CC_MD5(cStr, leng, result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}


/** 判断字符串自否为空 */
+ (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}


#pragma mark - 秒转换日期函数
+ (NSString *)timeFormatted:(long long)totalSeconds
{
    
    NSDate  *date = [NSDate dateWithTimeIntervalSince1970:totalSeconds];
    
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    
    NSInteger interval = [zone secondsFromGMTForDate: date];
    
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    
    // NSRange range = NSMakeRange(0, 10);
    
    return [NSString stringWithFormat:@"%@", localeDate];
    //[[NSString stringWithFormat:@"%@", localeDate] substringWithRange:range];
}


/**
 * 将16进制颜色转换成UIColor
 *
 **/
+ (UIColor *)getColor:(NSString *)hexColor {
    
    if(hexColor.length == 7 )
    {
        unsigned int red,green,blue;
        NSRange range;
        range.length = 2;
        
        range.location = 1;
        [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
        
        range.location = 3;
        [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
        
        range.location = 5;
        [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
        
        return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green / 255.0f) blue:(float)(blue / 255.0f) alpha:1.0f];
        
    }
    else
    {
        return [UIColor grayColor];
        
    }
    
    
}


/**
 *  判断字典是否为空
 *
 *  @param dict 需要判断的字典
 *
 *  @return yes - 非空，  no － 空
 */
+(BOOL)dictIsEmpty:(NSDictionary *)dict
{
    
    if (dict != nil && ![dict isKindOfClass:[NSNull class]] && dict.count != 0)
    {
        
        return YES;
    }
    
    return NO;
    
}

/**
 *  组合算法，取出 m个数里面 N 个的组合
 *
 *  @param array  数组
 *  @param m     组合个数
 *
 *  @return 返回有多少总组合的数组
 */

+ (NSMutableArray *)zuHeSuanFaDan:(NSMutableArray *)array chooseCount:(int)chooseCount  dan:(NSArray *)dan
{
    int arrayCount = (int)[array count];
    
    if (chooseCount > arrayCount)
    {
        return nil;
    }
    
//    MyLog(@"从1到%d中取%d个数的组合。。。",arrayCount,chooseCount);
    
    NSMutableArray *allChooseArray = [[NSMutableArray alloc] init];
    NSMutableArray *retArray = [array copy];
    
    // (1,1,1,0,0),, array = (1,1,0,0,0,0,0)
    // m = 2 ,  n = 7
    for(int i=0;i < arrayCount;i++)
    {
        if (i < chooseCount)
        {
            [array replaceObjectAtIndex:i withObject:@"1"];
        }
        else
        {
            [array replaceObjectAtIndex:i withObject:@"0"];
        }
        
    }
    
    // MyLog(@"replace Array = %@", array);
    
    NSMutableArray *firstArray = [[NSMutableArray alloc] init];
    
    //n = 7; , m =2 ,
    //array = (1,1,0,0,0,0,0)
    //firstArray = @"A", @"B"
    for(int i=0; i<arrayCount; i++)
    {
        if ([[array objectAtIndex:i] intValue] == 1)
        {
            [firstArray addObject:[retArray objectAtIndex:i]];
            // MyLog(@"%d ",i+1);
        }
    }
    
    int chechk = [self checkAisB:firstArray arrayB:dan];
    
    //  MyLog(@"chechk = %d", chechk);
    if (chechk) {
        // [allChooseArray addObject:middleArray];
        [allChooseArray addObject:firstArray];
    }
    
    //[allChooseArray addObject:firstArray];
    //  MyLog(@"============");
    
    int count = 0;
    //n = 7
    //array = (1,1,0,0,0,0,0)
    for(int i = 0; i < arrayCount-1; i++)
    {
        //2, //array = (1,0,1,0,0,0,0)
        if ([[array objectAtIndex:i] intValue] == 1 && [[array objectAtIndex:(i + 1)] intValue] == 0)
        {
            [array replaceObjectAtIndex:i withObject:@"0"];
            [array replaceObjectAtIndex:(i + 1) withObject:@"1"];
            
            
            //MyLog(@"%@", arrayC);
            //1, array = (1,0,1,0,0,0,0)
            
            // i = 1, (1,1,0,1,0)
            for (int k = 0; k < i; k++)
            {
                if ([[array objectAtIndex:k] intValue] == 1)
                {
                    count ++;
                }
            }
            
            if (count > 0)
            {
                //i = 1
                for (int k = 0; k < i; k++)
                {
                    //count = 1;
                    if (k < count)
                    {
                        // k = 1, (1,1,0,1,0)
                        //array = (1,0,1,0,0,0,0)
                        [array replaceObjectAtIndex:k withObject:@"1"];
                    }
                    else
                    {
                        [array replaceObjectAtIndex:k withObject:@"0"];
                    }
                }
            }
            
            NSMutableArray *middleArray = [[NSMutableArray alloc] init];
            //n = 7
            for (int k = 0; k < arrayCount; k++)
            {
                if ([[array objectAtIndex:k] intValue] == 1)
                {
                    //   MyLog(@"%d ",k+1);
                    //                    [middleArray addObject:[NSString stringWithFormat:@"%d",k + 1]];
                    [middleArray addObject:[retArray objectAtIndex:k]];
                }
                
                
            }
            
            
            if ([self checkAisB:middleArray arrayB:dan] == YES) {
                
                [allChooseArray addObject:middleArray];
            }
            
            // [allChooseArray addObject:middleArray];
            i = -1;
            count = 0;
        }
    }
    
    return allChooseArray;
    
    
}


/**
 *  判断数组A 中是否包含数组B的元素
 *
 *  @param arrayA 原数组
 *  @param arrayB 被包含的数组
 *
 *  @return yes/no
 */
+ (BOOL)checkAisB:(NSArray *)arrayA arrayB:(NSArray *)arrayB
{
    
    int  arrayACount = (int)[arrayA count];
    int  arrayBCount = (int)[arrayB count];
    int i;
    int j;
    //a = 2,b = 1
    
    for ( i = 0; i < arrayBCount; i++)
    {
        
        //循环判断数组A 中是否包含数组B[i]
        for ( j = 0; j < arrayACount; j++)
        {
            
            //  MyLog(@"arrayA[j]%@ = arrayB[i]%@", arrayA[j],arrayB[i]);
            if (arrayA[j] == arrayB[i])
            {
                //       MyLog(@"判断成功");
                break;
            }
            else
            {
                //     MyLog(@"判断失败");
            }
            
            
        }
        
        if (j == arrayACount)
        {
            // MyLog(@"返回0");
            return NO;
        }
    }
    
    return YES;
    
    
}



/**
 *  判断手机号码是否合法
 *
 *  @param mobileNum 需要判断的字符
 *
 *  @return  YES  or NO
 */
+ (BOOL)isMobileNumber:(NSString *)mobileNum
{
    //153,181,183, 184,   176 177 178
    
    /* 判断是否是电话号码 <br/>
     * 130 131 132 133 134x（0-8）135 136 137 138 139 (1349卫星电话)<br/>
     * 150 151 152 153 155 156 157 158 159 (154 暂时未启用)<br/>
     * 176 177 178 (最新4G段位号)<br/>
     * 180 181 182 183 184 185 186 187 188 189
     */
    
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    // NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    // NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    //    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    // NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSString *Counst = @"^1[3|4|5|7|8][0-9]\\d{8}$";
    
    //    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    //    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    //    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    //    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    
    NSPredicate *regextestCounst = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", Counst];
    
    //    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
    //        || ([regextestcm evaluateWithObject:mobileNum] == YES)
    //        || ([regextestct evaluateWithObject:mobileNum] == YES)
    //        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    if ([regextestCounst evaluateWithObject:mobileNum] == YES)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL)validateIDCardNumber:(NSString *)value {
    
    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    int length =0;
    if (!value) {
        return NO;
    }else {
        length = (int)value.length;
        
        if (length !=15 && length !=18) {
            return NO;
        }
    }
    // 省份代码
    NSArray *areasArray =@[@"11",@"12", @"13",@"14", @"15",@"21", @"22",@"23", @"31",@"32", @"33",@"34", @"35",@"36", @"37",@"41", @"42",@"43", @"44",@"45", @"46",@"50", @"51",@"52", @"53",@"54", @"61",@"62", @"63",@"64", @"65",@"71", @"81",@"82", @"91"];
    
    NSString *valueStart2 = [value substringToIndex:2];
    BOOL areaFlag =NO;
    for (NSString *areaCode in areasArray) {
        if ([areaCode isEqualToString:valueStart2]) {
            areaFlag = YES;
            break;
        }
    }
    
    if (!areaFlag) {
        return false;
    }
    
    
    NSRegularExpression *regularExpression;
    NSUInteger numberofMatch;
    
    int year =0;
    switch (length) {
        case 15:
            
            year = [value substringWithRange:NSMakeRange(6,2)].intValue +1900;
            
            if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {
                
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$"
                                                                        options:NSRegularExpressionCaseInsensitive
                                                                          error:nil];//测试出生日期的合法性
            }else {
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$"
                                                                        options:NSRegularExpressionCaseInsensitive
                                                                          error:nil];//测试出生日期的合法性
            }
            numberofMatch = [regularExpression numberOfMatchesInString:value
                                                               options:NSMatchingReportProgress
                                                                 range:NSMakeRange(0, value.length)];
            
            //  [regularExpression release];
            
            if(numberofMatch >0) {
                return YES;
            }else {
                return NO;
            }
        case 18:
            
            year = [value substringWithRange:NSMakeRange(6,4)].intValue;
            if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {
                
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}[0-9Xx]$"
                                                                        options:NSRegularExpressionCaseInsensitive
                                                                          error:nil];//测试出生日期的合法性
            }else {
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}[0-9Xx]$"
                                                                        options:NSRegularExpressionCaseInsensitive
                                                                          error:nil];//测试出生日期的合法性
            }
            numberofMatch = [regularExpression numberOfMatchesInString:value
                                                               options:NSMatchingReportProgress
                                                                 range:NSMakeRange(0, value.length)];
            
            // [regularExpression release];
            
            if(numberofMatch >0) {
                int S = ([value substringWithRange:NSMakeRange(0,1)].intValue + [value substringWithRange:NSMakeRange(10,1)].intValue) *7 + ([value substringWithRange:NSMakeRange(1,1)].intValue + [value substringWithRange:NSMakeRange(11,1)].intValue) *9 + ([value substringWithRange:NSMakeRange(2,1)].intValue + [value substringWithRange:NSMakeRange(12,1)].intValue) *10 + ([value substringWithRange:NSMakeRange(3,1)].intValue + [value substringWithRange:NSMakeRange(13,1)].intValue) *5 + ([value substringWithRange:NSMakeRange(4,1)].intValue + [value substringWithRange:NSMakeRange(14,1)].intValue) *8 + ([value substringWithRange:NSMakeRange(5,1)].intValue + [value substringWithRange:NSMakeRange(15,1)].intValue) *4 + ([value substringWithRange:NSMakeRange(6,1)].intValue + [value substringWithRange:NSMakeRange(16,1)].intValue) *2 + [value substringWithRange:NSMakeRange(7,1)].intValue *1 + [value substringWithRange:NSMakeRange(8,1)].intValue *6 + [value substringWithRange:NSMakeRange(9,1)].intValue *3;
                int Y = S %11;
                NSString *M =@"F";
                NSString *JYM =@"10X98765432";
                M = [JYM substringWithRange:NSMakeRange(Y,1)];// 判断校验位
                if ([M isEqualToString:[value substringWithRange:NSMakeRange(17,1)]]) {
                    return YES;// 检测ID的校验位
                }else {
                    return NO;
                }
                
            }else {
                return NO;
            }
        default:
            return false;
    }
}


/**
 *  判断字符串是否全是中文
 *
 *  @param str 字符串
 *
 *  @return yes  no
 */
+ (BOOL)IsChinese:(NSString *)str {
    
    NSInteger length = str.length;
    
    for(int i=0; i< length;i++){
        int a = [str characterAtIndex:i];
        if( !(a > 0x4e00 && a < 0x9fff))
        {
            return NO;
        }
        
    }
    return YES;
    
}
@end
