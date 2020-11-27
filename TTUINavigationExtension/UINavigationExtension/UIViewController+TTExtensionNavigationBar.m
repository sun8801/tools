//
//  UIViewController+TTExtensionNavigationBar.m
//  TestRepeatLayerDemo
//
//  Created by sun-zt on 2018/11/21.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import "UIViewController+TTExtensionNavigationBar.h"
@import ObjectiveC;

// !!!: UINavigationBar
@interface UINavigationBar (TTExtensionNavigationBar)

/**
 设置隐藏背景（为了改变背景色/消除模糊层）
 // 消掉navigationBar 的UIVisualEffectView 层
 */
@property (nonatomic, assign, getter=isTT_hiddenBarBackground) BOOL TT_hiddenBarBackground;

/**
 设置导航栏背景透明度 [0 - 1]
 */
@property (nonatomic, assign) CGFloat TT_barBackgroundAlpha;

/**
 获得运动bar 将要消失
 */
- (UIView *)TT_transitionDisAppearBar:(UIViewController *)vc;

- (void)TT_resettransitionDisAppearBar;

/**
 获得运动bar 出现
 */
- (UIView *)TT_transitionAppearBar:(UIViewController *)vc;

- (void)TT_resettransitionAppearBar;

//////////////////////////////////////////////////////////////////////////////////////
//-----------------------  自定义backgroundView  ------------------------------------//
/////////////////////////////////////////////////////////////////////////////////////
@property (nonatomic, strong, readonly) UIImageView *TT_customBackgroundDisAppearView;

- (void)TT_resetCustomBackgroundDisAppearView;

@property (nonatomic, strong, readonly) UIImageView *TT_customBackgroundAppearView;

- (void)TT_resetcCustomBackgroundAppearView;

- (void)TT_showCustomBackgroundDidAppearView;

@end

@interface UIViewController (TTExtensionNavigationBar_temp)

@property (nonatomic, assign, getter=isTT_navigationBarSetBackgroundView) BOOL TT_navigationBarSetBackgroundView;
@property (nonatomic, assign, getter=isTT_navigationBarEqualed) BOOL TT_navigationBarEqualed;
@property (nonatomic, assign, getter=isTT_navigationPushOrPoped) BOOL TT_navigationPushOrPoped;

//用于edgesForExtendedLayout 引起view frame 问题
@property (nonatomic, strong) UIView *TT_extendNavigationBarView;

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
NS_INLINE void TT_extension_nav_bar_exist_property_operation(id self, SEL pKey, TT_extension_nav_bar_block_type block) {
    if (!self) return;
    if (!pKey) {
        NSLog(@"pKey can't be null...");
        return;
    }
    if (!block) return;
    
    NSObject *obj = objc_getAssociatedObject(self, pKey);
    block(obj);
    block = nil;
}

NS_INLINE void TT_extension_nav_bar_no_animation_block(dispatch_block_t block) {
    if (!block) {
        return;
    }
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    block();
    [CATransaction commit];
}

NS_INLINE void TT_extension_nav_bar_update_custom_background_bar(UIViewController *self, UIView *background) {
    if (!background || !self) return;
    if ([background isKindOfClass:UIImageView.class]) {
        background.backgroundColor = self.TT_navigationBarBackgroundColor;
        [(UIImageView *)background setImage:self.TT_navigationBarBackgroundImage];
    }
    background.alpha = self.TT_navigationBarBackgroundAlpha;
    background.hidden = self.TT_navigationBarHidden;
}

