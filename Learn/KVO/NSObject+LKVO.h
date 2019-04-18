//
//  NSObject+LKVO.h
//  Learn
//
//  Created by 刘宪威 on 2019/4/18.
//  Copyright © 2019 bigbrother. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, L_KVO_OPTIONS) {
    L_KVO_OPTIONSNEW = 1 << 0,
    L_KVO_OPTIONSOLD = 1 << 1,
    L_KVO_OPTIONSINITIAL = 1 << 2
};

NS_ASSUME_NONNULL_BEGIN

extern NSString * const LKVOKeyNew;
extern NSString * const LKVOKeyOld;

@interface NSObject (LKVO)

/**
 生成一个新的派生类
 交换set 和get 方法
 在set 方法中去调用valueChangeForKey，通知监听者（类似通知），并且将新值赋值给原有的类
 在remove 的时候移除监听
 */

- (void)l_kvo_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(L_KVO_OPTIONS)options;

- (void)l_kvo_removeObserver:(NSObject *)observer;
- (void)l_kvo_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

- (void)l_kvo_observeValueForKeyPath:(NSString *)keyPath object:(id)object change:(NSDictionary<NSString *, id> *)change;

@end

NS_ASSUME_NONNULL_END
