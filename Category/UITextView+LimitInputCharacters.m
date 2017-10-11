//
//  UITextView+LimitInputCharacters.m
//
//  Created by iminer_szt on 16/7/12.
//  Copyright © 2016年 iminer_szt. All rights reserved.
//

#import "UITextView+LimitInputCharacters.h"

#import "NSString+YYAdd.h"
#import "UIColor+YYAdd.h"

#import <objc/runtime.h>

static const char kMaxInputLength;
static const char kMaxInputLines;
static const char kPlaceholder;
static const char kHasPlaceholder;

@interface UITextView ()<UITextViewDelegate>


@end
@implementation UITextView (LimitInputCharacters)

- (void)limitInputCharacters:(NSInteger)maxLength{
    objc_setAssociatedObject(self, &kMaxInputLength, @(maxLength), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.delegate = self;
}

- (void)setMaxLines:(NSUInteger)maxLines {
    objc_setAssociatedObject(self, &kMaxInputLines, @(maxLines), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger)maxLines {
    return [objc_getAssociatedObject(self, &kMaxInputLines) integerValue];
}

- (void)setPlaceholder:(NSString *)placeholder{
    if (!placeholder || ![placeholder isNotBlank]) {
        return;
    }
    objc_setAssociatedObject(self, &kPlaceholder, placeholder, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &kHasPlaceholder, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.delegate = self;
}

- (id<AVMTextViewLimitInputDelegate>)avm_delegate {
    return objc_getAssociatedObject(self, @selector(setAvm_delegate:));
}

- (void)setAvm_delegate:(id<AVMTextViewLimitInputDelegate>)avm_delegate {
    objc_setAssociatedObject(self, _cmd, avm_delegate, OBJC_ASSOCIATION_ASSIGN);
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (self.avm_delegate && [self.avm_delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
        return [self.avm_delegate textView:textView shouldChangeTextInRange:range replacementText:text];
    }
    
    //行数
    NSInteger maxLines = self.maxLines;
    if (maxLines != 0) {
        if ([text isEqualToString:@"\n"]) {
            NSArray *textArray = [textView.text componentsSeparatedByString:@"\n"];
            if (textArray.count >= maxLines) {
                [textView resignFirstResponder];
                return NO;
            }
        }
    }
    
    NSInteger maxLength = [objc_getAssociatedObject(self, &kMaxInputLength) integerValue];
    if (maxLength == 0) {
        maxLength = 1000;
    }
    NSString *new = [textView.text stringByReplacingCharactersInRange:range withString:text];
    NSInteger res = maxLength-[new length];
    if(res >= 0){
        return YES;
    }
    else{
        NSRange rg = {0,[text length]+res};
        if (rg.length>0) {
            if (text.length < rg.length) {
                rg.length = text.length;
            }
            NSString *s = [text substringWithRange:rg];
            [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
        }
        return NO;
    }
}
- (void)textViewDidChange:(UITextView *)textView
{
    if (self.avm_delegate && [self.avm_delegate respondsToSelector:@selector(textViewDidChange:)]) {
        [self.avm_delegate textViewDidChange:textView];
    }
    NSInteger maxLength = [objc_getAssociatedObject(self, &kMaxInputLength) integerValue];
    if (maxLength == 0) {
        maxLength = 1000;
    }
    if (textView.text.length > maxLength)
    {
        textView.text = [textView.text substringToIndex:maxLength];
    }
    
    if (textView.text.length == 0) {
        objc_setAssociatedObject(self, &kHasPlaceholder, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }else{
        objc_setAssociatedObject(self, &kHasPlaceholder, @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [self setNeedsDisplay];
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if (self.avm_delegate && [self.avm_delegate respondsToSelector:_cmd]) {
        [self.avm_delegate textViewDidBeginEditing:textView];
    }
    [self setNeedsDisplay];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    if (self.avm_delegate && [self.avm_delegate respondsToSelector:_cmd]) {
        [self.avm_delegate textViewDidEndEditing:textView];
    }
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    NSString *placeholder = objc_getAssociatedObject(self, &kPlaceholder);
    BOOL hasPlaceholder = [objc_getAssociatedObject(self, &kHasPlaceholder) boolValue];
    if (!hasPlaceholder) {
        return;
    }
    if (!placeholder || [self.text isNotBlank]) {
        return;
    }
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.lineSpacing = 4;
    style.lineBreakMode = NSLineBreakByCharWrapping;
    CGFloat x = 5 + self.contentInset.left + self.textContainerInset.left;
    [placeholder drawInRect:CGRectMake(x, self.textContainerInset.top+self.contentInset.top, rect.size.width - x * 2 , rect.size.height) withAttributes:@{NSFontAttributeName:self.font,NSForegroundColorAttributeName:kTextColor_9b9b9b,NSParagraphStyleAttributeName:style}];
}

@end
