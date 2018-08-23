//
//  UITextView+LimitInputCharacters.h
//
//  Created by iminer_szt on 16/7/12.
//  Copyright © 2016年 iminer_szt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TTTextViewLimitInputDelegate <UITextViewDelegate>

@end

@interface UITextView (TTLimitInputCharacters)
/**
 *  限制输入的最大字数
 */
- (void)TT_limitInputCharacters:(NSInteger)maxLength;

/**
 最大输入行数
 */
@property (nonatomic, assign) NSUInteger TT_maxLines;

- (void)TT_setPlaceholder:(NSString *)placeholder;

@property (nonatomic, weak) id<TTTextViewLimitInputDelegate> TT_delegate;

@end
