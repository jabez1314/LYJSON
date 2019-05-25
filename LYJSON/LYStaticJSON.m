//
//  LYStaticJSON.m
//  LYJSON
//
//  Created by john on 2019/5/25.
//  Copyright © 2019 jabez. All rights reserved.
//

#import "LYStaticJSON.h"
#import "LYJSON.h"

@interface LYStaticJSON()

@property (nonatomic, strong, readwrite, nullable) id object;

@end

@implementation LYStaticJSON

+ (instancetype)jsonWithData:(NSData *)data {
    id object = nil;
    if ([data isKindOfClass:[NSData class]]) {
        object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    }
    return [self jsonWithObject:object];
}

+ (instancetype)jsonWithString:(NSString *)jsonString {
    if (nil == jsonString) {
        return [self jsonWithObject:[NSNull null]];
    }
    
    NSData * data = [[jsonString description] dataUsingEncoding:NSUTF8StringEncoding];
    if (nil != data) {
        return [self jsonWithData:data];
    }
    return [self jsonWithObject:[NSNull null]];
}

+ (instancetype)jsonWithObject:(id _Nullable)object {
    return [[self alloc] initWithObject:object];
}

- (instancetype)initWithObject:(id _Nullable)object {
    if (self = [super init]) {
        self.object = object;
    }
    return self;
}

#pragma mark - Null

+ (LYStaticJSON *)null { return [LYStaticJSON jsonWithObject:[NSNull null]]; }

- (NSNull * _Nullable)null {
    if (LYJSONTypeNull == _type) {
        return (NSNull *) _object;
    }
    return nil;
}

- (void)setNull:(NSNull *)null {
    self.object = [NSNull null];
}

- (void)setObject:(id)object {
    _object = object;
    
    if (nil == object || [object isEqual:[NSNull null]]) {
        _type = LYJSONTypeNull;
    } else if ([object isKindOfClass:[NSArray class]]) {
        _type = LYJSONTypeArray;
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        _type = LYJSONTypeDictionary;
    } else if ([object isKindOfClass:[NSString class]]) {
        _type = LYJSONTypeString;
    } else if ([object isKindOfClass:[NSNumber class]]) {
        _type = LYJSONTypeNumber;
    } else if ([object isKindOfClass:[LYJSON class]]) {
        _type = LYJSONTypeJSON;
    } else if ([object isKindOfClass:[LYStaticJSON class]]) {
        _type = LYJSONTypeStaticJSON;
    } else {
        _type = LYJSONTypeUnknown;
        _object = nil;
        self.error = [LYJSONError unsupportedType];
    }
}

- (NSString *)stringValueWhereEmpty:(NSString *)defaultValue {
    NSString *result = [self stringValue];
    if (result.length == 0) {
        return [LYStaticJSON jsonWithObject:defaultValue].stringValue;
    }
    return result;
}

#pragma mark - substript
#pragma mark - for array
- (LYStaticJSON *)objectAtIndexedSubscript:(NSInteger)idx {
    if (_type == LYJSONTypeArray) {
        NSArray *array = (NSArray *) self.object;
        if (idx >= 0 && idx < array.count) {
            return [LYStaticJSON jsonWithObject:array[idx]];
        }
        LYStaticJSON *json = [LYStaticJSON null];
        json.error = LYJSONError.indexOutOfBounds;
        return json;
    } else if (_type == LYJSONTypeJSON) {
        LYJSON *json = ((LYJSON *) self.object)[idx];
        
        if (json.isExists) {
            LYStaticJSON *staticJson = [LYStaticJSON jsonWithObject:json[idx]];
            staticJson.error = json.error;
            return staticJson;
        } else {
            LYStaticJSON *staticJson = [LYStaticJSON null];
            staticJson.error = json.error;
            return staticJson;
        }
    } else if (_type == LYJSONTypeStaticJSON) {
        return ((LYStaticJSON *) self.object)[idx];
    }
    
    LYStaticJSON *result = [LYStaticJSON null];
    result.error = LYJSONError.wrongType;
    return result;
}

#pragma mark - for Dictionary
- (LYStaticJSON *)objectForKeyedSubscript:(NSString *)key {
    if (_type == LYJSONTypeDictionary) {
        NSDictionary *dict = (NSDictionary *) self.object;
        id result = dict[key];
        if (nil != result) {
            return [LYStaticJSON jsonWithObject:result];
        }
        
        LYStaticJSON *json = [LYStaticJSON null];
        json.error = LYJSONError.notExist;
        return json;
    } else if (_type == LYJSONTypeJSON) {
        LYJSON *json = ((LYJSON *) self.object)[key];
        if (json.isExists) {
            return [LYStaticJSON jsonWithObject:json];
        } else {
            LYStaticJSON *staticJson = LYStaticJSON.null;
            staticJson.error = json.error;
            return staticJson;
        }
    } else if (_type == LYJSONTypeStaticJSON) {
        return ((LYStaticJSON *) self.object);
    }
    
    LYStaticJSON *result = [LYStaticJSON null];
    result.error = LYJSONError.wrongType;
    return result;
}

#pragma mark - Array
- (NSArray<LYStaticJSON *> * _Nullable)array {
    if (_type == LYJSONTypeArray) {
        NSArray *array = (NSArray *) _object;
        NSMutableArray<LYStaticJSON *> *list = [[NSMutableArray alloc] init];
        for (id object in array) {
            [list addObject:[LYStaticJSON jsonWithObject:object]];
        }
        return list;
    } else if (_type == LYJSONTypeJSON) {
        NSArray *list = ((LYJSON *) _object).arrayObject;
        return [LYStaticJSON jsonWithObject:list].array;
    } else if (_type == LYJSONTypeStaticJSON) {
        return ((LYStaticJSON *) _object).array;
    }
    return nil;
}

