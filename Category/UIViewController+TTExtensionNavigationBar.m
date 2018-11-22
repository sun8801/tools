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
NS_INLINE void TT_extension_nav_bar_exist_property_opertion(UIViewController *self, SEL pKey, TT_extension_nav_bar_block_type block) {
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

NS_INLINE void TT_extension_nav_bar_to_willappear_VC(UIViewController *self) {
    if (!self.isTT_navigationBarSetBackgroundView) return;
    //消掉navigationBar 的UIVisualEffectView 层
    UINavigationBar *currentNavigationBar = self.navigationController.navigationBar;
    [currentNavigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    currentNavigationBar.shadowImage = [UIImage new];
    [currentNavigationBar.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSClassFromString(@"_UIBarBackground")]) {
            obj.hidden = YES;
            *stop = YES;
        }
    }];
    
    CGRect barFrame = TT_extension_nav_bar_custom_bar_background_view_frame(self);
    barFrame.origin.y = 0;
    [self.TT_navgationBarBackgroundView removeFromSuperview];
    self.TT_navgationBarBackgroundView.frame = barFrame;
    [self.view addSubview:self.TT_navgationBarBackgroundView];
}

NS_INLINE void TT_extension_nav_bar_to_didappear_VC(UIViewController *self) {
    if (!self.isTT_navigationBarSetBackgroundView) return;
    
    CGRect barFrame = TT_extension_nav_bar_custom_bar_background_view_frame(self);
    [self.TT_navgationBarBackgroundView removeFromSuperview];
    self.TT_navgationBarBackgroundView.frame = barFrame;
    [self.navigationController.navigationBar insertSubview:self.TT_navgationBarBackgroundView atIndex:0];
}

NS_INLINE void TT_extension_nav_bar_to_disappear_VC(UIViewController *self) {
    //修改当前导航栏
    if (!self.isTT_navigationBarSetBackgroundView) return;
    [self.TT_navgationBarBackgroundView removeFromSuperview];
    CGRect barFrame = self.TT_navgationBarBackgroundView.frame;
    barFrame.origin.y = 0;
    self.TT_navgationBarBackgroundView.frame = barFrame;
    [self.view addSubview:self.TT_navgationBarBackgroundView];
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
    
    UIViewController *topVC = self.navigationController.topViewController;
    if (topVC == self) {
        return;
    }
    //还原当前导航栏状态的修改
    TT_extension_nav_bar_exist_property_opertion(topVC, @selector(TT_navigationBarHidden), ^(NSNumber *obj) {
        if (obj) return ;
        if (self.navigationController.isNavigationBarHidden == NO) return;
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    });
    TT_extension_nav_bar_exist_property_opertion(topVC, @selector(TT_navigationBarAlpha), ^(NSNumber *obj) {
        if (obj) return ;
        self.navigationController.navigationBar.alpha = 1;
    });
    
    if (!topVC.isTT_navigationBarSetBackgroundView) {
        UIImage *image = [[UINavigationBar appearance] backgroundImageForBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [UINavigationBar appearance].shadowImage;
    }
    
    TT_extension_nav_bar_to_disappear_VC(self);
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
    
    TT_extension_nav_bar_to_willappear_VC(self);
}

@end
