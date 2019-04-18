//
//  NSObject+LKVOAttrs.h
//  Learn
//
//  Created by 刘宪威 on 2019/4/18.
//  Copyright © 2019 bigbrother. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LKVOObserver;

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (LKVOAttrs)

@property (nonatomic, strong) NSMutableArray<LKVOObserver *> *l_kvo_obvservers;
@property (nonatomic, weak) NSObject *l_kvo_retainBy;

@end

NS_ASSUME_NONNULL_END
