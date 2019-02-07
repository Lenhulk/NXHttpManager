//
//  NXUploadFormData.m
//  CaiPiao
//
//  Created by Design on 2019/1/24.
//  Copyright © 2019年 swear. All rights reserved.
//

#import "NXUploadFormData.h"

@implementation NXUploadFormData

+ (instancetype)formDataWithName:(NSString *)name fileData:(NSData *)fileData {
    NXUploadFormData *formData = [[NXUploadFormData alloc] init];
    formData.name = name;
    formData.fileData = fileData;
    return formData;
}

+ (instancetype)formDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileData:(NSData *)fileData {
    NXUploadFormData *formData = [[NXUploadFormData alloc] init];
    formData.name = name;
    formData.fileName = fileName;
    formData.mimeType = mimeType;
    formData.fileData = fileData;
    return formData;
}

+ (instancetype)formDataWithName:(NSString *)name fileURL:(NSURL *)fileURL {
    NXUploadFormData *formData = [[NXUploadFormData alloc] init];
    formData.name = name;
    formData.fileURL = fileURL;
    return formData;
}

+ (instancetype)formDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileURL:(NSURL *)fileURL {
    NXUploadFormData *formData = [[NXUploadFormData alloc] init];
    formData.name = name;
    formData.fileName = fileName;
    formData.mimeType = mimeType;
    formData.fileURL = fileURL;
    return formData;
}

@end
