//
//  NSObject+TTSwizzle.h
//

#import <Foundation/Foundation.h>

typedef id (*_IMP)(id, SEL, ...);

@interface NSObject (TTSwizzle)

/**
 直接交换类方法 -- 对私有类的交换
 static _IMP _xx_IMP;
 _xx_IMP = [self tt_replaceOriginalClass:NSClassFromString(@"UIDynamicSystemColor") withAltClass:ViewController.class method:NSSelectorFromString(@"_resolvedColorWithTraitCollection:")]

 在 ViewController 中实现 判断
 - (id)_resolvedColorWithTraitCollection:(id)p {
     id ret = _xx_IMP(self, _cmd, p);
     NSLog(@"---");
     return ret;
 }
 
 */
+ (_IMP)tt_replaceOriginalClass:(Class)origClass withAltClass:(Class)altClass method:(SEL)sel;

+ (BOOL)tt_swizzleOriginalMethod:(SEL)origSel withAltMethod:(SEL)altSel;

@end
