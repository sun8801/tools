//
//  UIImage+TTStretchBorder.m
//  ToolDemo
//
//  Created by sun-zt on 2018/11/19.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import "UIImage+TTStretchBorder.h"

/**
 拉伸两端，保留中间
 
 @param image 需要拉伸的图片
 @param desSize 目标大小
 @param stretchLeftBorder 拉伸图片距离左边的距离
 @return 拉伸收缩后的图片
 */
static UIImage *tt_stretch_both_sides_image(UIImage *image, CGSize desSize, CGFloat stretchLeftBorder) {
    if (!image) {
        return nil;
    }
    if (desSize.width == 0) {
        return nil;
    }
    CGSize imageSize = image.size;
    if (imageSize.width == desSize.width) {
        return image;
    }
    
    //各需要拉伸的宽度
    CGFloat needWidth = 0;
    needWidth = (desSize.width - imageSize.width) /2.0;
    
    //先拉取左边
    CGFloat left = stretchLeftBorder;
    CGFloat right = imageSize.width - fabs(needWidth) -left;
    
    //画图， 生成拉伸的左边后的图片
    CGFloat tempStrecthWith = 0;
    tempStrecthWith = imageSize.width + needWidth;
    
    //生成拉伸后的图片-》左
    CGFloat height = imageSize.height;
    UIImage *strectedImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, left, 0, right)];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(tempStrecthWith, height), NO, 0);
    [strectedImage drawInRect:CGRectMake(0, 0, tempStrecthWith, height)];
    strectedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //拉伸右边
    right = stretchLeftBorder;
    left  = strectedImage.size.width - right - fabs(needWidth);
    
    //生成拉伸后的图片-》右
    tempStrecthWith = desSize.width;
    strectedImage = [strectedImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, left, 0, right)];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(tempStrecthWith, height), NO, 0);
    [strectedImage drawInRect:CGRectMake(0, 0, tempStrecthWith, height)];
    strectedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return strectedImage;
}

@implementation UIImage (TTStretchBorder)

- (UIImage *)stretchBothSidesImageDesSize:(CGSize)desSize
                        stretchLeftBorder:(CGFloat)stretchLeftBorder {
    return tt_stretch_both_sides_image(self, desSize, stretchLeftBorder);
}

@end
