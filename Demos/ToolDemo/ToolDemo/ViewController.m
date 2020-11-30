//
//  ViewController.m
//  ToolDemo
//
//  Created by sun-zt on 2018/10/17.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import "ViewController.h"
#import "TTIAPManager.h"
#import "UIViewController+TTParallaxDimming.h"
#import "UIViewController+TTExtensionNavigationBar.h"
#import "NSObject+TTSwizzle.h"
#import "AllClasses.h"

@interface ViewController () <TTIAPTransactionResultDelegate>

@end

@implementation ViewController

static _IMP _resolvedColorWithTraitCollection_IMP;

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        _resolvedColorWithTraitCollection_IMP = [self tt_replaceOriginalClass:NSClassFromString(@"UIDynamicSystemColor") withAltClass:ViewController.class method:NSSelectorFromString(@"_resolvedColorWithTraitCollection:")];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"%@", UIColor.systemRedColor);
    
//    self.navigationController.TT_parallaxColor = UIColor.redColor;
    
    self.view.backgroundColor = UIColor.whiteColor;
    self.TT_parallaxColor = UIColor.yellowColor;
    
//    self.TT_navigationBarBackgroundColor = UIColor.blueColor;
//    self.TT_navigationBarBackgroundAlpha = 0.2;
}

- (void)buy {
    [TTIAPManager sharedIAPManager].delegate = self;
    //通过api 从服务获取购买商品的ID和订单ID
    [[TTIAPManager sharedIAPManager] buyGoodsWithProductId:@"商品ID" orderId:@"订单ID"];
}

- (void)IAPTansactionResultCode:(TTIAPCodeType)codeType error:(NSString *)errorString {
    //获得当前交易回调
}

#pragma mark - exchange
- (id)_resolvedColorWithTraitCollection:(id)p {
//    NSLog(@"走到了 UIDynamicSystemColor _resolvedColorWithTraitCollection：---%@", p);
    id ret = _resolvedColorWithTraitCollection_IMP(self, _cmd, p);
    return ret;
}

@end
