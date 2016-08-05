//
//  PowerPlotTests.m
//  PowerPlotTests
//
//  Created by Dr. Wolfram Schroers on 7/8/16.
//  Copyright © 2016 Wolfram Schroers. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PowerPlot.h"

@interface PowerPlotTests : XCTestCase

// The data object to be tested.
@property (nonatomic, strong) WSData *data;

// The ticks object to be tested.
@property (nonatomic, strong) WSTicks *ticks;

@end

@implementation PowerPlotTests

- (void)setUp {
    [super setUp];

    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.data = [WSData dataWithValues:@[@5, @10, @7, @4, @-1]
                               valuesX:@[@1, @2, @2, @5, @-1]
                           annotations:@[@"datum1", @"datum2", @"datum3", @"datum4", @"datum5"]];
    self.ticks = [[WSTicks alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.data = nil;
    self.ticks = nil;

    [super tearDown];
}

#pragma mark Unit tests

- (void)testVersion {
    XCTAssertTrue([[WSChart version] isEqualToString:@"3.0"], @"The version number is not correct.");
}

- (void)testLicense {
    XCTAssertTrue([[WSChart license] isEqualToString:@"MIT"], @"The license identifier is not correct.");
}

- (void)testInitialization {
    XCTAssertNotNil(self.data, @"The data has not been initialized correctly.");
    XCTAssertEqual((int)[self.data count], (int)5, @"The data does not have the correct count.");
}

- (void)testReadAccess {
    XCTAssertEqualWithAccuracy(self.data[0].value, 5.0, 0.001, @"Value not correct.");
    XCTAssertEqualWithAccuracy(self.data[1].valueX, 2.0, 0.001, @"ValueX not correct.");
    XCTAssertEqualWithAccuracy([self.data lastDatum].valueX, -1.0, 0.001, @"Last value not correct.");
    XCTAssertEqualObjects(self.data[0], self.data[@"datum1"], @"Different accessors yield different results.");
}

- (void)testReadWriteAccess {
    [self.data addDatum:[WSDatum datumWithValue:3.0 annotation:@"datum1"]];
    XCTAssertEqual((int)[self.data count], (int)6, @"The data does not have the correct count.");

    NSArray *datum1Get = self.data[@"datum1"];
    NSArray *alternativeGet = @[[self.data firstDatum], [self.data lastDatum]];
    XCTAssertEqual([datum1Get count], [alternativeGet count], @"Incorrect comparison result.");
    XCTAssertEqualObjects(datum1Get[0], alternativeGet[0], @"The getters yield inconsistent results.");
    XCTAssertEqualObjects(datum1Get[1], alternativeGet[1], @"The getters yield inconsistent results.");
}

- (void)testReadWriteAccess2 {
    self.data[@"datum1"] = [WSDatum datumWithValue:3.0];
    XCTAssertEqual((int)[self.data count], (int)5, @"The data does not have the correct count.");

    WSDatum *datum1Get = self.data[@"datum1"];
    XCTAssertEqualObjects(datum1Get, [self.data firstDatum], @"The getters yield inconsistent results.");
    XCTAssertEqualWithAccuracy(datum1Get.value, 3.0, 0.001, @"Value not correct.");
}

- (void)testReductions {
    WSDatum *average = [self.data reduceAverage];
    XCTAssertEqualWithAccuracy(average.valueX, 1.8, 0.001, @"Average x-value not correct.");
    XCTAssertEqualWithAccuracy(average.valueY, 5.0, 0.001, @"Average y-value not correct.");

    WSDatum *sum = [self.data reduceSum];
    XCTAssertEqualWithAccuracy(sum.valueX, 9.0, 0.001, @"Summed x-value not correct.");
    XCTAssertEqualWithAccuracy(sum.valueY, 25.0, 0.001, @"Summed y-value not correct.");

    sum = [self.data reduce:^WSDatum *(WSDatum *datum1, WSDatum *datum2) {
        return [WSDatum datumWithValue:(datum1.value + datum2.value)
                                valueX:(datum1.valueX + datum2.valueX)];
    }
                      start:[WSDatum datumWithValue:0.f valueX:0.f]];
    XCTAssertEqualWithAccuracy(sum.valueX, 9.0, 0.001, @"Summed x-value not correct.");
    XCTAssertEqualWithAccuracy(sum.valueY, 25.0, 0.001, @"Summed y-value not correct.");
}

- (void)testMap {
    [self.data map:^WSDatum *(const WSDatum *datum) {
        XCTAssert([datum isKindOfClass:[WSDatum class]], @"Datum has the wrong class.");
        WSDatum *result = [datum copy];
        result.value *= 2;
        return result;
    }];

    XCTAssertEqualWithAccuracy(self.data[0].value, 10.0, 0.001, @"Incorrect map result.");
    XCTAssertEqualWithAccuracy(self.data[1].value, 20.0, 0.001, @"Incorrect map result.");
    XCTAssertEqualWithAccuracy(self.data[2].value, 14.0, 0.001, @"Incorrect map result.");
    XCTAssertEqualWithAccuracy(self.data[3].value, 8.0, 0.001, @"Incorrect map result.");
    XCTAssertEqualWithAccuracy(self.data[4].value, -2.0, 0.001, @"Incorrect map result.");
}

- (void)testMap2 {
    WSDatum *oneElement = self.data[0];
    WSData *newData = [WSData data:self.data
                               map:^WSDatum *(const WSDatum *datum) {
                                   XCTAssert([datum isKindOfClass:[WSDatum class]], @"Datum has the wrong class.");
                                   WSDatum *result = [datum copy];
                                   result.value *= 2;
                                   return result;
                               }];

    XCTAssertEqualWithAccuracy(newData[0].value, 10.0, 0.001, @"Incorrect map result.");
    XCTAssertEqualWithAccuracy(newData[1].value, 20.0, 0.001, @"Incorrect map result.");

    XCTAssertEqualObjects(oneElement, self.data[0], @"Incoming object changed.");
}

- (void)testLocation {
    NSInteger closest = [self.data datumClosestToLocation:CGPointZero];
    XCTAssertEqual(closest, 4, @"Incorrect location identified.");

    closest = [self.data datumClosestToLocation:CGPointZero
                                maximumDistance:0.5];
    XCTAssertEqual(closest, -1, @"Reported incorrect result.");
}

- (void)testTicksRegular {
    [self.ticks autoTicksWithRange:NARangeMake(0, 5)
                            number:6
                         skipFirst:NO];
    XCTAssertEqual([self.ticks count], (NSUInteger)6, @"Number of ticks is incorrect.");
    XCTAssertEqualWithAccuracy([self.ticks tickAtIndex:0], 0.f, 0.001, @"Tick position is incorrect.");
    XCTAssertEqualWithAccuracy([self.ticks tickAtIndex:1], 1.f, 0.001, @"Tick position is incorrect.");
    XCTAssertEqualWithAccuracy([self.ticks tickAtIndex:2], 2.f, 0.001, @"Tick position is incorrect.");
    XCTAssertEqualWithAccuracy([self.ticks tickAtIndex:3], 3.f, 0.001, @"Tick position is incorrect.");
    XCTAssertEqualWithAccuracy([self.ticks tickAtIndex:4], 4.f, 0.001, @"Tick position is incorrect.");
    XCTAssertEqualWithAccuracy([self.ticks tickAtIndex:5], 5.f, 0.001, @"Tick position is incorrect.");
    XCTAssertEqualObjects(self.ticks[0], @"", @"Label string is not empty.");

    [self.ticks setTickLabels];
    XCTAssertEqualObjects(self.ticks[0], @"0", @"Tick label incorrect.");
    XCTAssertEqualObjects(self.ticks[1], @"1", @"Tick label incorrect.");
    XCTAssertEqualObjects(self.ticks[2], @"2", @"Tick label incorrect.");
    XCTAssertEqualObjects(self.ticks[3], @"3", @"Tick label incorrect.");
    XCTAssertEqualObjects(self.ticks[4], @"4", @"Tick label incorrect.");
    XCTAssertEqualObjects(self.ticks[5], @"5", @"Tick label incorrect.");
}

- (void)testTicksRegularSkipStart {
    [self.ticks autoTicksWithRange:NARangeMake(0, 5)
                            number:5
                         skipFirst:YES];
    XCTAssertEqual([self.ticks count], (NSUInteger)5, @"Number of ticks is incorrect.");
    XCTAssertEqualWithAccuracy([self.ticks tickAtIndex:0], 1.f, 0.001, @"Tick position is incorrect.");
    XCTAssertEqualWithAccuracy([self.ticks tickAtIndex:1], 2.f, 0.001, @"Tick position is incorrect.");
    XCTAssertEqualWithAccuracy([self.ticks tickAtIndex:2], 3.f, 0.001, @"Tick position is incorrect.");
    XCTAssertEqualWithAccuracy([self.ticks tickAtIndex:3], 4.f, 0.001, @"Tick position is incorrect.");
    XCTAssertEqualWithAccuracy([self.ticks tickAtIndex:4], 5.f, 0.001, @"Tick position is incorrect.");
    XCTAssertEqualObjects(self.ticks[0], @"", @"Label string is not empty.");
}

- (void)testNiceTicks {
    [self.ticks autoNiceTicksWithRange:NARangeMake(0, 5)
                                number:5];
    XCTAssertEqual([self.ticks count], (NSUInteger)6, @"Number of ticks is incorrect.");
    XCTAssertEqualWithAccuracy([self.ticks tickAtIndex:0], 0.f, 0.001, @"Tick position is incorrect.");
}

@end
