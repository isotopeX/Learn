//
//  LObserver.m
//  Learn
//
//  Created by 刘宪威 on 2019/4/9.
//  Copyright © 2019 bigbrother. All rights reserved.
//

#import "LObserver.h"

@interface LObserver ()

@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, weak, readwrite) id observer;
@property (nonatomic, assign) SEL selector;

@end

@implementation LObserver

- (instancetype)initWithObserver:(id)observer
                        selector:(SEL)selector
                            name:(NSString *)name {
    if (self = [super init]) {
        _observer = observer;
        _name = name.copy;
        _selector = selector;
    }
    return self;
}

- (void)performNotification:(LNotification *)notification {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (_selector) {
        [_observer performSelector:_selector withObject:notification];
    }
#pragma clang diagnostic pop
}

@end
