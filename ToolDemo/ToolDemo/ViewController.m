//
//  ViewController.m
//  ToolDemo
//
//  Created by sun-zt on 2018/10/17.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import "ViewController.h"
#import "TTIAPManager.h"
#import "UINavigationController+TTParallaxDimming.h"

@interface ViewController () <TTIAPTransactionResultDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"%@", [TTIAPManager sharedIAPManager]);
    NSLog(@"%@", [[TTIAPManager alloc] init]);
    NSLog(@"%@", [TTIAPManager new]);
    
    self.navigationController.parallaxColor = UIColor.redColor;
    
    self.view.backgroundColor = UIColor.orangeColor;
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