NS_INLINE BOOL TT_extension_nav_bar_is_equaled(UIViewController *self, UIViewController *topVC) {
    //计算导航栏是否相同
    BOOL isBarEqual = topVC.isTT_navigationBarSetBackgroundView == self.isTT_navigationBarSetBackgroundView;
    if (isBarEqual && topVC.isTT_navigationBarSetBackgroundView) {
        BOOL customInfoEqual = topVC.TT_navigationBarBackgroundImage &&
        [self.TT_navigationBarBackgroundImage isEqual:topVC.TT_navigationBarBackgroundImage];
        if (!customInfoEqual && !topVC.TT_navigationBarBackgroundImage && !self.TT_navigationBarBackgroundImage) {
            customInfoEqual = topVC.TT_navigationBarBackgroundColor.hash == self.TT_navigationBarBackgroundColor.hash;
        }
        isBarEqual = customInfoEqual;
    }
    if (isBarEqual) {
        isBarEqual &= (topVC.TT_navigationBarHidden == self.TT_navigationBarHidden);
    }
    if (isBarEqual) {
        CGFloat alpha = fabs(topVC.TT_navigationBarBackgroundAlpha - self.TT_navigationBarBackgroundAlpha);
        isBarEqual &= (alpha < 0.1);
    }
    return isBarEqual;
}

//修正view frame 问题，  edgesForExtendedLayout引起
NS_INLINE void TT_extension_nav_to_VC_edgesForExtendedLayout(UIViewController *self, UIView *background) {
    CGRect selfFrame = self.view.frame;
    if (CGRectGetMinY(selfFrame) != 0) {
        CGFloat offsetY = CGRectGetMinY(selfFrame);
        CGRect frame = CGRectMake(0, -offsetY, CGRectGetWidth(selfFrame), offsetY);
        TT_extension_nav_bar_no_animation_block(^{
            self.TT_extendNavigationBarView.frame = frame;
            self.TT_extendNavigationBarView.backgroundColor = self.view.backgroundColor;
            [self.TT_extendNavigationBarView addSubview:background];
        });
    }else if (!(self.edgesForExtendedLayout & UIRectEdgeTop)) {
        CGFloat offsetY = CGRectGetMaxY(background.frame);
        CGRect frame = CGRectMake(0, -offsetY, CGRectGetWidth(selfFrame), offsetY);
        TT_extension_nav_bar_no_animation_block(^{
            self.TT_extendNavigationBarView.frame = frame;
            self.TT_extendNavigationBarView.backgroundColor = self.view.backgroundColor;
            [self.TT_extendNavigationBarView addSubview:background];
        });
    }else {
        [self.view addSubview:background];
    }
}

static void TT_extension_nav_bar_add_navigation_bar_to_VC(UIViewController *self, BOOL isWillApperar, BOOL isDidAppear) {
    UINavigationBar *bar = self.navigationController.navigationBar;
    if (!isDidAppear) {
        UIView *background = nil;
        if (self.isTT_navigationBarSetBackgroundView) { //自定义
            if (isWillApperar) {
                background = bar.TT_customBackgroundAppearView;
            }else {
                [bar TT_resetcCustomBackgroundAppearView];
                background = bar.TT_customBackgroundDisAppearView;
            }
        }else { //系统
            if (isWillApperar) {
                background = [bar TT_transitionAppearBar:self];
            }else {
                [bar TT_resettransitionAppearBar];
                background = [bar TT_transitionDisAppearBar:self];
            }
        }
        TT_extension_nav_bar_update_custom_background_bar(self, background);
        TT_extension_nav_to_VC_edgesForExtendedLayout(self, background);
        return;
    }
    
    //didAppear
    if (!self.isTT_navigationBarSetBackgroundView) {
        [bar TT_resetCustomBackgroundDisAppearView];
        [bar TT_resetcCustomBackgroundAppearView];
        [bar TT_resettransitionDisAppearBar];
        [bar TT_resettransitionAppearBar];
    }else {
        [bar TT_resettransitionDisAppearBar];
        [bar TT_resettransitionAppearBar];
        [bar TT_showCustomBackgroundDidAppearView];
    }
    bar.TT_barBackgroundAlpha = self.TT_navigationBarBackgroundAlpha;
}

