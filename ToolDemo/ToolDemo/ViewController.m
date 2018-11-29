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

@interface ViewController () <TTIAPTransactionResultDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
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

@end
