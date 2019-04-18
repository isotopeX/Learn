//
//  LNotificationCenterTests.m
//  LearnUITests
//
//  Created by 刘宪威 on 2019/4/9.
//  Copyright © 2019 bigbrother. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../Learn/NotificationCenter/LNotificationCenter.h"
#import "../Learn/NotificationCenter/LNotification.h"

@interface LNotificationCenterTests : XCTestCase

@property (nonatomic, strong) dispatch_queue_t testQueue;
@property (nonatomic, assign) NSInteger callCount;

@end

@implementation LNotificationCenterTests

- (void)setUp {
    self.testQueue = dispatch_queue_create("test", DISPATCH_QUEUE_CONCURRENT);
    self.callCount = 0;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)test_singletonTest {
    LNotificationCenter *center0 = [LNotificationCenter defaultCenter];
    LNotificationCenter *center1 = [[LNotificationCenter alloc] init];
    
    XCTAssert(center0 == center1);
}

- (void)test_registerNotification {
    dispatch_group_t group = dispatch_group_create();
    LNotificationCenter *center = [LNotificationCenter defaultCenter];
    for (int i = 0; i < 100; i ++) {
        dispatch_group_enter(group);
    }
    
    for (int i = 0; i < 100; i ++) {
        
    }
}

- (void)testExample {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

@end
