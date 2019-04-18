//
//  LNotificationCenter.m
//  Learn
//
//  Created by 刘宪威 on 2019/4/9.
//  Copyright © 2019 bigbrother. All rights reserved.
//

#import "LNotificationCenter.h"
#import "LNotification.h"
#import "LObserver.h"

static const char* LNotificationQueueId = "com.LNotificationCenter.Queue";

@interface LNotificationCenter ()

@property (nonatomic, strong) NSMutableArray<LObserver *> *observers;
// concurrent
@property (nonatomic, strong) dispatch_queue_t notificationQueue;

@end

@implementation LNotificationCenter

+ (id)defaultCenter {
    return [[self alloc] init];
}

// 正确的单例保证生成的实例唯一
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static LNotificationCenter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
        instance.notificationQueue = dispatch_queue_create(LNotificationQueueId, DISPATCH_QUEUE_CONCURRENT);
    });
    return instance;
}

#pragma mark - Public

- (void)addObserver:(id)observer selector:(SEL)selector name:(NSString *)name {
    LObserver *model = [[LObserver alloc] initWithObserver:observer selector:selector name:name];
    dispatch_barrier_async(_notificationQueue, ^{
        [self.observers addObject:model];
    });
}

- (void)postNotification:(LNotification *)notification {
    if (!notification.name.length) {
        return;
    }
    
    __block NSArray<LObserver *> *observers;
    dispatch_sync(_notificationQueue, ^{
        observers = [self.observers copy];
    });
    
    for (LObserver *observer in observers) {
        if ([observer.name isEqualToString:notification.name]) {
            [observer performNotification:notification];
        }
    }
}

- (void)postNotificationWithName:(NSString *)name {
    return [self postNotification:[[LNotification alloc] initWithName:name]];
}

- (void)postNotificationOnMainThread:(LNotification *)notification {
    [self performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
}

- (void)postNotificationOnMainThreadWithName:(NSString *)name {
    return [self postNotificationOnMainThread:[[LNotification alloc] initWithName:name]];
}

- (void)removeObserver:(id)observer {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(LObserver *  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return evaluatedObject.observer != observer;
    }];
    
    dispatch_barrier_async(_notificationQueue, ^{
        self.observers = [[self.observers filteredArrayUsingPredicate:predicate] mutableCopy];
    });
}

- (NSMutableArray<LObserver *> *)observers {
    if (!_observers) {
        _observers = [NSMutableArray array];
    }
    return _observers;
}

@end
