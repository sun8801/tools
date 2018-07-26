//
//  MDGradientImageFactory.m
//  MomoChat
//
//  Created by sun-zt on 2018/6/21.
//  Copyright © 2018年 wemomo.com. All rights reserved.
//

#import "MDGradientImageFactory.h"

#define MDGradientStartPoint CGPointMake(0.3, 0.2)
#define MDGradientEndPoint   CGPointMake(1, 0.8)

@implementation MDGradientImageFactory

+ (UIImage *)gradientImageWithStartColor:(UIColor *)startColor
                                endColor:(UIColor *)endColor
                              startPoint:(CGPoint)startPoint
                                endPoint:(CGPoint)endPoint {
    
    return [self gradientImageWithStartColor:startColor
                                       endColor:endColor
                                     startPoint:startPoint
                                       endPoint:endPoint
                                           size:CGSizeZero];
}

+ (UIImage *)gradientImageWithStartColor:(UIColor *)startColor
                                endColor:(UIColor *)endColor
                              startPoint:(CGPoint)startPoint
                                endPoint:(CGPoint)endPoint
                                    size:(CGSize)size {
    return [self gradientImageWithGradientColors:@[startColor, endColor]
                                      startPoint:startPoint
                                        endPoint:endPoint
                                            size:size];
}

+ (UIImage *)gradientImageWithGradientColors:(NSArray <UIColor *>*)gradientColors
                                  startPoint:(CGPoint)startPoint
                                    endPoint:(CGPoint)endPoint
                                        size:(CGSize)size {
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        size = CGSizeMake(20, 10);
    }
    CAGradientLayer *gradientLayer = [self gradientLayerWithGradientColors:gradientColors
                                                                startPoint:startPoint
                                                                  endPoint:endPoint
                                                                      size:size];
    
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [gradientLayer renderInContext:contextRef];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)gradientImageWithStartColor:(UIColor *)startColor
                                endColor:(UIColor *)endColor
                                    size:(CGSize)size {
    return [self gradientImageWithStartColor:startColor
                                    endColor:endColor
                                  startPoint:MDGradientStartPoint
                                    endPoint:MDGradientEndPoint
                                        size:size];
}



+ (CAGradientLayer *)gradientLayerWithStartColor:(UIColor *)startColor
                                        endColor:(UIColor *)endColor
                                            size:(CGSize)size {
    return [self gradientLayerWithStartColor:startColor
                                    endColor:endColor
                                  startPoint:MDGradientStartPoint
                                    endPoint:MDGradientEndPoint
                                        size:size];
}

+ (CAGradientLayer *)gradientLayerWithStartColor:(UIColor *)startColor
                                        endColor:(UIColor *)endColor
                                      startPoint:(CGPoint)startPoint
                                        endPoint:(CGPoint)endPoint
                                            size:(CGSize)size {
    return [self gradientLayerWithGradientColors:@[startColor, endColor]
                                      startPoint:startPoint
                                        endPoint:endPoint
                                            size:size];
}

+ (CAGradientLayer *)gradientLayerWithGradientColors:(NSArray <UIColor *> *)gradientColors
                                          startPoint:(CGPoint)startPoint
                                            endPoint:(CGPoint)endPoint
                                                size:(CGSize)size {
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:gradientColors.count];
    [gradientColors enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [colors addObject:((__bridge id)obj.CGColor)];
    }];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = colors;
    gradientLayer.startPoint = startPoint;
    gradientLayer.endPoint = endPoint;
    gradientLayer.frame = CGRectMake(0, 0, size.width, size.height);
    return gradientLayer;
}

@end
