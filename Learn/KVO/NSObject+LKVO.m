//
//  NSObject+LKVO.m
//  Learn
//
//  Created by 刘宪威 on 2019/4/18.
//  Copyright © 2019 bigbrother. All rights reserved.
//

#import "NSObject+LKVO.h"
#import "LKVOObserver.h"
#import "NSObject+LKVOAttrs.h"
#import <objc/runtime.h>
#import <objc/message.h>

NSString *const LKVOKeyNew = @"LKVOKeyNew";
NSString *const LKVOKeyOld = @"LKVOKeyOld";
static NSString *const LKVOClassPrefix = @"LKVOClass_";

@implementation NSObject (LKVO)

#pragma mark - Public

- (void)l_kvo_addObserver:(NSObject *)observer
               forKeyPath:(NSString *)keyPath
                  options:(L_KVO_OPTIONS)options {
    
    [self l_kvo_isaSwizzleWithKeyPath:keyPath];

    LKVOObserver *newOb = [[LKVOObserver alloc] init];
    newOb.observer = observer;
    newOb.observerMemberAddress = [NSString stringWithFormat:@"%p", observer];
    newOb.keyPath = keyPath;
    newOb.options = options;
    if (!self.l_kvo_obvservers) {
        self.l_kvo_obvservers = @[].mutableCopy;
    }
    
    [self.l_kvo_obvservers addObject:newOb];
    
    if (options & L_KVO_OPTIONSINITIAL) {
        ((void(*)(id,SEL,id,id,id))(void *)objc_msgSend)(observer, @selector(l_kvo_observeValueForKeyPath:object:change:), keyPath, self, @{});
    }
}

- (void)l_kvo_removeObserver:(NSObject *)observer {
    self.l_kvo_obvservers = [[self.l_kvo_obvservers filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(LKVOObserver *obj, NSDictionary<NSString *,id> * _Nullable bindings) {
        if ([obj.observerMemberAddress isEqualToString:[NSString stringWithFormat:@"%p", observer]]) {
            return false;
        } else {
            return true;
        }
    }]] mutableCopy];
    if (!self.l_kvo_obvservers.count) {
        object_setClass(self, class_getSuperclass(object_getClass(self)));
    }
}

- (void)l_kvo_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    self.l_kvo_obvservers = [[self.l_kvo_obvservers filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(LKVOObserver *obj, NSDictionary<NSString *,id> * _Nullable bindings) {
        if ([obj.observerMemberAddress isEqualToString:[NSString stringWithFormat:@"%p", observer]] && [obj.keyPath isEqualToString:keyPath]) {
            return false;
        } else {
            return true;
        }
    }]] mutableCopy];
    if (!self.l_kvo_obvservers.count) {
        object_setClass(self, class_getSuperclass(object_getClass(self)));
    }
}

- (void)l_kvo_observeValueForKeyPath:(NSString *)keyPath object:(id)object change:(NSDictionary<NSString *, id> *)change {
    // must imp in subclass
}

#pragma mark - Private

static NSString *const keyPathDotSep = @".";

- (void)l_kvo_isaSwizzleWithKeyPath:(NSString *)keyPath {
    // 获取监听的属性
    NSArray<NSString *> *attrs = [keyPath componentsSeparatedByString:keyPathDotSep];
    id preObj = self;
    
    for (NSUInteger i = 0; i < attrs.count; i ++) {
        NSString *attrName = attrs[i];
        SEL get = sel_registerName(attrName.UTF8String);
        SEL set = sel_registerName([NSString stringWithFormat:@"set%@:", attrName.capitalizedString].UTF8String);
        
        if ([preObj respondsToSelector:set]) {
            [preObj l_kvo_isaSwizzleSetter:set];
        }
        
        BOOL last = (i == attrs.count - 1);
        if (!last && [preObj respondsToSelector:get]) {
            NSObject *newObj = ((id(*)(id, SEL))(void *)objc_msgSend)(preObj, get);
            newObj.l_kvo_retainBy = preObj;
            preObj = newObj;
        }
    }
}

- (void)l_kvo_isaSwizzleSetter:(SEL)setter {
    //
    const char * subclassName = l_kvo_subClassName([self class]);
    Class subClass = objc_getClass(subclassName);
    if (!subClass) {
        subClass = objc_allocateClassPair(object_getClass(self), subclassName, 0);
        if (subClass) {
            objc_registerClassPair(subClass);
        } else {
            return; // fail
        }
    }
    
    //
    const char * typeEncoding = method_getTypeEncoding(class_getInstanceMethod(object_getClass(self), setter));
    IMP new = l_kvo_IMPWithTypeEncoding(typeEncoding);
    class_addMethod(subClass, setter, new, typeEncoding);
    object_setClass(self, subClass);
}


