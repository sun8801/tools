//
//  UINavigationController+TTParallaxDimming.h
//  TestRepeatLayerDemo
//
//  Created by sun-zt on 2018/11/12.
//  Copyright © 2018 MOMO. All rights reserved.
//
//设置系统导航手势左滑时，左边边界的阴影颜色
//可以单独设置某个页面或导航控制器主题阴影颜色

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (TTParallaxDimming)

/**
 设置 手势滑动时左侧阴影颜色
 */
@property (nonatomic, strong) UIColor *TT_parallaxColor;

@end

@interface UINavigationController (TTParallaxDimming)

@end

NS_ASSUME_NONNULL_END
