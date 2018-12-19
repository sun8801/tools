//
//  UIScrollView+TTVerticalVelocity.m
//  TestRepeatLayerDemo
//
//  Created by sun-zt on 2018/12/18.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import "UIScrollView+TTVerticalVelocity.h"
@import ObjectiveC;

NS_INLINE void TT_extension_scrollview_swizzleInstanceSelector(Class class, SEL originalSelector, SEL newSelector) {
    Method origMethod     = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, newSelector);
    
    BOOL isAdd = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if(isAdd) {
        class_replaceMethod(class, newSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, swizzledMethod);
    }
}

@interface UIScrollView (TTVerticalVelocity_Inner)

@property (nonatomic, strong) NSHashTable<id <TTScrollViewVelocitalDelegate>> *weakHashTable;
@property (nonatomic, assign) double lastVerticalVelocity;

@end

NS_INLINE BOOL TT_extension_scrollview_vertical_velocity_change_continue(UIScrollView *self, double velocity) {
    if (self.velocityLeeway <= 0) return YES;
    velocity = fabs(velocity);
    
    if (velocity == 0) return YES;
    if (fabs(self.lastVerticalVelocity - velocity) < self.velocityLeeway) return NO;
    self.lastVerticalVelocity = velocity;
    return YES;
}

@implementation UIScrollView (TTVerticalVelocity)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TT_extension_scrollview_swizzleInstanceSelector(self, @selector(setContentOffset:), @selector(TT_setContentOffset:));
    });
}

- (void)TT_setContentOffset:(CGPoint)contentOffset {
    [self TT_setContentOffset:contentOffset];
    
    if (self.velocityBlock) {
        double velocity = [self TT_verticalVelocity];
        if (!TT_extension_scrollview_vertical_velocity_change_continue(self, velocity)) return;
        self.velocityBlock(velocity);
    }
    if (self.weakHashTable) {
        double velocity = [self TT_verticalVelocity];
        if (!TT_extension_scrollview_vertical_velocity_change_continue(self, velocity)) return;
        for (id<TTScrollViewVelocitalDelegate> obj in self.weakHashTable) {
            [obj TT_scrollView:self verticalVelocity:velocity];
        }
    }
}

- (void)addVelocityDelegate:(id<TTScrollViewVelocitalDelegate>)vDelegate {
    if (vDelegate) {
       NSHashTable *hashTable = [self weakHashTable];
        if (!hashTable) {
            hashTable = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPointerPersonality capacity:0];
            [self setWeakHashTable:hashTable];
        }
        if (![hashTable containsObject:vDelegate]) {
            [hashTable addObject:vDelegate];
        }
    }
}

#pragma mark - property

- (double)TT_verticalVelocity {
    return [[self valueForKey:@"_verticalVelocity"] doubleValue];
}

- (double)TT_abs_verticalVelocity {
    return fabs([self TT_verticalVelocity]);
}

- (void)setVelocityLeeway:(double)velocityLeeway {
    objc_setAssociatedObject(self, @selector(velocityLeeway), @(velocityLeeway), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (double)velocityLeeway {
    NSNumber *value = objc_getAssociatedObject(self, _cmd);
    return value.doubleValue;
}

- (void)setVelocityBlock:(TTScrollViewVerticalVelocityChangeBlock)velocityBlock {
    objc_setAssociatedObject(self, @selector(velocityBlock), velocityBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (TTScrollViewVerticalVelocityChangeBlock)velocityBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (NSHashTable<id<TTScrollViewVelocitalDelegate>> *)weakHashTable {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setWeakHashTable:(NSHashTable<id<TTScrollViewVelocitalDelegate>> *)weakHashTable {
    objc_setAssociatedObject(self, @selector(weakHashTable), weakHashTable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setLastVerticalVelocity:(double)lastVerticalVelocity {
    objc_setAssociatedObject(self, @selector(lastVerticalVelocity), @(lastVerticalVelocity), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (double)lastVerticalVelocity {
    NSNumber *value = objc_getAssociatedObject(self, _cmd);
    return value.doubleValue;
}

@end

static char TTUsedScrollView;
@implementation UIView (TTVerticalVelocity)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TT_extension_scrollview_swizzleInstanceSelector(self, @selector(layoutSubviews), @selector(TT_layoutSubviews));
    });
}

- (void)TT_layoutSubviews {
    [self TT_layoutSubviews];
    NSNumber *value = objc_getAssociatedObject(self, &TTUsedScrollView);
    if (!value.boolValue) return;
    [self TT_scrollView];
}

- (void)setVelocityValueChanged:(BOOL)velocityValueChanged {
    objc_setAssociatedObject(self, @selector(velocityValueChanged), @(velocityValueChanged), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)velocityValueChanged {
    NSNumber *value = objc_getAssociatedObject(self, _cmd);
    if (value) return value.boolValue;
    return YES;
}

- (UIScrollView *)TT_scrollView {
    UIScrollView *obj = objc_getAssociatedObject(self, _cmd);
    if (obj) return obj;
    obj = (UIScrollView *)self.superview;
    while (obj && ![obj isKindOfClass:UIScrollView.class]) {
        obj = (UIScrollView *)obj.superview;
    }
    if (obj) {
        [obj addVelocityDelegate:self];
        [obj setVelocityLeeway:0.1];
        objc_setAssociatedObject(self, _cmd, obj, OBJC_ASSOCIATION_ASSIGN);
    }
    objc_setAssociatedObject(self, &TTUsedScrollView, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return obj;
}

@end

double const TTVerticalVelocityThresholdLow = 0.5;    // 0.5
double const TTVerticalVelocityThresholdNormal = 0.8; // 0.8
double const TTVerticalVelocityThresholdFast = 1.5;   // 1.5
