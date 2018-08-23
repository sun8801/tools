//
//  UITextField+LimitInputCharacters.h
//
//  Created by iminer_szt on 16/7/12.
//  Copyright © 2016年 iminer_szt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (TTLimitInputCharacters)
/**
 *  限制输入的最大字数
 */
- (void)TT_limitInputCharacters:(NSUInteger)maxLength;
@end
