//
//  NXUploadFormData.h
//  CaiPiao
//
//  Created by Design on 2019/1/24.
//  Copyright © 2019年 swear. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 `NXUploadFormData` 是描述和汇总上传文件数据的类, 有关详细信息, 请参阅 "AFMultipartFormData" 协议。
 */
@interface NXUploadFormData : NSObject

/**
 与上传数据关联的名称  不能为空
 */
@property (nonatomic, copy, nonnull) NSString *name;

/**
 要在 "Content-Disposition" 标头中使用的文件名  此属性不建议为空
 */
@property (nonatomic, copy, nullable) NSString *fileName;

/**
 MIME type of the file data.  此属性不建议为空
 */
@property (nonatomic, copy, nullable) NSString *mimeType;

/**
 要编码并追加到表单数据的数据, 它优先于 "fileURL"
 */
@property (nonatomic, strong, nullable) NSData *fileData;

/**
 要上传的文件相对应的 url, 当 "fileData" 已经定义时, 将忽略该属性
 */
@property (nonatomic, strong, nullable) NSURL *fileURL;

// IMPORTANT: Either of the `fileData` and `fileURL` should not be `nil`, and the `fileName` and `mimeType` must both be `nil` or assigned at the same time,

///-----------------------------------------------------
/// @name Quickly Class Methods For Creates A New Object
///-----------------------------------------------------

+ (instancetype)formDataWithName:(NSString *)name fileData:(NSData *)fileData;
+ (instancetype)formDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileData:(NSData *)fileData;
+ (instancetype)formDataWithName:(NSString *)name fileURL:(NSURL *)fileURL;
+ (instancetype)formDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileURL:(NSURL *)fileURL;

@end

NS_ASSUME_NONNULL_END
