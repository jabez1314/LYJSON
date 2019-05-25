//
//  LYJSON.h
//  UdoTestProgress
//
//  Created by Jabez on 06/02/2018.
//  Copyright © 2018 Udo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYJSONType.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * LYJSON: 安全的处理json，字典、数组等类型
 mutable json object
 */
@interface LYJSON : NSObject

@property (nonatomic, strong, readonly, nullable) id object;
@property (nonatomic, assign, readonly) LYJSONType type;

@property (class, nonatomic, readonly) LYJSON *null;

@property (nonatomic, nullable) NSNull *null;

@property (nonatomic, readonly, nullable) NSString *rawString;

@property (nonatomic, nullable, readonly) NSArray<LYJSON *> *array;
@property (nonatomic, readonly) NSArray<LYJSON *> *arrayValue;
@property (nonatomic, nullable) NSArray *arrayObject; // 原数组
@property (nonatomic, readonly, nonnull) NSArray *arrayObjectValue; // 原数组，如果非数组，返回空数组

@property (nonatomic, nullable) NSDictionary<NSString *, LYJSON *> *dictionary;
@property (nonatomic, readonly) NSDictionary<NSString *, LYJSON *> *dictionaryValue;
@property (nonatomic, nullable) NSDictionary *dictionaryObject;
@property (nonatomic, readonly, nonnull) NSDictionary *dictionaryObjectValue;

@property (nonatomic, nullable) NSString *string;
@property (nonatomic, readonly) NSString *stringValue;

@property (nonatomic, nullable) NSNumber *number;
@property (nonatomic, nullable) NSNumber *numberValue;

#pragma mark - Number
@property (nonatomic, assign) char charValue;
@property (nonatomic, assign) unsigned char unsignedCharValue;
@property (nonatomic, assign) short shortValue;
@property (nonatomic, assign) unsigned short unsignedShortValue;
@property (nonatomic, assign) int intValue;
@property (nonatomic, assign) unsigned int unsignedIntValue;
@property (nonatomic, assign) long longValue;
@property (nonatomic, assign) unsigned long unsignedLongValue;
@property (nonatomic, assign) long long longLongValue;
@property (nonatomic, assign) unsigned long long unsignedLongLongValue;
@property (nonatomic, assign) float floatValue;
@property (nonatomic, assign) double doubleValue;
@property (nonatomic, assign) BOOL boolValue;
@property (nonatomic, assign) NSInteger integerValue;
@property (nonatomic, assign) NSUInteger unsignedIntegerValue;

@property (nonatomic, nullable) NSURL *url;

@property (nonatomic, readonly, nullable) NSError *error;
@property (nonatomic, readonly, getter=isExists) BOOL exists;

+ (instancetype)jsonWithData:(NSData *)data;

+ (instancetype)jsonWithString:(NSString *)jsonString;

+ (instancetype)jsonWithObject:(id _Nullable)object;

- (instancetype)initWithObject:(id _Nullable)object;

#pragma mark - String
- (nullable NSString *)rawString;
- (nullable NSString *)rawStringWithOptions:(NSJSONWritingOptions)options;
- (nullable NSData *)rawDataWithOptions:(NSJSONWritingOptions)options error:(NSError **)error;

- (NSString *)stringValueWhereEmpty:(NSString *)defaultValue NS_SWIFT_NAME(stringValue(whereEmpty:));

#pragma mark - Data;
- (nullable NSData *)rawData;
- (nullable NSData *)rawDataWithOptions:(NSJSONWritingOptions)options;

#pragma mark - for array
- (LYJSON *)objectAtIndexedSubscript:(NSInteger)idx;
- (void)setObject:(id _Nullable)obj atIndexedSubscript:(NSInteger)idx;

#pragma mark - for Dictionary
- (LYJSON *)objectForKeyedSubscript:(NSString *)key;
- (void)setObject:(id _Nullable)obj forKeyedSubscript:(NSString *)key;

@end

FOUNDATION_STATIC_INLINE LYJSON *LYJSONObject(id _Nullable obj) {
    return [LYJSON jsonWithObject:obj];
}

NS_ASSUME_NONNULL_END;
