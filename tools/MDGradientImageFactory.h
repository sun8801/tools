//
//  MDGradientImageFactory.h
//  MomoChat
//
//  Created by sun-zt on 2018/6/21.
//  Copyright © 2018年 wemomo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDGradientImageFactory : NSObject

//获取渐变image
+ (UIImage *)gradientImageWithStartColor:(UIColor *)startColor
                                endColor:(UIColor *)endColor
                              startPoint:(CGPoint)startPoint
                                endPoint:(CGPoint)endPoint;

+ (UIImage *)gradientImageWithStartColor:(UIColor *)startColor
                                endColor:(UIColor *)endColor
                              startPoint:(CGPoint)startPoint
                                endPoint:(CGPoint)endPoint
                                    size:(CGSize)size;

+ (UIImage *)gradientImageWithStartColor:(UIColor *)startColor
                                endColor:(UIColor *)endColor
                                    size:(CGSize)size;

+ (CAGradientLayer *)gradientLayerWithStartColor:(UIColor *)startColor
                                        endColor:(UIColor *)endColor
                                            size:(CGSize)size;

+ (CAGradientLayer *)gradientLayerWithStartColor:(UIColor *)startColor
                                endColor:(UIColor *)endColor
                              startPoint:(CGPoint)startPoint
                                endPoint:(CGPoint)endPoint
                                    size:(CGSize)size;
@end
