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
@property (nonatomic, strong) UIColor *TT_navigationBarBackgroundImage;

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
 获得系统的背景view
 */
@property (nonatomic, strong, nullable) UIView *TT_systemBackgroundView;

/**
 设置自定义背景图
 */
@property (nonatomic, strong, nullable) UIView *TT_customBackgroundView;

@end

NS_ASSUME_NONNULL_END