const char * l_kvo_subClassName(Class class) {
    NSString *name = [NSString stringWithFormat:@"%@%s", LKVOClassPrefix, class_getName(class)];
    return name.UTF8String;
}

NSString * l_kvo_getterSELName(SEL setterSEL) {
    NSString *methodName = [NSString stringWithFormat:@"%s", sel_getName(setterSEL)];
    methodName = [methodName substringFromIndex:3];
    methodName = [methodName substringToIndex:methodName.length - 1];
    methodName = [methodName lowercaseString];
    return methodName;
}

IMP l_kvo_IMPWithTypeEncoding(const char * typeEncoding) {
    NSString *type = [[NSString stringWithUTF8String:typeEncoding] substringFromIndex:@"v24@0:8".length];
    if ([type containsString:[NSString stringWithUTF8String:@encode(char)]]) {
        return (IMP)l_kvo_setter_char;
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(short)]]) {
        return (IMP)l_kvo_setter_short;
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(int)]]) {
        return (IMP)l_kvo_setter_int;
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(long)]]) {
        return (IMP)l_kvo_setter_long;
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(long long)]]) {
        return (IMP)l_kvo_setter_long_long;
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(unsigned char)]]) {
        return (IMP)l_kvo_setter_unsigned_char;
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(unsigned short)]]) {
        return (IMP)l_kvo_setter_unsigned_short;
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(unsigned int)]]) {
        return (IMP)l_kvo_setter_unsigned_int;
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(unsigned long long)]]) {
        return (IMP)l_kvo_setter_unsigned_long_long;
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(unsigned long)]]) {
        return (IMP)l_kvo_setter_unsigned_long;
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(bool)]]) {
        return (IMP)l_kvo_setter_bool;
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(float)]]) {
        return (IMP)l_kvo_setter_float;
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(double)]]) {
        return (IMP)l_kvo_setter_double;
    } else {
        return (IMP)l_kvo_setter_objc;
    }
}

void l_kvo_setter_short(NSObject *self, SEL cmd, short newValue) {
    l_kvo_setter_basic(self, cmd, @(newValue));
}

void l_kvo_setter_unsigned_short(NSObject *self, SEL cmd, unsigned short newValue) {
    l_kvo_setter_basic(self, cmd, @(newValue));
}

void l_kvo_setter_int(NSObject *self, SEL cmd, int newValue) {
    l_kvo_setter_basic(self, cmd, @(newValue));
}

void l_kvo_setter_unsigned_int(NSObject *self, SEL cmd, unsigned int newValue) {
    l_kvo_setter_basic(self, cmd, @(newValue));
}

void l_kvo_setter_long(NSObject *self, SEL cmd, long newValue) {
    l_kvo_setter_basic(self, cmd, @(newValue));
}

void l_kvo_setter_unsigned_long(NSObject *self, SEL cmd, unsigned long newValue) {
    l_kvo_setter_basic(self, cmd, @(newValue));
}

void l_kvo_setter_long_long(NSObject *self, SEL cmd, long long newValue) {
    l_kvo_setter_basic(self, cmd, @(newValue));
}

void l_kvo_setter_unsigned_long_long(NSObject *self, SEL cmd, unsigned long long newValue) {
    l_kvo_setter_basic(self, cmd, @(newValue));
}

void l_kvo_setter_bool(NSObject *self, SEL cmd, BOOL newValue) {
    l_kvo_setter_basic(self, cmd, @(newValue));
}

void l_kvo_setter_float(NSObject *self, SEL cmd, float newValue) {
    l_kvo_setter_basic(self, cmd, @(newValue));
}

void l_kvo_setter_double(NSObject *self, SEL cmd, double newValue) {
    l_kvo_setter_basic(self, cmd, @(newValue));
}

void l_kvo_setter_unsigned_char(NSObject *self, SEL cmd, unsigned char newValue) {
    l_kvo_setter_basic(self, cmd, [NSString stringWithFormat:@"%c", newValue]);
}

void l_kvo_setter_char(NSObject *self, SEL cmd, char newValue) {
    l_kvo_setter_basic(self, cmd, [NSString stringWithFormat:@"%c", newValue]);
}

#pragma mark - Old value

