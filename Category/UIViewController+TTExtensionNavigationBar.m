//
//  UIViewController+TTExtensionNavigationBar.m
//  TestRepeatLayerDemo
//
//  Created by sun-zt on 2018/11/21.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import "UIViewController+TTExtensionNavigationBar.h"
@import ObjectiveC;

@interface UIViewController (TTExtensionNavigationBar_temp)

@property (nonatomic, strong) UIImageView *TT_navgationBarBackgroundView;
@property (nonatomic, assign, getter=isTT_navigationBarSetBackgroundView) BOOL TT_navigationBarSetBackgroundView;

@end

#define TT_EXTENSION_NAV_BAR_NO_NavigationController \
if (!self.navigationController) {\
return;\
}

NS_INLINE void TT_extension_vc_nav_bar_swizzleInstanceSelector(Class class, SEL originalSelector, SEL newSelector) {
    Method origMethod     = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, newSelector);
    
    BOOL isAdd = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if(isAdd) {
        class_replaceMethod(class, newSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, swizzledMethod);
    }
}

typedef void(^TT_extension_nav_bar_block_type)(id obj);
NS_INLINE void TT_extension_nav_bar_exist_property_opertion(id self, SEL pKey, TT_extension_nav_bar_block_type block) {
    if (!self) {
        return;
    }
    if (pKey == NULL) {
        NSLog(@"pKey can't be null...");
        return;
    }
    if (!block) {
        return;
    }
    NSObject *obj = objc_getAssociatedObject(self, pKey);
    block(obj);
    block = nil;
}

NS_INLINE CGRect TT_extension_nav_bar_custom_bar_background_view_frame(UIViewController *self) {
    CGRect barFrame = self.navigationController.navigationBar.frame;
    barFrame.size.height += CGRectGetMinY(barFrame);
    barFrame.origin.y  = - CGRectGetMinY(barFrame);
    return barFrame;
}

static void TT_extension_nav_bar_add_navigation_bar_to_VC(UIViewController *self) {
    [self.navigationController.navigationBar setTT_customBackgroundView:nil];
    if (!self.isTT_navigationBarSetBackgroundView) { //系统
        [self.navigationController.navigationBar TT_resetTranslitionBar];
        UIView *background = self.navigationController.navigationBar.TT_translitionBar;
        if (!background) return;
        [self.view addSubview:background];
    }else { //自定义
        UIView *background = self.TT_navgationBarBackgroundView;
        CGRect barFrame = TT_extension_nav_bar_custom_bar_background_view_frame(self);
        barFrame.origin.y = 0;
        background.frame  = barFrame;
        [self.view addSubview:background];
    }
}

static void TT_extension_nav_bar_to_willappear_VC(UIViewController *self) {
    TT_extension_nav_bar_add_navigation_bar_to_VC(self);
    BOOL hidden = self.navigationController.viewControllers.count > 1;
    hidden = hidden || (!hidden && self.isTT_navigationBarSetBackgroundView);
    self.navigationController.navigationBar.TT_hiddenBarBackground = YES;
}

static void TT_extension_nav_bar_to_willdisappear_VC(UIViewController *self) {
    UIViewController *topVC = self.navigationController.topViewController;
    //还原当前导航栏状态的修改
    TT_extension_nav_bar_exist_property_opertion(topVC, @selector(TT_navigationBarHidden), ^(NSNumber *obj) {
        if (obj) return ;
        if (self.navigationController.isNavigationBarHidden == NO) return;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    });
    TT_extension_nav_bar_exist_property_opertion(topVC, @selector(TT_navigationBarAlpha), ^(NSNumber *obj) {
        if (obj) return ;
        self.navigationController.navigationBar.alpha = 1;
    });
    
    //修改当前导航栏
    TT_extension_nav_bar_add_navigation_bar_to_VC(self);
}

static void TT_extension_nav_bar_to_didappear_VC(UIViewController *self) {
    if (!self.isTT_navigationBarSetBackgroundView) {
        [self.navigationController.navigationBar TT_resetTranslitionBar];
    }else {
        UIView *background = self.TT_navgationBarBackgroundView;
        CGRect barFrame  = TT_extension_nav_bar_custom_bar_background_view_frame(self);
        background.frame = barFrame;
        [background removeFromSuperview];
        self.navigationController.navigationBar.TT_customBackgroundView = background;
    }
    self.navigationController.navigationBar.TT_hiddenBarBackground = self.isTT_navigationBarSetBackgroundView;
}

