//
//  NSString+LimitTextLength.m
//  TestRepeatLayerDemo
//
//  Created by sun-zt on 2018/8/23.
//  Copyright © 2018年 MOMO. All rights reserved.
//

#import "NSString+TTLimitTextLength.h"

@implementation NSString (TTLimitTextLength)

- (NSString *)TT_limitStringWithMaxLength:(NSUInteger)maxLength {
    
    if (self.length <= maxLength) {
        return self;
    }
    
    __block NSUInteger index = 0; //每个字符所在索引 下一个字符开始位置
    __block NSUInteger lengthCount = 0; //字符串长度
    
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        lengthCount ++;
        if (lengthCount > maxLength) {
            *stop = YES;
        }else {
            index += substringRange.length;
        }
    }];
    
    return [self substringToIndex:index];
}

@end
