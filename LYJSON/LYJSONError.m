//
//  LYJSONError.m
//  JSON
//
//  Created by Jabez on 2018/9/27.
//  Copyright © 2018 ly. All rights reserved.
//

#import "LYJSONError.h"

@implementation LYJSONError

+ (NSError *)errorWithCode:(NSInteger)code description:(NSString *)decripition {
    return [NSError errorWithDomain:@"com.lyjson.lyjson" code:code userInfo:@{NSLocalizedDescriptionKey: decripition}];
}

+ (NSError *)unsupportedType { return [self errorWithCode:999 description:@"类型不支持"]; }

+ (NSError *)indexOutOfBounds { return [self errorWithCode:900 description:@"index越界"]; }

+ (NSError *)elementTooDeep { return [self errorWithCode:902 description:@"元素层级过多"]; }

+ (NSError *)wrongType { return [self errorWithCode:901 description:@"错误类型"]; }

+ (NSError *)notExist { return [self errorWithCode:500 description:@"key不存在"]; }

+ (NSError *)invalidJSON { return [self errorWithCode:490 description:@"JSON非法"]; }

@end