@implementation UIViewController (TTExtensionNavigationBar)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TT_extension_vc_nav_bar_swizzleInstanceSelector(self,
                                                        @selector(viewWillAppear:),
                                                        @selector(TT_extension_nav_bar_viewWillAppear:));
        TT_extension_vc_nav_bar_swizzleInstanceSelector(self,
                                                        @selector(viewDidAppear:),
                                                        @selector(TT_extension_nav_bar_viewDidAppear:));
        TT_extension_vc_nav_bar_swizzleInstanceSelector(self,
                                                        @selector(viewWillDisappear:),
                                                        @selector(TT_extension_nav_bar_viewWillDisappear:));
        TT_extension_vc_nav_bar_swizzleInstanceSelector(self,
                                                        @selector(viewDidDisappear:),
                                                        @selector(TT_extension_nav_bar_viewDidDisappear:));
    });
}

#pragma mark - swizzle method

- (void)TT_extension_nav_bar_viewWillAppear:(BOOL)animated {
    [self TT_extension_nav_bar_viewWillAppear:animated];
    
    TT_EXTENSION_NAV_BAR_NO_NavigationController
    
    TT_extension_nav_bar_exist_property_opertion(self, @selector(TT_navigationBarHidden), ^(NSNumber *obj) {
        if (!obj) return ;
        [self.navigationController setNavigationBarHidden:obj.boolValue animated:animated];
    });
    //如果导航栏隐藏 --直接返回
    if (self.navigationController.isNavigationBarHidden) return;
    
    [self TT_extension_nav_bar_updateNavigationBar:YES];
}

- (void)TT_extension_nav_bar_viewDidAppear:(BOOL)animated {
    [self TT_extension_nav_bar_viewDidAppear:animated];
    
    TT_EXTENSION_NAV_BAR_NO_NavigationController
    
    TT_extension_nav_bar_to_didappear_VC(self);
}

- (void)TT_extension_nav_bar_viewWillDisappear:(BOOL)animated {
    [self TT_extension_nav_bar_viewWillDisappear:animated];
    
    TT_EXTENSION_NAV_BAR_NO_NavigationController

    if (self.navigationController.topViewController == self) return;
    
    TT_extension_nav_bar_to_willdisappear_VC(self);
}

- (void)TT_extension_nav_bar_viewDidDisappear:(BOOL)animated {
    [self TT_extension_nav_bar_viewDidDisappear:animated];
    
    TT_EXTENSION_NAV_BAR_NO_NavigationController
}

#pragma mark - property method

- (void)setTT_navigationBarBackgroundColor:(UIColor *)TT_navigationBarBackgroundColor {
    self.TT_navigationBarSetBackgroundView = YES;
    objc_setAssociatedObject(self, @selector(TT_navigationBarBackgroundColor), TT_navigationBarBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self TT_extension_nav_bar_updateNavigationBar:NO];
}

- (UIColor *)TT_navigationBarBackgroundColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTT_navigationBarBackgroundImage:(UIColor *)TT_navigationBarBackgroundImage {
    self.TT_navigationBarSetBackgroundView = YES;
    objc_setAssociatedObject(self, @selector(TT_navigationBarBackgroundImage), TT_navigationBarBackgroundImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self TT_extension_nav_bar_updateNavigationBar:NO];
}

