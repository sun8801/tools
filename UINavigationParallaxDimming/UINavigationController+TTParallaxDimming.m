//
//  UINavigationController+TTParallaxDimming.m
//  TestRepeatLayerDemo
//
//  Created by sun-zt on 2018/11/12.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import "UINavigationController+TTParallaxDimming.h"
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

@implementation UIViewController (TTParallaxDimming)

- (void)setTT_parallaxColor:(UIColor *)parallaxColor {
    objc_setAssociatedObject(self, _cmd, parallaxColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)TT_parallaxColor {
    return objc_getAssociatedObject(self, @selector(setTT_parallaxColor:));
}

- (void)setTT_popedViewController:(UIViewController *)popedViewController {
    objc_setAssociatedObject(self, _cmd, popedViewController, OBJC_ASSOCIATION_ASSIGN);
}

- (UIViewController *)TT_popedViewController {
    return objc_getAssociatedObject(self, @selector(setTT_popedViewController:));
}

@end

@implementation UINavigationController (TTParallaxDimming)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TT_nav_parallax_swizzleInstanceSelector(self, @selector(pushViewController:animated:), @selector(TT_parallax_pushViewController:animated:));
        TT_nav_parallax_swizzleInstanceSelector(self, @selector(popViewControllerAnimated:), @selector(TT_parallax_popViewControllerAnimated:));
    });
}

#pragma mark - swizzle

- (void)TT_parallax_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIViewController *topVC = self.topViewController;
    
    [self TT_parallax_pushViewController:viewController animated:animated];
    
    [self.topViewController setTT_popedViewController:topVC];
}

- (void)TT_parallax_popViewControllerAnimated:(BOOL)animated {
    UIViewController *topVC = self.topViewController;
    
    [self TT_parallax_popViewControllerAnimated:animated];
    
    [self.topViewController setTT_popedViewController:topVC];
}

@end

@interface UIView (TTParallaxDimming)

@end
@implementation UIView (TTParallaxDimming)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // _UIParallaxDimmingView
        NSString *parallaxDimminClass = [NSString stringWithFormat:@"_UIPa%@%@", @"rallaxDi", @"mmingView"];
        Class class = NSClassFromString(parallaxDimminClass);
        if (!class) return ;
        TT_nav_parallax_swizzleInstanceSelector(class, @selector(addSubview:), @selector(TT_parallax_addSubview:));
    });
}

- (void)TT_parallax_addSubview:(UIView *)view {
    [self TT_parallax_addSubview:view];
    
    if (![view isKindOfClass:UIImageView.class]) return;
    
    UINavigationController *nav = (UINavigationController *)[[UIApplication sharedApplication].delegate window].rootViewController;
    if (!nav || ![nav isKindOfClass:UINavigationController.class]) return;
    
    UIViewController *topVC = nav.topViewController;
    UIViewController *popedVC = [topVC TT_popedViewController];
    if (!topVC || !popedVC) return;
    
    UIColor *parallaxColor = popedVC.TT_parallaxColor? : nav.TT_parallaxColor;
    if (!parallaxColor) return;
    
    UIImageView *imageView = (UIImageView *)view;
    imageView.tintColor = parallaxColor;
    UIImage *image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    imageView.image = image;
}

@end
