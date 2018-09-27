//
//  LYJSON.m
//  JSON
//
//  Created by Jabez on 2018/9/27.
//  Copyright © 2018 ly. All rights reserved.
//

#import "LYJSON.h"
#import "LYJSONError.h"

id unwrapped(id _Nullable object) {
    if ([object isKindOfClass:[LYJSON class]]) {
        id value = [(LYJSON *) object object];
        return unwrapped(value);
    } else if ([object isKindOfClass:[NSArray class]]) {
        NSArray *unwrappedArray = (NSArray *) object;
        NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:unwrappedArray.count];
        for (id item in unwrappedArray) {
            id value = unwrapped(item);
            if (value != nil) {
                [results addObject:value];
            }
        }
        return [results mutableCopy];
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *unwrappeDic = (NSDictionary *) object;
        NSMutableDictionary *results = [[NSMutableDictionary alloc] initWithCapacity:unwrappeDic.count];
        [unwrappeDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            id value = unwrapped(obj);
            if (nil != value) {
                results[key] = value;
            }
        }];
        return [results mutableCopy];
    } else {
        return object;
    }
}

id unwrapping(id _Nullable object) {
    if ([object isKindOfClass:[LYJSON class]]) {
        id value = [(LYJSON *) object object];
        return unwrapping(value);
    } else if ([object isKindOfClass:[NSMutableArray class]]) {
        NSMutableArray *unwrappedArray = (NSMutableArray *)object;
        [unwrappedArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id value = unwrapping(obj);
            if (nil == value) {
                value = [NSNull null];
            }
            [unwrappedArray replaceObjectAtIndex:idx withObject:value];
        }];
        return unwrappedArray;
    } else if ([object isKindOfClass:[NSMutableDictionary class]]) {
        NSMutableDictionary *unwrappeDic = (NSMutableDictionary *) object;
        [unwrappeDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            id value = unwrapping(obj);
            if (nil == value) {
                value = [NSNull null];
            }
            unwrappeDic[key] = value;
        }];
        return unwrappeDic;
    } else {
        return object;
    }
}

#pragma mark - LYJSON

@interface LYJSON ()

@property (nonatomic, strong, readwrite, nullable) id object;

@property (nonatomic, strong, readwrite, nullable) NSError *error;

- (void)setObject:(id)object mutable:(BOOL)mutable;

@end


NS_INLINE LYJSON *internalJSON(id _Nullable object) {
    LYJSON *json = [[LYJSON alloc] init];
    json.object = object; // 无需unwrap过程
    //    [json setObject:object mutable:YES];
    return json;
}

@implementation LYJSON

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
    } else {
        _type = LYJSONTypeUnknown;
        _object = nil;
        self.error = [LYJSONError unsupportedType];
    }
}

- (void)setObject:(id)object mutable:(BOOL)mutable {
    id newValue = nil;
    if (mutable) {
        newValue = unwrapping(object);
    } else {
        newValue = unwrapped(object);
    }
    self.object = newValue;
}

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
        [self setObject:object mutable:NO];
    }
    return self;
}

#pragma mark - substript
#pragma mark - for array
- (LYJSON *)objectAtIndexedSubscript:(NSInteger)idx {
    if (_type != LYJSONTypeArray) {
        LYJSON *result = [LYJSON null];
        result.error = LYJSONError.wrongType;
        return result;
    }

    NSMutableArray *array = (NSMutableArray *) self.arrayObject;
    if (idx >= 0 && idx < [array count]) {
        return internalJSON(array[idx]);
    }

    LYJSON *result = [LYJSON null];
    result.error = LYJSONError.indexOutOfBounds;
    return result;
}

- (void)setObject:(id _Nullable)obj atIndexedSubscript:(NSInteger)idx {
    if (LYJSONTypeArray != _type) { return; }

    if (nil != _error) { return; }

    NSMutableArray *array = (NSMutableArray *) _object;
    if (![array isKindOfClass:[NSMutableArray class]]) {
        array = [NSMutableArray arrayWithArray:(NSArray *) _object];
        self.arrayObject = array;
    }

    if (idx >= 0 && idx < array.count) {
        id unwrappedValue = unwrapped(obj);
        if (nil == unwrappedValue) {
            [array removeObjectAtIndex:idx];
        } else {
            array[idx] = unwrappedValue;
        }
    }
}

#pragma mark - for Dictionary
- (LYJSON *)objectForKeyedSubscript:(NSString *)key {
    LYJSON *result = LYJSON.null;

    NSString *inputKey = [key description];
    if (LYJSONTypeDictionary != _type) {
        result.error = LYJSONError.wrongType;
    } else if (nil != inputKey) {

        NSMutableDictionary *mutableDictionary = (NSMutableDictionary *) self.dictionaryObject;
        id value = mutableDictionary[inputKey];
        if (nil != value) {
            return internalJSON(value);
        }
    }

    if (nil == result.error) {
        result.error = LYJSONError.notExist;
    }

    return result;
}