- (NSArray<LYJSON *> *)arrayValue {
    NSArray *result = [self array];
    if (nil != result) { return result; }
    return @[];
}

- (NSArray * _Nullable)arrayObject {
    if (_type == LYJSONTypeArray) {
        return (NSMutableArray *) _object;
    } else if (_type == LYJSONTypeJSON) {
        return ((LYJSON *) _object).arrayObject;
    } else if (_type == LYJSONTypeStaticJSON) {
        return ((LYStaticJSON *) _object).arrayObject;
    }
    return nil;
}

- (NSArray *)arrayObjectValue {
    NSArray *result = [self arrayObject];
    if (nil == result) {
        return @[];
    }
    return result;
}

#pragma mark - Dictionary

- (NSDictionary<NSString *, LYStaticJSON *> * _Nullable)dictionary {
    if (_type == LYJSONTypeDictionary) {
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        NSDictionary *rawDictionary = (NSDictionary *) _object;
        for (NSString *key in rawDictionary.allKeys) {
            id value = rawDictionary[key];
            if ([value isKindOfClass:[LYStaticJSON class]]) {
                result[key] = value;
            } else {
                result[key] = [LYStaticJSON jsonWithObject:value];
            }
        }
        return result;
    } else if (_type == LYJSONTypeJSON) {
        NSDictionary *dict = ((LYJSON *) _object).dictionaryObject;
        return [LYStaticJSON jsonWithObject:dict].dictionary;
    } else if (_type == LYJSONTypeStaticJSON) {
        return ((LYStaticJSON *) _object).dictionary;
    }
    return nil;
}

- (NSDictionary<NSString *, LYJSON *> *)dictionaryValue {
    NSDictionary *result = [self dictionary];
    if (nil == result) {
        return @{};
    }
    return result;
}

- (NSDictionary * _Nullable)dictionaryObject {
    if (_type == LYJSONTypeDictionary) {
        return (NSMutableDictionary *) _object;
    } else if (_type == LYJSONTypeJSON) {
        return ((LYJSON *) _object).dictionaryObject;
    } else if (_type == LYJSONTypeStaticJSON) {
        return ((LYStaticJSON *) _object).dictionaryObject;
    }
    return nil;
}

- (NSDictionary *)dictionaryObjectValue {
    NSDictionary *dict = [self dictionaryObject];
    if (nil == dict) {
        return @{ };
    }
    return dict;
}

- (id)rawObject {
    if (_type == LYJSONTypeStaticJSON) {
        return ((LYStaticJSON *) _object).rawObject;
    } else if (_type == LYJSONTypeJSON) {
        return ((LYJSON *) _object).object;
    }
    return _object;
}

#pragma mark - String
- (NSString *)string {
    if (_type == LYJSONTypeString) {
        return (NSString *) _object;
    } else if (_type == LYJSONTypeJSON) {
        return ((LYJSON *) _object).string;
    } else if (_type == LYJSONTypeStaticJSON) {
        return ((LYStaticJSON *) _object).string;
    }
    return nil;
}

- (NSString *)stringValue {
    switch (_type) {
        case LYJSONTypeString:
            return (NSString *) _object;
        case LYJSONTypeNumber:
            return ((NSNumber *) _object).stringValue;
        case LYJSONTypeJSON:
            return ((LYJSON *) _object).stringValue;
        case LYJSONTypeStaticJSON:
            return ((LYStaticJSON *) _object).stringValue;
        default:
            return @"";
    }
}

#pragma mark - Number
- (NSNumber *)number {
    switch (_type) {
        case LYJSONTypeNumber:
            return (NSNumber *) _object;
        case LYJSONTypeJSON:
            return ((LYJSON *) _object).number;
        case LYJSONTypeStaticJSON:
            return ((LYStaticJSON *) _object).number;
        default:
            return nil;
    }
}

- (NSNumber *)numberValue {
    if (LYJSONTypeNumber == _type) {
        NSNumber *num = (NSNumber *) _object;
        if (nil != num) { return num; }
        return @0;
    } else if (LYJSONTypeString == _type) {
        NSDecimalNumber *num = [NSDecimalNumber decimalNumberWithString:_object];
        if ([num isEqualToNumber:[NSDecimalNumber notANumber]]) {
            return [NSDecimalNumber zero];
        }
        return num;
    } else if (LYJSONTypeJSON == _type) {
        return ((LYJSON *) _object).numberValue;
    } else if (LYJSONTypeStaticJSON == _type) {
        return ((LYStaticJSON *) _object).numberValue;
    }
    return @0;
}

#pragma mark - Number
- (char)charValue { return self.numberValue.charValue; }

- (unsigned char)unsignedCharValue { return self.numberValue.unsignedCharValue; }

- (short)shortValue { return self.numberValue.shortValue; }

- (unsigned short)unsignedShortValue { return self.numberValue.unsignedShortValue; }

- (int)intValue { return self.numberValue.intValue; }

- (unsigned int)unsignedIntValue { return self.numberValue.unsignedIntValue; }

- (long)longValue { return self.numberValue.longValue; }

- (unsigned long)unsignedLongValue { return self.numberValue.unsignedLongValue; }

- (long long)longLongValue { return self.numberValue.longLongValue; }

- (unsigned long long)unsignedLongLongValue { return self.numberValue.unsignedLongLongValue; }

- (float)floatValue { return self.numberValue.floatValue; }

- (double)doubleValue { return self.numberValue.doubleValue; }

- (BOOL)boolValue { return self.numberValue.boolValue; }

- (NSInteger)integerValue { return self.numberValue.integerValue; }

- (NSUInteger)unsignedIntegerValue { return self.numberValue.unsignedIntegerValue; }


@end