id l_kvo_oldValue(NSObject* self, const char *typeEncoding, SEL getAttrSEL) {
    NSString *type = [[NSString stringWithUTF8String:typeEncoding] substringFromIndex:@"v24@0:8".length];
    if ([type containsString:[NSString stringWithUTF8String:@encode(char)]]) {
        char oldValue = ((char(*)(id,SEL))(void *)objc_msgSend)(self, getAttrSEL);
        return [NSString stringWithFormat:@"%c", oldValue];
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(short)]]) {
        return @(((short(*)(id,SEL))(void *)objc_msgSend)(self, getAttrSEL));
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(int)]]) {
        return @(((int(*)(id,SEL))(void *)objc_msgSend)(self, getAttrSEL));
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(long)]]) {
        return @(((long(*)(id,SEL))(void *)objc_msgSend)(self, getAttrSEL));
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(long long)]]) {
        return @(((long long(*)(id,SEL))(void *)objc_msgSend)(self, getAttrSEL));
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(unsigned char)]]) {
        char oldValue = ((unsigned char (*)(id,SEL))(void *)objc_msgSend)(self, getAttrSEL);
        return [NSString stringWithFormat:@"%c", oldValue];
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(unsigned short)]]) {
        return @(((unsigned short(*)(id,SEL))(void *)objc_msgSend)(self, getAttrSEL));
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(unsigned int)]]) {
        return @(((unsigned int(*)(id,SEL))(void *)objc_msgSend)(self, getAttrSEL));
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(unsigned long)]]) {
        return @(((unsigned long(*)(id,SEL))(void *)objc_msgSend)(self, getAttrSEL));
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(unsigned long long)]]) {
        return @(((unsigned long long(*)(id,SEL))(void *)objc_msgSend)(self, getAttrSEL));
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(bool)]]) {
        return @(((bool (*)(id,SEL))(void *)objc_msgSend)(self, getAttrSEL));
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(float)]]) {
        return @(((float (*)(id,SEL))(void *)objc_msgSend)(self, getAttrSEL));
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(double)]]) {
        return @(((double(*)(id,SEL))(void *)objc_msgSend)(self, getAttrSEL));
    }
    return nil;
}

#pragma mark - set New

void l_kvo_set_newValue(IMP imp, id receiver, SEL cmd, id newValue, const char * typeEncoding) {
    NSString *type = [[NSString stringWithUTF8String:typeEncoding] substringFromIndex:@"v24@0:8".length];
    if ([type containsString:[NSString stringWithUTF8String:@encode(char)]]) {
        char c = [newValue charValue];
        ((void(*)(id,SEL,char))(void *)imp)(receiver, cmd, c);
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(short)]]) {
        short s = [newValue shortValue];
        ((void(*)(id,SEL,short))(void *)imp)(receiver, cmd, s);
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(int)]]) {
        ((void(*)(id,SEL,int))(void *)imp)(receiver, cmd, [newValue intValue]);
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(long)]]) {
        ((void(*)(id,SEL,long))(void *)imp)(receiver, cmd, [newValue longValue]);
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(long long)]]) {
        ((void(*)(id,SEL,long long))(void *)imp)(receiver, cmd, [newValue longLongValue]);
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(unsigned char)]]) {
        ((void(*)(id,SEL,unsigned char))(void *)imp)(receiver, cmd, [newValue unsignedCharValue]);
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(unsigned short)]]) {
        ((void(*)(id,SEL,unsigned short))(void *)imp)(receiver, cmd, [newValue unsignedShortValue]);
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(unsigned int)]]) {
        ((void(*)(id,SEL,unsigned int))(void *)imp)(receiver, cmd, [newValue unsignedIntValue]);
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(unsigned long)]]) {
        ((void(*)(id,SEL,unsigned long))(void *)imp)(receiver, cmd, [newValue unsignedLongValue]);
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(unsigned long long)]]) {
        ((void(*)(id,SEL,unsigned long long))(void *)imp)(receiver, cmd, [newValue unsignedLongLongValue]);
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(BOOL)]]) {
        ((void(*)(id,SEL,BOOL))(void *)imp)(receiver, cmd, [newValue boolValue]);
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(float)]]) {
        ((void(*)(id,SEL,float))(void *)imp)(receiver, cmd, [newValue floatValue]);
        
    } else if ([type containsString:[NSString stringWithUTF8String:@encode(double)]]) {
        ((void(*)(id,SEL,double))(void *)imp)(receiver, cmd, [newValue doubleValue]);
    }
}