- (UIColor *)TT_navigationBarBackgroundImage {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTT_navigationBarBackgroundAlpha:(CGFloat)TT_navigationBarBackgroundAlpha {
    self.TT_navigationBarSetBackgroundView = YES;
    if (TT_navigationBarBackgroundAlpha == self.TT_navigationBarBackgroundAlpha) {
        return;
    }
    objc_setAssociatedObject(self, @selector(TT_navigationBarBackgroundAlpha), @(TT_navigationBarBackgroundAlpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self TT_extension_nav_bar_updateNavigationBar:NO];
}

- (CGFloat)TT_navigationBarBackgroundAlpha {
    NSNumber *alpha = objc_getAssociatedObject(self, _cmd);
    if (alpha) {
        return alpha.floatValue;
    }
    return 1;
}

- (void)setTT_navigationBarAlpha:(CGFloat)TT_navigationBarAlpha {
    if (TT_navigationBarAlpha == self.TT_navigationBarAlpha) {
        return;
    }
    objc_setAssociatedObject(self, @selector(TT_navigationBarAlpha), @(TT_navigationBarAlpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self TT_extension_nav_bar_updateNavigationBar:NO];
}

- (CGFloat)TT_navigationBarAlpha {
    NSNumber *alpha = objc_getAssociatedObject(self, _cmd);
    if (alpha) {
        return alpha.floatValue;
    }
    return 1;
}

- (void)setTT_navigationBarHidden:(BOOL)TT_navigationBarHidden {
    if (TT_navigationBarHidden == self.TT_navigationBarHidden) {
        return;
    }
    objc_setAssociatedObject(self, @selector(TT_navigationBarHidden), @(TT_navigationBarHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self TT_extension_nav_bar_updateNavigationBar:NO];
}

- (BOOL)TT_navigationBarHidden {
    NSNumber *hidden = objc_getAssociatedObject(self, _cmd);
    if (hidden) {
        return hidden.boolValue;
    }
    return NO;
}

#pragma mark - inner
#pragma mark - private property
- (void)setTT_navgationBarBackgroundView:(UIImageView *)TT_navgationBarBackgroundView {
    objc_setAssociatedObject(self, @selector(TT_navgationBarBackgroundView), TT_navgationBarBackgroundView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImageView *)TT_navgationBarBackgroundView {
    UIImageView *barBackgroundView = objc_getAssociatedObject(self, _cmd);
    if (!barBackgroundView) {
        CGRect barFrame = TT_extension_nav_bar_custom_bar_background_view_frame(self);
        barBackgroundView = [[UIImageView alloc] initWithFrame:barFrame];
        barBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self setTT_navgationBarBackgroundView:barBackgroundView];
    }
    return barBackgroundView;
}

- (BOOL)isTT_navigationBarSetBackgroundView {
    NSNumber *value = objc_getAssociatedObject(self, _cmd);
    return value.boolValue;
}

- (void)setTT_navigationBarSetBackgroundView:(BOOL)TT_navigationBarSetBackgroundView {
    objc_setAssociatedObject(self, @selector(isTT_navigationBarSetBackgroundView), @(TT_navigationBarSetBackgroundView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - private method

- (void)TT_extension_nav_bar_updateNavigationBar:(BOOL)isFromWillAppear {
    if (!(isFromWillAppear || (self.isViewLoaded && self.view.window))) {
        return;
    }
    UINavigationBar *currentNavigationBar = self.navigationController.navigationBar;
    
    TT_extension_nav_bar_exist_property_opertion(self, @selector(TT_navigationBarBackgroundColor), ^(UIColor *obj) {
        if (!obj) return ;
        self.TT_navgationBarBackgroundView.backgroundColor = obj;
    });
    
    TT_extension_nav_bar_exist_property_opertion(self, @selector(TT_navigationBarBackgroundImage), ^(UIImage *obj) {
        if (!obj) return ;
        self.TT_navgationBarBackgroundView.image = obj;
    });
    
    TT_extension_nav_bar_exist_property_opertion(self, @selector(TT_navigationBarBackgroundAlpha), ^(NSNumber *obj) {
        if (!obj) return ;
        self.TT_navgationBarBackgroundView.alpha = obj.floatValue;
    });
    
    TT_extension_nav_bar_exist_property_opertion(self, @selector(TT_navigationBarAlpha), ^(NSNumber *obj) {
        if (!obj) {
            currentNavigationBar.alpha = 1;
            return ;
        }
        currentNavigationBar.alpha = obj.floatValue;
    });
    
    if (isFromWillAppear) {
        TT_extension_nav_bar_to_willappear_VC(self);
    }else {
        TT_extension_nav_bar_exist_property_opertion(self, @selector(TT_navgationBarBackgroundView), ^(UIView *obj) {
            self.navigationController.navigationBar.TT_hiddenBarBackground = obj;
            self.navigationController.navigationBar.TT_customBackgroundView = obj;
        });
    }
}

@end

NS_INLINE UIView *TT_extension_vc_nav_bar_get_background_view(UINavigationBar *self) {
    __block UIView *tempBackground = nil;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSClassFromString(@"_UIBarBackground")]) {
            tempBackground = obj;
            *stop = YES;
        }
    }];
    return tempBackground;
}

@interface UINavigationBar (TTExtensionNavigationBarInner)

@property (nonatomic, assign) BOOL TT_navigationBarTransitionBar;

@end

@implementation UINavigationBar (TTExtensionNavigationBar)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TT_extension_vc_nav_bar_swizzleInstanceSelector(self,
                                                        @selector(layoutSubviews),
                                                        @selector(TT_extension_nav_bar_layoutSubviews));
    });
}

