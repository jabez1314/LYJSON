//
//  LYJSONTests.m
//  LYJSONTests
//
//  Created by Jabez on 2018/9/27.
//  Copyright © 2018 jabez. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LYJSON.h"

@interface LYJSONTests : XCTestCase

@end

@implementation LYJSONTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    LYJSON *json = LYJSONObject(nil);
    XCTAssert(json[@"a"].stringValue.length == 0);
}


@end
