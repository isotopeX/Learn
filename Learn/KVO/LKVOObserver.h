//
//  LKVOObserver.h
//  Learn
//
//  Created by 刘宪威 on 2019/4/18.
//  Copyright © 2019 bigbrother. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+LKVO.h"

NS_ASSUME_NONNULL_BEGIN

@interface LKVOObserver : NSObject

@property (nonatomic, weak) id observer;
@property (nonatomic, assign) L_KVO_OPTIONS options;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, copy) NSString *observerMemberAddress;

@end

NS_ASSUME_NONNULL_END