- (void)setObject:(id _Nullable)obj forKeyedSubscript:(NSString *)key {
    if (nil != _error) { return; }

    if (LYJSONTypeDictionary != _type) { return; }

    if (nil == key) { return; }

    NSMutableDictionary *dict = (NSMutableDictionary *) _object;
    if (![dict isKindOfClass:[NSMutableDictionary class]]) {
        dict = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *) _object];
        self.dictionaryObject = dict;
    }

    if (nil == obj) {
        [dict removeObjectForKey:key.description];
    } else {
        id unwrappedValue = unwrapped(obj);
        if (nil == unwrappedValue) {
            [dict removeObjectForKey:key.description];
        } else {
            dict[key.description] = unwrappedValue;
        }
    }
}


#pragma mark - String

- (nullable NSString *)rawString {
    return [self rawStringWithOptions:NSJSONWritingPrettyPrinted];
}

- (nullable NSString *)rawStringWithOptions:(NSJSONWritingOptions)options {
    if (_type == LYJSONTypeDictionary || _type == LYJSONTypeArray) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:_object options:options error:nil];
        if (nil == data) { return nil; }
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    } else if (_type == LYJSONTypeNull) {
        return @"null";
    }
    return [_object description];
}

#pragma mark - Data
- (nullable NSData *)rawData {
    return [self rawDataWithOptions:NSJSONWritingPrettyPrinted];
}

- (nullable NSData *)rawDataWithOptions:(NSJSONWritingOptions)options {
    return [self rawDataWithOptions:options error:nil];
}

- (nullable NSData *)rawDataWithOptions:(NSJSONWritingOptions)options error:(NSError * _Nullable __autoreleasing *)error {
    if (nil == _object) { return nil; }

    if (![NSJSONSerialization isValidJSONObject:_object]) {
        if (nil != error) { *error = [LYJSONError invalidJSON]; }
        return nil;
    }

    NSError *inputError = nil;
    id object = [NSJSONSerialization dataWithJSONObject:_object options:options error:&inputError];
    if (error != nil && inputError != nil) {
        *error = [LYJSONError invalidJSON];
    }
    return object;
}

#pragma mark - Array
- (NSArray<LYJSON *> * _Nullable)array {
    if (_type == LYJSONTypeArray) {
        NSArray *array = (NSArray *) _object;
        NSMutableArray<LYJSON *> *list = [[NSMutableArray alloc] init];
        for (id object in array) {
            [list addObject:internalJSON(object)];
        }
        return list;
    }
    return nil;
}

- (NSArray<LYJSON *> *)arrayValue {
    NSArray *result = [self array];
    if (nil != result) { return result; }
    return @[];
}

