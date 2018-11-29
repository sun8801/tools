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

NS_ASSUME_NONNULL_END
