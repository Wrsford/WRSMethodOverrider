//
//  WRSMethodOverriderTests.m
//  WRSMethodOverriderTests
//
//  Created by Will Stafford on 3/30/16.
//  Copyright © 2016 wrsford. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WRSMethodOverrider.h"
@interface TestingObj : NSObject

- (NSString*)testString1;
- (NSString*)testString2;
+ (NSString*)testString1;
+ (NSString*)testString2;
@end

@implementation TestingObj

- (NSString*)testString1 {
	return @"TestString 1";
}

- (NSString*)testString2 {
	return @"TestString 2";
}

+ (NSString*)testString1 {
	return @"TestString 1";
}

+ (NSString*)testString2 {
	return @"TestString 2";
}


@end

@interface WRSMethodOverriderTests : XCTestCase

@end

@implementation WRSMethodOverriderTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInstanceMethodOverride {
	[TestingObj overrideSelector:@selector(testString1) withBlock:^NSString*(TestingObj *me) {
		return [me testString2];
	}];
	
	TestingObj *to = [TestingObj new];
	
	XCTAssert([[to testString1] isEqualToString:[to testString2]], "Instance method override failure.");
}

- (void)testClassMethodOverride {
	[TestingObj overrideSelector:@selector(testString1) withBlock:^NSString*(TestingObj *me) {
		return [me testString2];
	}];
	
	XCTAssert([[TestingObj testString1] isEqualToString:[TestingObj testString2]], "Class method override failure.");
}

- (void)testAbstractionPerformanceLevel0 {
	[self measureBlock:^{
		
	}];
}

- (void)testAbstractionPerformanceLevel1 {
	[self measureBlock:^{
		
	}];
}

- (void)testAbstractionPerformanceLevel2 {
	[self measureBlock:^{
		
	}];
}


@end
