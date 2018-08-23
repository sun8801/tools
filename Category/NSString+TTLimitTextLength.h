//
//  NSString+LimitTextLength.h
//  TestRepeatLayerDemo
//
//  Created by sun-zt on 2018/8/23.
//  Copyright © 2018年 MOMO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TTLimitTextLength)

//安全的截取字符串长度
- (NSString *)TT_limitStringWithMaxLength:(NSUInteger)maxLength;

@end