static void TT_extension_nav_bar_to_willappear_VC(UIViewController *self) {
    if (self.isTT_navigationBarEqualed) { //左右相等时
        if (self.TT_navigationBarBackgroundAlpha < 1 ||
            self.isTT_navigationBarSetBackgroundView) {
            UINavigationBar *bar = self.navigationController.navigationBar;
            [bar setNeedsLayout];
        }
        return;
    };
    if (!self.isTT_navigationPushOrPoped) { //基类（显示nav.viewvc 1） 或 present 返回
        UINavigationBar *bar = self.navigationController.navigationBar;
        UIView *background = self.isTT_navigationBarSetBackgroundView ? bar.TT_customBackgroundAppearView : nil;
        TT_extension_nav_bar_update_custom_background_bar(self, background);
        [bar TT_showCustomBackgroundDidAppearView];
        bar.TT_hiddenBarBackground = background;
        bar.TT_barBackgroundAlpha  = self.TT_navigationBarBackgroundAlpha;
        return;
    }
    
    self.navigationController.navigationBar.TT_hiddenBarBackground = YES;
    TT_extension_nav_bar_add_navigation_bar_to_VC(self, YES, NO);
}

static void TT_extension_nav_bar_to_willdisappear_VC(UIViewController *self) {
    UIViewController *topVC = self.navigationController.topViewController;
    //还原当前导航栏状态的修改
    TT_extension_nav_bar_exist_property_operation(topVC, @selector(TT_navigationBarHidden), ^(NSNumber *obj) {
        if (obj) return ;
        if (self.navigationController.isNavigationBarHidden == NO) return;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    });
    TT_extension_nav_bar_exist_property_operation(topVC, @selector(TT_navigationBarAlpha), ^(NSNumber *obj) {
        if (obj) return ;
        self.navigationController.navigationBar.alpha = 1;
    });
    
    //计算导航栏是否相同
    //在iOS 9 时，viewdidload 加载稍晚
    if (!topVC.isViewLoaded) {
        [topVC view];
    }
    BOOL isBarEqual = TT_extension_nav_bar_is_equaled(self, topVC);
    topVC.TT_navigationBarEqualed = isBarEqual;
    if (isBarEqual) return;
    
    //修改当前导航栏
    topVC.TT_navigationPushOrPoped = YES;
    TT_extension_nav_bar_add_navigation_bar_to_VC(self, NO, NO);
}

static void TT_extension_nav_bar_to_didappear_VC(UIViewController *self) {
    if (self.isTT_navigationBarEqualed) {
        self.TT_navigationBarEqualed = NO;
        return;
    }
    if (!self.isTT_navigationPushOrPoped) return;
    self.TT_navigationPushOrPoped = NO;
    
    TT_extension_nav_bar_add_navigation_bar_to_VC(self, NO, YES);
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
    });
}

#pragma mark - swizzle method

