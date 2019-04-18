//
//  LNotificationCenter.h
//  Learn
//
//  Created by 刘宪威 on 2019/4/9.
//  Copyright © 2019 bigbrother. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LNotification;

NS_ASSUME_NONNULL_BEGIN

@interface LNotificationCenter : NSObject

+ defaultCenter;

- (void)addObserver:(id)observer selector:(SEL)selector name:(NSString *)name;

- (void)postNotificationWithName:(NSString *)name;
- (void)postNotificationOnMainThreadWithName:(NSString *)name;

- (void)postNotification:(LNotification *)notification;
- (void)postNotificationOnMainThread:(LNotification *)notification;

- (void)removeObserver:(id)observer;

@end

NS_ASSUME_NONNULL_END
