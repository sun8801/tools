//
//  UIImage+TTStretchBorder.h
//  ToolDemo
//
//  Created by sun-zt on 2018/11/19.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (TTStretchBorder)


/**
 拉伸两端，保留中间

 @param desSize 目标大小
 @param stretchLeftBorder 拉伸图片距离左边的距离
 @return <#return value description#>
 */
- (UIImage *)stretchBothSidesImageDesSize:(CGSize)desSize
                        stretchLeftBorder:(CGFloat) stretchLeftBorder;

@end

NS_ASSUME_NONNULL_END