- (void)TT_extension_nav_bar_viewWillAppear:(BOOL)animated {
    [self TT_extension_nav_bar_viewWillAppear:animated];
    
    TT_EXTENSION_NAV_BAR_NO_NavigationController
    
    TT_extension_nav_bar_exist_property_operation(self, @selector(TT_navigationBarHidden), ^(NSNumber *obj) {
        if (!obj) return ;
        [self.navigationController setNavigationBarHidden:obj.boolValue animated:animated];
    });
    //如果导航栏隐藏 --直接返回
    if (self.navigationController.isNavigationBarHidden) return;
    
    TT_extension_nav_bar_to_willappear_VC(self);
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

#pragma mark - property method

- (void)setTT_navigationBarBackgroundColor:(UIColor *)TT_navigationBarBackgroundColor {
    self.TT_navigationBarSetBackgroundView = YES;
    objc_setAssociatedObject(self, @selector(TT_navigationBarBackgroundColor), TT_navigationBarBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self TT_extension_nav_bar_updateNavigationBar];
}

- (UIColor *)TT_navigationBarBackgroundColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTT_navigationBarBackgroundImage:(UIImage *)TT_navigationBarBackgroundImage {
    self.TT_navigationBarSetBackgroundView = YES;
    objc_setAssociatedObject(self, @selector(TT_navigationBarBackgroundImage), TT_navigationBarBackgroundImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self TT_extension_nav_bar_updateNavigationBar];
}

- (UIImage *)TT_navigationBarBackgroundImage {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTT_navigationBarBackgroundAlpha:(CGFloat)TT_navigationBarBackgroundAlpha {
    if (TT_navigationBarBackgroundAlpha > 1) {
        TT_navigationBarBackgroundAlpha = 1;
    }
    if (TT_navigationBarBackgroundAlpha < 0) {
        TT_navigationBarBackgroundAlpha = 0;
    }
    if (TT_navigationBarBackgroundAlpha == self.TT_navigationBarBackgroundAlpha) {
        return;
    }
    objc_setAssociatedObject(self, @selector(TT_navigationBarBackgroundAlpha), @(TT_navigationBarBackgroundAlpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self TT_extension_nav_bar_updateNavigationBar];
}

- (CGFloat)TT_navigationBarBackgroundAlpha {
    NSNumber *alpha = objc_getAssociatedObject(self, _cmd);
    if (alpha) {
        return alpha.floatValue;
    }
    return 1;
}

- (void)setTT_navigationBarAlpha:(CGFloat)TT_navigationBarAlpha {
    if (TT_navigationBarAlpha > 1) {
        TT_navigationBarAlpha = 1;
    }
    if (TT_navigationBarAlpha < 0) {
        TT_navigationBarAlpha = 0;
    }
    if (TT_navigationBarAlpha == self.TT_navigationBarAlpha) {
        return;
    }
    objc_setAssociatedObject(self, @selector(TT_navigationBarAlpha), @(TT_navigationBarAlpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self TT_extension_nav_bar_updateNavigationBar];
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
    [self TT_extension_nav_bar_updateNavigationBar];
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

- (BOOL)isTT_navigationBarSetBackgroundView {
    NSNumber *value = objc_getAssociatedObject(self, _cmd);
    return value.boolValue;
}

- (void)setTT_navigationBarSetBackgroundView:(BOOL)TT_navigationBarSetBackgroundView {
    objc_setAssociatedObject(self, @selector(isTT_navigationBarSetBackgroundView), @(TT_navigationBarSetBackgroundView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isTT_navigationBarEqualed {
    NSNumber *value = objc_getAssociatedObject(self, _cmd);
    return value.boolValue;
}

- (void)setTT_navigationBarEqualed:(BOOL)isTT_navigationBarEqualed {
    objc_setAssociatedObject(self, @selector(isTT_navigationBarEqualed), @(isTT_navigationBarEqualed), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isTT_navigationPushOrPoped{
    NSNumber *value = objc_getAssociatedObject(self, _cmd);
    return value.boolValue;
}

- (void)setTT_navigationPushOrPoped:(BOOL)isTT_navigationPushOrPoped {
    objc_setAssociatedObject(self, @selector(isTT_navigationPushOrPoped), @(isTT_navigationPushOrPoped), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setTT_extendNavigationBarView:(UIView *)TT_extendNavigationBarView {
    objc_setAssociatedObject(self, @selector(TT_extendNavigationBarView), TT_extendNavigationBarView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)TT_extendNavigationBarView {
    UIView *view = objc_getAssociatedObject(self, _cmd);
    if (!view) {
        view = [UIView new];
        [self.view insertSubview:view atIndex:0];
        [self setTT_extendNavigationBarView:view];
    }
    return view;
}

#pragma mark - private method

- (void)TT_extension_nav_bar_updateNavigationBar {
    if (!(self.isViewLoaded && self.view.window)) {
        return;
    }
    UINavigationBar *currentNavigationBar = self.navigationController.navigationBar;
    UIImageView *background = self.isTT_navigationBarSetBackgroundView? currentNavigationBar.TT_customBackgroundAppearView: nil;
    TT_extension_nav_bar_update_custom_background_bar(self, background);
    
    TT_extension_nav_bar_exist_property_operation(self, @selector(TT_navigationBarAlpha), ^(NSNumber *obj) {
        if (!obj) {
            currentNavigationBar.alpha = 1;
            return ;
        }
        currentNavigationBar.alpha = obj.floatValue;
    });
    
    if (background) {
        [currentNavigationBar TT_showCustomBackgroundDidAppearView];
    }
    currentNavigationBar.TT_hiddenBarBackground = background;
    currentNavigationBar.TT_barBackgroundAlpha  = self.TT_navigationBarBackgroundAlpha;
}

@end

#pragma mark - UINavigationBar
// !!!: UINavigationBar

NS_INLINE UIView *TT_extension_vc_nav_bar_get_background_view(UINavigationBar *self) {
    __block UIView *tempBackground = nil;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // _UINavigationBarBackground  >=11 _UIBarBackground
        if ([NSStringFromClass(obj.class) containsString:@"BarBackground"]) {
            tempBackground = obj;
            *stop = YES;
        }
    }];
    return tempBackground;
}

@interface UINavigationBar (TTExtensionNavigationBarInner)


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
    

    CGRect backFrame = TT_extension_navigation_bar_custom_background_view_frame(self, YES);
    UIView *backView = TT_extension_vc_nav_bar_get_background_view(self);
    if (backView && !CGRectEqualToRect(backFrame, backView.frame)) {
        TT_extension_nav_bar_no_animation_block(^{
            backView.frame = backFrame;
        });
    }

    //取消运动是动画
    UIView *background = TT_extension_vc_nav_bar_get_background_view(self);
    TT_extension_nav_bar_no_animation_block(^{
        background.hidden = self.isTT_hiddenBarBackground;
        background.alpha  = self.TT_barBackgroundAlpha;
    });

    TT_extension_nav_bar_exist_property_operation(self, @selector(TT_customBackgroundAppearView), ^(UIView *obj) {
        if (!obj || (obj.superview && ![obj.superview isEqual:self])) return ;
        TT_extension_nav_bar_no_animation_block(^{
            obj.alpha = self.TT_barBackgroundAlpha;
            obj.frame = TT_extension_navigation_bar_custom_background_view_frame(self, YES);
        });
        [self insertSubview:obj atIndex:0];
    });
}

#pragma mark - reset method
NS_INLINE void TT_extension_navigation_bar_reset_bar(id self, SEL selKey) {
    TT_extension_nav_bar_exist_property_operation(self, selKey, ^(UIView *obj) {
        if (!obj) return ;
        [obj removeFromSuperview];
    });
    objc_setAssociatedObject(self, selKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void)TT_resettransitionDisAppearBar {
    SEL selKey = @selector(TT_transitionDisAppearBar:);
    TT_extension_navigation_bar_reset_bar(self, selKey);
}

- (void)TT_resettransitionAppearBar {
    SEL selKey = @selector(TT_transitionAppearBar:);
    TT_extension_navigation_bar_reset_bar(self, selKey);
}

- (void)TT_resetCustomBackgroundDisAppearView {
    SEL selKey = @selector(TT_customBackgroundDisAppearView);
    TT_extension_navigation_bar_reset_bar(self, selKey);
}

- (void)TT_resetcCustomBackgroundAppearView {
    SEL selKey = @selector(TT_customBackgroundAppearView);
    TT_extension_navigation_bar_reset_bar(self, selKey);
}

- (void)TT_showCustomBackgroundDidAppearView {
    [self TT_resetCustomBackgroundDisAppearView];
    TT_extension_nav_bar_exist_property_operation(self, @selector(TT_customBackgroundAppearView), ^(UIView *obj) {
        if (!obj) return ;
        if (obj.superview && ![obj.superview isEqual:self]) [obj removeFromSuperview];
        if (!self.window) return;
        if ([self.subviews.firstObject isEqual:self]) {
            obj.frame = TT_extension_navigation_bar_custom_background_view_frame(self, YES);
            return;
        }
        [self setNeedsLayout];
    });
}

#pragma mark - property method
- (void)setTT_hiddenBarBackground:(BOOL)TT_hiddenBarBackground {
    if (TT_hiddenBarBackground == self.isTT_hiddenBarBackground) {
        return;
    }
    objc_setAssociatedObject(self, @selector(isTT_hiddenBarBackground), @(TT_hiddenBarBackground), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (self.window) [self setNeedsLayout];
}

- (BOOL)isTT_hiddenBarBackground {
    NSNumber *value = objc_getAssociatedObject(self, _cmd);
    return value.boolValue;
}

- (void)setTT_barBackgroundAlpha:(CGFloat)TT_barBackgroundAlpha {
    if (self.TT_barBackgroundAlpha == TT_barBackgroundAlpha) {
        return;
    }
    objc_setAssociatedObject(self, @selector(TT_barBackgroundAlpha), @(TT_barBackgroundAlpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (self.window) [self setNeedsLayout];
}

- (CGFloat)TT_barBackgroundAlpha {
    NSNumber *value = objc_getAssociatedObject(self, _cmd);
    if (!value) {
        return 1;
    }
    return value.floatValue;
}

- (UIView *)TT_transitionDisAppearBar:(UIViewController *)vc {
    UIView *background = objc_getAssociatedObject(self, _cmd);
    if (background) return background;
    
//    background = [vc.view.window
//                  resizableSnapshotViewFromRect:
//                  TT_extension_navigation_bar_custom_background_view_frame(self, NO)
//                  afterScreenUpdates:NO
//                  withCapInsets:UIEdgeInsetsZero];
    background = [TT_extension_vc_nav_bar_get_background_view(self) snapshotViewAfterScreenUpdates:NO];

    objc_setAssociatedObject(self, _cmd, background, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return background;
}

- (UIView *)TT_transitionAppearBar:(UIViewController *)vc {
    UIView *background = objc_getAssociatedObject(self, _cmd);
    if (background) return background;
    
//    background = [vc.view
//                  resizableSnapshotViewFromRect:
//                  TT_extension_navigation_bar_custom_background_view_frame(self, NO)
//                  afterScreenUpdates:YES
//                  withCapInsets:UIEdgeInsetsZero];
    background = TT_extension_vc_nav_bar_get_background_view(self);
    background.hidden = NO;
//    background = [background snapshotViewAfterScreenUpdates:NO];
    
    [background removeFromSuperview];
    
#error 无法获取
    
    objc_setAssociatedObject(self, _cmd, background, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return background;
}


NS_INLINE CGRect TT_extension_navigation_bar_custom_background_view_frame(UINavigationBar *self, BOOL didShow) {
    CGRect barFrame = self.frame;
    barFrame.size.height += CGRectGetMinY(barFrame);
    barFrame.origin.y     = didShow? - CGRectGetMinY(barFrame): 0;
    return barFrame;
}

- (UIImageView *)TT_customBackgroundDisAppearView {
    UIImageView *view = objc_getAssociatedObject(self, _cmd);
    if (!view) {
        view = [self TT_customNavigationBackgroundDisAppearView];
        view.frame = TT_extension_navigation_bar_custom_background_view_frame(self, NO);
        objc_setAssociatedObject(self, _cmd, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return view;
}

- (UIImageView *)TT_customBackgroundAppearView {
    UIImageView *view = objc_getAssociatedObject(self, _cmd);
    if (!view) {
        view = [self TT_customNavigationBackgroundAppearView];
        view.frame = TT_extension_navigation_bar_custom_background_view_frame(self, NO);
        objc_setAssociatedObject(self, _cmd, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return view;
}

#pragma mark - inner

- (UIImageView *)TT_customNavigationBackgroundDisAppearView {
    UIImageView *view = objc_getAssociatedObject(self, _cmd);
    if (!view) {
        view = [[UIImageView alloc] initWithFrame:self.frame];
        objc_setAssociatedObject(self, _cmd, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return view;
}

- (UIImageView *)TT_customNavigationBackgroundAppearView {
    UIImageView *view = objc_getAssociatedObject(self, _cmd);
    if (!view) {
        view = [[UIImageView alloc] initWithFrame:self.frame];
        objc_setAssociatedObject(self, _cmd, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return view;
}

@end
