//
//  LNotification.m
//  Learn
//
//  Created by 刘宪威 on 2019/4/9.
//  Copyright © 2019 bigbrother. All rights reserved.
//

#import "LNotification.h"

@interface LNotification ()

@property (nonatomic, copy, readwrite) NSString *name;

@end

@implementation LNotification

- (instancetype)initWithName:(NSString *)name {
    if (self = [super init]) {
        _name = name.copy;
    }
    return self;
}

@end
