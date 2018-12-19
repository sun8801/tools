//
//  UIScrollView+TTVerticalVelocity.h
//  TestRepeatLayerDemo
//
//  Created by sun-zt on 2018/12/18.
//  Copyright © 2018 MOMO. All rights reserved.
// cell 滑动过快是优化，延后加载图片
/**
 @ 用法
 model赋值是，把需要的提取出来
 - (void)showImageTTT {
    if ([self.TT_scrollView TT_abs_verticalVelocity] <= TTVerticalVelocityThresholdNormal) {
        self.velocityValueChanged = NO;
 
        //实际需求代码
        [self.coverImageView setImageWithURL:self.listItem.coverURL];
    }else {
        self.velocityValueChanged = YES;
 
        //实际需求代码
        [self.coverImageView setImageWithURL:nil];
    }
 }
 
 实现代理
 - (void)TT_scrollView:(UIScrollView *)scrollView verticalVelocity:(double)verticalVelocity {
 //    NSLog(@"ve....%f", verticalVelocity);
    if (fabs(verticalVelocity) <= TTVerticalVelocityThresholdNormal && self.velocityValueChanged) {
        self.velocityValueChanged = NO;
 
        //实际需求代码
        [self.coverImageView setImageWithURL:self.listItem.coverURL];
    }
 }
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TTScrollViewVerticalVelocityChangeBlock)(double verticalVelocity);

@protocol TTScrollViewVelocitalDelegate <NSObject>

- (void)TT_scrollView:(UIScrollView *)scrollView verticalVelocity:(double)verticalVelocity;

@end

@interface UIScrollView (TTVerticalVelocity)

/**
 回调精度, 降低回调密度
 [0, .....]
 */
@property (nonatomic, assign) double velocityLeeway;

/**
  滑动速度
 */
@property (nonatomic, assign, readonly) double TT_verticalVelocity;

/**
 滑动速度绝对值
 */
@property (nonatomic, assign, readonly) double TT_abs_verticalVelocity;

@property (nonatomic, copy) TTScrollViewVerticalVelocityChangeBlock velocityBlock;

- (void)addVelocityDelegate:(id <TTScrollViewVelocitalDelegate>)vDelegate;


@end

@interface UIView (TTVerticalVelocity)<TTScrollViewVelocitalDelegate>

@property (nonatomic, assign) BOOL velocityValueChanged;

@property (nonatomic, weak, readonly) UIScrollView *TT_scrollView;

@end

extern double const TTVerticalVelocityThresholdLow;    // 0.5
extern double const TTVerticalVelocityThresholdNormal; // 0.8
extern double const TTVerticalVelocityThresholdFast;   // 1.5

NS_ASSUME_NONNULL_END
