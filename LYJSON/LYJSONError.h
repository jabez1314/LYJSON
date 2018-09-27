//
//  LYJSONError.h
//  JSON
//
//  Created by Jabez on 2018/9/27.
//  Copyright © 2018 ly. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LYJSONError : NSObject

@property (class, nonatomic, readonly) NSError *unsupportedType;
@property (class, nonatomic, readonly) NSError *indexOutOfBounds;
@property (class, nonatomic, readonly) NSError *elementTooDeep;
@property (class, nonatomic, readonly) NSError *wrongType;
@property (class, nonatomic, readonly) NSError *notExist;
@property (class, nonatomic, readonly) NSError *invalidJSON;

@end

NS_ASSUME_NONNULL_END
