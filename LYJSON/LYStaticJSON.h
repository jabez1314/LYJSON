//
//  LYStaticJSON.h
//  LYJSON
//
//  Created by john on 2019/5/25.
//  Copyright © 2019 jabez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYJSONType.h"

NS_ASSUME_NONNULL_BEGIN

// immutable json object
@interface LYStaticJSON : NSObject

@property (class, strong, nonatomic, readonly) LYStaticJSON *null;

@property (nonatomic, strong, readonly, nullable) id rawObject;
@property (nonatomic, assign, readonly) LYJSONType type;
@property (nonatomic, strong, nullable) NSError *error;

@property (nonatomic, strong, readonly, nullable) NSString *string;
@property (nonatomic, strong, readonly) NSString *stringValue;

@property (nonatomic, strong, readonly, nullable) NSNumber *number;
@property (nonatomic, strong, readonly, nullable) NSNumber *numberValue;

@property (nonatomic, strong, readonly, nullable) NSArray<LYStaticJSON *> *array;
@property (nonatomic, strong, readonly) NSArray<LYStaticJSON *> *arrayValue;
@property (nonatomic, strong, nullable) NSArray *arrayObject; // 原数组
@property (nonatomic, strong, readonly, nonnull) NSArray *arrayObjectValue; // 原数组，如果非数组，返回空数组

@property (nonatomic, strong, readonly, nullable) NSDictionary<NSString *, LYStaticJSON *> *dictionary;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, LYStaticJSON *> *dictionaryValue;
@property (nonatomic, strong, readonly, nullable) NSDictionary *dictionaryObject;
@property (nonatomic, strong, nonnull, readonly) NSDictionary *dictionaryObjectValue;

@property (nonatomic, assign, readonly) char charValue;
@property (nonatomic, assign, readonly) unsigned char unsignedCharValue;
@property (nonatomic, assign, readonly) short shortValue;
@property (nonatomic, assign, readonly) unsigned short unsignedShortValue;
@property (nonatomic, assign, readonly) int intValue;
@property (nonatomic, assign, readonly) unsigned int unsignedIntValue;
@property (nonatomic, assign, readonly) long longValue;
@property (nonatomic, assign, readonly) unsigned long unsignedLongValue;
@property (nonatomic, assign, readonly) long long longLongValue;
@property (nonatomic, assign, readonly) unsigned long long unsignedLongLongValue;
@property (nonatomic, assign, readonly) float floatValue;
@property (nonatomic, assign, readonly) double doubleValue;
@property (nonatomic, assign, readonly) BOOL boolValue;
@property (nonatomic, assign, readonly) NSInteger integerValue;
@property (nonatomic, assign, readonly) NSUInteger unsignedIntegerValue;

- (NSString *)stringValueWhereEmpty:(NSString *)defaultValue NS_SWIFT_NAME(stringValue(whereEmpty:));

+ (instancetype)jsonWithData:(NSData *)data;

+ (instancetype)jsonWithString:(NSString *)jsonString;

+ (instancetype)jsonWithObject:(id _Nullable)object;

// support NSObject, LYJSON, LYStaticJSON
- (instancetype)initWithObject:(id _Nullable)object;

#pragma mark - for array
- (instancetype)objectAtIndexedSubscript:(NSInteger)idx;

#pragma mark - for Dictionary
- (instancetype)objectForKeyedSubscript:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