- (NSMutableArray * _Nullable)arrayObject {
    if (_type == LYJSONTypeArray) {
        return (NSMutableArray *) _object;
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

- (void)setArrayObject:(NSArray *)arrayObject {
    if (_type == LYJSONTypeArray) {
        [self setObject:arrayObject mutable:NO];
    } else {
        self.object = [NSNull null];
    }
}

#pragma mark - Dictionary

- (NSDictionary<NSString *, LYJSON *> * _Nullable)dictionary {
    if (_type == LYJSONTypeDictionary) {
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        NSDictionary *rawDictionary = (NSDictionary *) _object;
        [rawDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            //            [result setObject:[LYJSON jsonWithObject:obj] forKey:key];
            [result setObject:internalJSON(obj) forKey:key];
        }];
        return result;
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

- (NSMutableDictionary * _Nullable)dictionaryObject {
    if (_type == LYJSONTypeDictionary) {
        return (NSMutableDictionary *) _object;
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

- (void)setDictionaryObject:(NSDictionary *)dictionaryObject {
    if (_type == LYJSONTypeDictionary) {
        [self setObject:dictionaryObject mutable:NO];
    } else {
        self.object = [NSNull null];
    }
}

#pragma mark - String
- (NSString * _Nullable)string {
    if (_type == LYJSONTypeString) {
        return (NSString *) _object;
    }
    return nil;
}

- (void)setString:(NSString *)string {
    if (_type == LYJSONTypeString) {
        self.object = [NSString stringWithString:string];
    } else {
        self.object = [NSNull null];
    }
}

- (NSString *)stringValue {
    switch (_type) {
        case LYJSONTypeString:
            return (NSString *) _object;
        case LYJSONTypeNumber:
            return ((NSNumber *) _object).stringValue;
        default:
            return @"";
    }
}

#pragma mark - Number
- (NSNumber * _Nullable)number {
    if (_type == LYJSONTypeNumber) {
        return (NSNumber *) _object;
    }
    return nil;
}

- (void)setNumber:(NSNumber *)number {
    self.object = number;
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
    }
    return @0;
}

#pragma mark - Null

+ (LYJSON *)null { return [LYJSON jsonWithObject:[NSNull null]]; }

- (NSNull * _Nullable)null {
    if (LYJSONTypeNull == _type) {
        return (NSNull *) _object;
    }
    return nil;
}

- (void)setNull:(NSNull *)null {
    self.object = [NSNull null];
}

- (BOOL)isExists { return nil == _error; }

#pragma mark - Number
- (void)setCharValue:(char)charValue { self.object = @(charValue); }
- (char)charValue { return self.numberValue.charValue; }

- (void)setUnsignedCharValue:(unsigned char)unsignedCharValue { self.object = @(unsignedCharValue); }
- (unsigned char)unsignedCharValue { return self.numberValue.unsignedCharValue; }

- (void)setShortValue:(short)shortValue { self.object = @(shortValue); }
- (short)shortValue { return self.numberValue.shortValue; }

- (void)setUnsignedShortValue:(unsigned short)unsignedShortValue { self.object = @(unsignedShortValue); }
- (unsigned short)unsignedShortValue { return self.numberValue.unsignedShortValue; }

- (void)setIntValue:(int)intValue { self.object = @(intValue); }
- (int)intValue { return self.numberValue.intValue; }

- (void)setUnsignedIntValue:(unsigned int)unsignedIntValue { self.object = @(unsignedIntValue); }
- (unsigned int)unsignedIntValue { return self.numberValue.unsignedIntValue; }

- (void)setLongValue:(long)longValue { self.object = @(longValue); }
- (long)longValue { return self.numberValue.longValue; }

- (void)setUnsignedLongValue:(unsigned long)unsignedLongValue { self.object = @(unsignedLongValue); }
- (unsigned long)unsignedLongValue { return self.numberValue.unsignedLongValue; }

- (void)setLongLongValue:(long long)longLongValue { self.object = @(longLongValue); }
- (long long)longLongValue { return self.numberValue.longLongValue; }

- (void)setUnsignedLongLongValue:(unsigned long long)unsignedLongLongValue { self.object = @(unsignedLongLongValue); }
- (unsigned long long)unsignedLongLongValue { return self.numberValue.unsignedLongLongValue; }

- (void)setFloatValue:(float)floatValue { self.object = @(floatValue); }
- (float)floatValue { return self.numberValue.floatValue; }

- (void)setDoubleValue:(double)doubleValue { self.object = @(doubleValue); }
- (double)doubleValue { return self.numberValue.doubleValue; }

- (void)setBoolValue:(BOOL)boolValue { self.object = @(boolValue); }
- (BOOL)boolValue { return self.numberValue.boolValue; }

- (void)setIntegerValue:(NSInteger)integerValue { self.object = @(integerValue); }
- (NSInteger)integerValue { return self.numberValue.integerValue; }

- (void)setUnsignedIntegerValue:(NSUInteger)unsignedIntegerValue { self.object = @(unsignedIntegerValue); }
- (NSUInteger)unsignedIntegerValue { return self.numberValue.unsignedIntegerValue; }

#pragma mark - url
- (NSURL *_Nullable)url {
    if (LYJSONTypeString != _type) { return nil; }

    NSString *rawString = [self rawString];
    if (nil == rawString) { return nil; }

    if ([rawString rangeOfString:@"%[0-9A-Fa-f]{2}" options:NSRegularExpressionSearch].location != NSNotFound) {
        return [NSURL URLWithString:rawString];
    } else {
        NSString *encoded = [rawString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
        return [NSURL URLWithString:encoded];
    }
    return nil;
}

- (void)setUrl:(NSURL * _Nullable)url {
    if ([url isKindOfClass:[NSURL class]]) {
        self.object = url.absoluteString;
    } else {
        self.object = [NSNull null];
    }
}

#pragma mark - Printable, DebugPrintable
- (NSString *)description {
    NSString *str = [self rawStringWithOptions:NSJSONWritingPrettyPrinted];
    if (str == nil) {
        return @"known";
    }
    return str;
}

- (NSString *)debugDescription {
    return [self description];
}

#pragma mark - Copy
- (instancetype)copy {
    return [self mutableCopy];
}

- (instancetype)mutableCopy {
    return [LYJSON jsonWithObject:_object];
}

@end