#pragma mark - swizzle
- (void)TT_extension_nav_bar_layoutSubviews {
    [self TT_extension_nav_bar_layoutSubviews];
    
    if (self.TT_navigationBarTransitionBar) {
        UIView *other = TT_extension_vc_nav_bar_get_background_view(self);
        CGRect frame = other.frame;
        frame.origin.y    = - CGRectGetMinY(self.frame);
        frame.size.height = CGRectGetMaxY(self.frame);
        other.frame = frame;
        return;
    }
    
    TT_extension_nav_bar_exist_property_opertion(self, @selector(isTT_hiddenBarBackground), ^(NSNumber *obj) {
        if (!obj) return ;
        TT_extension_vc_nav_bar_get_background_view(self).hidden = obj.boolValue;
    });
    TT_extension_nav_bar_exist_property_opertion(self, @selector(TT_customBackgroundView), ^(UIView *obj) {
        if (!obj) return ;
        [self insertSubview:obj atIndex:0];
    });
    TT_extension_nav_bar_exist_property_opertion(self, @selector(TT_translitionBar), ^(UINavigationBar *obj) {
        if (!obj) return ;
        obj.frame = self.frame;
    });
}

#pragma mark - property method
- (void)setTT_hiddenBarBackground:(BOOL)TT_hiddenBarBackground {
    if (TT_hiddenBarBackground == self.isTT_hiddenBarBackground) {
        return;
    }
    objc_setAssociatedObject(self, @selector(isTT_hiddenBarBackground), @(TT_hiddenBarBackground), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (!self.window) {
        return;
    }
    
    [self setNeedsLayout];
}

- (BOOL)isTT_hiddenBarBackground {
    NSNumber *value = objc_getAssociatedObject(self, _cmd);
    return value.boolValue;
}

- (void)TT_resetTranslitionBar {
    TT_extension_nav_bar_exist_property_opertion(self, @selector(TT_translitionBar), ^(UIView *obj) {
        if (!obj) return ;
        [obj removeFromSuperview];
    });
    objc_setAssociatedObject(self, @selector(TT_translitionBar), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (__kindof UIView *)TT_translitionBar {
    UIView *background = objc_getAssociatedObject(self, _cmd);
    if (background) return background;
    
    UINavigationBar *bar = [self TT_customNavigationBar];
    [bar setBackgroundImage:[self backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
    bar.shadowImage  = self.shadowImage;
    bar.barTintColor = self.barTintColor;
    bar.tintColor    = self.tintColor;
    
    objc_setAssociatedObject(self, _cmd, bar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return bar;
}

- (void)setTT_customBackgroundView:(__kindof UIView *)TT_customBackgroundView {
    UIView *tBackground = self.TT_customBackgroundView;
    if (!tBackground && !TT_customBackgroundView) {
        return;
    }
    if ([tBackground isEqual:TT_customBackgroundView] &&
        [self.subviews.firstObject isEqual:tBackground]) {
        return;
    }
    if (tBackground && ![tBackground isEqual:TT_customBackgroundView]) {
        [tBackground removeFromSuperview];
    }
    
    objc_setAssociatedObject(self, @selector(TT_customBackgroundView), TT_customBackgroundView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (!self.window) {
        return;
    }
    [self setNeedsLayout];
}

- (__kindof UIView *)TT_customBackgroundView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTT_navigationBarTransitionBar:(BOOL)TT_navigationBarTransitionBar {
    objc_setAssociatedObject(self, @selector(TT_navigationBarTransitionBar), @(TT_navigationBarTransitionBar), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)TT_navigationBarTransitionBar {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (UINavigationBar *)TT_customNavigationBar {
    UINavigationBar *bar = objc_getAssociatedObject(self, _cmd);
    if (!bar) {
        bar = [[UINavigationBar alloc] initWithFrame:self.bounds];
        bar.TT_navigationBarTransitionBar = YES;
        bar.backgroundColor = UIColor.redColor;
        objc_setAssociatedObject(self, _cmd, bar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return bar;
}

@end
