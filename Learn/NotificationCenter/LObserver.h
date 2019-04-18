//
//  LObserver.h
//  Learn
//
//  Created by 刘宪威 on 2019/4/9.
//  Copyright © 2019 bigbrother. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LNotification;

NS_ASSUME_NONNULL_BEGIN

@interface LObserver : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, weak, readonly) id observer;

- (instancetype)initWithObserver:(id)observer
                        selector:(SEL)selector
                            name:(NSString *)name;

- (void)performNotification:(LNotification *)notification;

@end

NS_ASSUME_NONNULL_END
