//
//  NSObject+TTSwizzle.m
//

#import "NSObject+TTSwizzle.h"

#import <objc/runtime.h>

@implementation NSObject (TTSwizzle)

+ (BOOL)tt_swizzleOriginalMethod:(SEL)origSel withAltMethod:(SEL)altSel {
    Method origMethod = class_getInstanceMethod(self, origSel);
    if (!origMethod) {
        return NO;
    }

    Method altMethod = class_getInstanceMethod(self, altSel);
    if (!altMethod) {
        return NO;
    }

    class_addMethod(self,
                    origSel,
                    class_getMethodImplementation(self, origSel),
                    method_getTypeEncoding(origMethod));
    class_addMethod(self,
                    altSel,
                    class_getMethodImplementation(self, altSel),
                    method_getTypeEncoding(altMethod));

    method_exchangeImplementations(class_getInstanceMethod(self, origSel), class_getInstanceMethod(self, altSel));
    return YES;
}

+ (_IMP)tt_replaceOriginalClass:(Class)origClass withAltClass:(Class)altClass method:(SEL)sel {
    Method oldMethod = class_getInstanceMethod(origClass, sel);
    IMP oldIMP       = method_getImplementation(oldMethod);
    IMP newIMP       = class_getMethodImplementation(altClass, sel);
    method_setImplementation(oldMethod, newIMP);
    return (_IMP)oldIMP;
}

@end