void l_kvo_setter_basic(NSObject *self, SEL cmd, id newValue) {
    NSObject *rootListener = self;
    while (rootListener.l_kvo_retainBy) {
        rootListener = rootListener.l_kvo_retainBy;
    }
    
    NSString *getterSELName = l_kvo_getterSELName(cmd);
    
    NSMutableArray<LKVOObserver *> *notifys = @[].mutableCopy;
    
    for (LKVOObserver *observer in rootListener.l_kvo_obvservers) {
        NSArray *components = [observer.keyPath componentsSeparatedByString:@"."];
        if ([components containsObject:getterSELName]) {
            [notifys addObject:observer];
        }
    }
    const char *typeEncoding = method_getTypeEncoding(class_getInstanceMethod(object_getClass(self), cmd));
    for (LKVOObserver *observer in notifys) {
        NSMutableDictionary *dict = @{}.mutableCopy;
        
        SEL getAttrSEL = sel_registerName(getterSELName.UTF8String);
        if (observer.options & L_KVO_OPTIONSOLD) {
            dict[LKVOKeyOld] = l_kvo_oldValue(self, typeEncoding, getAttrSEL);
        }
        if (observer.options & L_KVO_OPTIONSNEW) {
            dict[LKVOKeyNew] = newValue;
        }
        ((void(*)(id,SEL,id,id,id))(void *)objc_msgSend)(observer.observer, @selector(l_kvo_observeValueForKeyPath:object:change:), observer.keyPath, rootListener, dict);
    }
    
    //调用父类实现设置新值
    IMP superIMP = class_getMethodImplementation(class_getSuperclass(object_getClass(self)), cmd);
    l_kvo_set_newValue(superIMP, self, cmd, newValue, typeEncoding);
}

void l_kvo_setter_objc(NSObject *self, SEL cmd, id newValue) {
    NSObject *rootListener = self;
    while (rootListener.l_kvo_retainBy) {
        rootListener = rootListener.l_kvo_retainBy;
    }

    NSString *getterSELName = l_kvo_getterSELName(cmd);

    NSMutableArray<LKVOObserver *> *notifys = @[].mutableCopy;
    
    for (LKVOObserver *observer in rootListener.l_kvo_obvservers) {
        NSArray *components = [observer.keyPath componentsSeparatedByString:@"."];
        if ([components containsObject:getterSELName]) {
            [notifys addObject:observer];
        }
    }
    
    for (LKVOObserver *observer in notifys) {
        NSMutableDictionary *dict = @{}.mutableCopy;
        
        SEL getAttrSEL = sel_registerName(getterSELName.UTF8String);
        id oldValue = ((id(*)(id,SEL))(void *)objc_msgSend)(self, getAttrSEL);
        NSRange range = [observer.keyPath rangeOfString:getterSELName];
        BOOL hasMoreAttr = (range.location + range.length) != observer.keyPath.length;
        id endNewValue = newValue;
        if (hasMoreAttr) {
            //后面还有更多属性
            NSString *moreAttrs = [observer.keyPath substringFromIndex:range.location + range.length+1];
            NSArray *components = [moreAttrs componentsSeparatedByString:@"."];
            for (NSString *str in components) {
                getAttrSEL = sel_registerName(str.UTF8String);
                if ([oldValue respondsToSelector:getAttrSEL]) {
                    oldValue = ((id(*)(id,SEL))(void *)objc_msgSend)(oldValue, getAttrSEL);
                }
                if ([endNewValue respondsToSelector:getAttrSEL]) {
                    endNewValue = ((id(*)(id,SEL))(void *)objc_msgSend)(endNewValue, getAttrSEL);
                }
            }
            
            [newValue setL_kvo_retainBy:self];
            [newValue l_kvo_isaSwizzleWithKeyPath:moreAttrs];
        }
        
        if (observer.options & L_KVO_OPTIONSOLD) {
            dict[LKVOKeyOld] = oldValue;
        }
        if (observer.options & L_KVO_OPTIONSNEW) {
            dict[LKVOKeyNew] = endNewValue;
        }
        ((void(*)(id,SEL,id,id,id))(void *)objc_msgSend)(observer.observer, @selector(l_kvo_observeValueForKeyPath:object:change:), observer.keyPath, rootListener, dict);
    }
    
    IMP superIMP = class_getMethodImplementation(class_getSuperclass(object_getClass(self)), cmd);
    ((void(*)(id,SEL,id))(void *)superIMP)(self, cmd, newValue);
}



@end
