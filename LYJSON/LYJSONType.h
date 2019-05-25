//
//  LYJSONType.h
//  LYJSON
//
//  Created by john on 2019/5/26.
//  Copyright © 2019 jabez. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LYJSONType) {
    LYJSONTypeNumber,
    LYJSONTypeString,
    LYJSONTypeArray,
    LYJSONTypeDictionary,
    LYJSONTypeNull,
    LYJSONTypeUnknown,
    
    LYJSONTypeJSON,
    LYJSONTypeStaticJSON,
};

@interface LYJSONError: NSObject

@property (class, nonatomic, readonly) NSError *unsupportedType;
@property (class, nonatomic, readonly) NSError *indexOutOfBounds;
@property (class, nonatomic, readonly) NSError *elementTooDeep;
@property (class, nonatomic, readonly) NSError *wrongType;
@property (class, nonatomic, readonly) NSError *notExist;
@property (class, nonatomic, readonly) NSError *invalidJSON;

@end

NS_ASSUME_NONNULL_END
