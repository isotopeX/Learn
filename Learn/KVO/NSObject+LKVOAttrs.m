//
//  NSObject+LKVOAttrs.m
//  Learn
//
//  Created by 刘宪威 on 2019/4/18.
//  Copyright © 2019 bigbrother. All rights reserved.
//

#import "NSObject+LKVOAttrs.h"
#import "LKVOObserver.h"
#import <objc/runtime.h>

@implementation NSObject (LKVOAttrs)

@dynamic l_kvo_obvservers, l_kvo_retainBy;

- (void)setL_kvo_obvservers:(NSMutableArray<LKVOObserver *> *)l_kvo_obvservers {
    objc_setAssociatedObject(self, sel_getName(@selector(l_kvo_obvservers)), l_kvo_obvservers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray<LKVOObserver *> *)l_kvo_obvservers {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setL_kvo_retainBy:(NSObject *)l_kvo_retainBy {
    objc_setAssociatedObject(self, sel_getName(@selector(l_kvo_retainBy)), l_kvo_retainBy, OBJC_ASSOCIATION_ASSIGN);
}

- (NSObject *)l_kvo_retainBy {
    return objc_getAssociatedObject(self, _cmd);
}

@end
