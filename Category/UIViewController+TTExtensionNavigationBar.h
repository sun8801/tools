//
//  UIViewController+TTExtensionNavigationBar.h
//  TestRepeatLayerDemo
//
//  Created by sun-zt on 2018/11/21.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (TTExtensionNavigationBar)

/**
 设置导航栏背景色
 */
@property (nonatomic, strong) UIColor *TT_navigationBarBackgroundColor;

/**
 设置导航栏背景图
 */
@property (nonatomic, strong) UIImage *TT_navigationBarBackgroundImage;

/**
 设置导航栏背景透明度 [0 - 1]
 */
@property (nonatomic, assign) CGFloat TT_navigationBarBackgroundAlpha;

/**
 设置导航栏透明度 [0 - 1]
 */
@property (nonatomic, assign) CGFloat TT_navigationBarAlpha;

/**
 是否隐藏导航栏
 */
@property (nonatomic, assign) BOOL TT_navigationBarHidden;

@end

@interface UINavigationBar (TTExtensionNavigationBar)

/**
 设置隐藏背景（为了改变背景色/消除模糊层）
 // 消掉navigationBar 的UIVisualEffectView 层
 */
@property (nonatomic, assign, getter=isTT_hiddenBarBackground) BOOL TT_hiddenBarBackground;

/**
 获得运动bar 将要消失
 */
@property (nonatomic, strong, readonly) UINavigationBar *TT_translitionDisAppearBar;

- (void)TT_resetTranslitionDisAppearBar;

/**
 获得运动bar 出现
 */
@property (nonatomic, strong, readonly) UINavigationBar *TT_translitionAppearBar;

- (void)TT_resetTranslitionAppearBar;

//////////////////////////////////////////////////////////////////////////////////////
//-----------------------  自定义backgroundView  ------------------------------------//
/////////////////////////////////////////////////////////////////////////////////////
@property (nonatomic, strong, readonly) UIImageView *TT_customBackgroundDisAppearView;

- (void)TT_resetCustomBackgroundDisAppearView;

@property (nonatomic, strong, readonly) UIImageView *TT_customBackgroundAppearView;

- (void)TT_resetcCustomBackgroundAppearView;

- (void)TT_showCustomBackgroundDidAppearView;

@end

NS_ASSUME_NONNULL_END
