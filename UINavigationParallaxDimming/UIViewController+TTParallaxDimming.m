//
//  UIViewController+TTParallaxDimming.m
//  TestRepeatLayerDemo
//
//  Created by sun-zt on 2018/11/12.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import "UIViewController+TTParallaxDimming.h"
@import ObjectiveC;

NS_INLINE void TT_nav_parallax_swizzleInstanceSelector(Class class, SEL originalSelector, SEL newSelector) {
    Method origMethod     = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, newSelector);
    
    BOOL isAdd = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if(isAdd) {
        class_replaceMethod(class, newSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, swizzledMethod);
    }
}

@interface UIView (TTParallaxDimming)

@end

@implementation UIViewController (TTParallaxDimming)

- (void)setTT_parallaxColor:(UIColor *)parallaxColor {
    objc_setAssociatedObject(self, _cmd, parallaxColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)TT_parallaxColor {
    return objc_getAssociatedObject(self, @selector(setTT_parallaxColor:));
}

@end

@implementation UIView (TTParallaxDimming)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // _UI Parallax DimmingView
        NSString *parallaxDimminClass = [NSString stringWithFormat:@"_UIPa%@%@", @"rallaxDi", @"mmingView"];
        Class class = NSClassFromString(parallaxDimminClass);
        if (!class) return ;
        TT_nav_parallax_swizzleInstanceSelector(class,
                                                @selector(layoutSubviews),
                                                @selector(TT_parallax_layoutSubviews));
    });
}

- (void)TT_parallax_layoutSubviews {
    [self TT_parallax_layoutSubviews];
    
    NSLog(@"TT_parallax_layoutSubviews");
    
    UINavigationController *nav = [self TT_parallax_nextResponder:self];
    if (!nav) return;
    UIViewController *topVC = nav.topViewController;
    
    if (self.subviews.count == 0) {
//        UIView *firstVCView = wrapperView.subviews.firstObject.subviews.firstObject;
        UIColor *parallaxColor = topVC.TT_parallaxColor? : nav.TT_parallaxColor;
        if (!parallaxColor) return;
        self.backgroundColor = [parallaxColor colorWithAlphaComponent:0.1];
        return;
    }
    
    UIImageView *imageView = self.subviews.firstObject;
    if (!imageView || ![imageView isKindOfClass:UIImageView.class]) return;
    
//    UIView *secondVCView = self.subviews.lastObject;
    UIColor *parallaxColor = topVC.TT_parallaxColor? : nav.TT_parallaxColor;
    if (!parallaxColor) return;

    imageView.tintColor = parallaxColor;
    UIImage *image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    imageView.image = image;
}

- (UINavigationController *)TT_parallax_nextResponder:(UIResponder *)view {
    UIResponder *nextResponder = view.nextResponder;
    if (!nextResponder || [nextResponder isKindOfClass:UINavigationController.class]) {
        return (UINavigationController *)nextResponder;
    }
    return [self TT_parallax_nextResponder:nextResponder];
}

@end
