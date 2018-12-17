//
//  TTViewController_2.m
//  ToolDemo
//
//  Created by sun-zt on 2018/11/21.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import "TTViewController_2.h"
#import "UIViewController+TTExtensionNavigationBar.h"
#import "UIViewController+TTParallaxDimming.h"

@interface TTViewController_2 ()

@end

@implementation TTViewController_2

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"VC2";
    
//    self.TT_navigationBarHidden = YES;
    
    self.TT_parallaxColor = UIColor.orangeColor;
    
//    self.TT_navigationBarAlpha = 0.2;
    self.TT_navigationBarBackgroundColor = UIColor.redColor;
//    self.TT_navigationBarBackgroundImage = [UIImage imageNamed:@"nav_bar1"];
    
//    self.TT_navigationBarHidden = YES;
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.TT_navigationBarBackgroundImage = [UIImage imageNamed:@"nav_bar1"];
//    });
}

- (IBAction)poped:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//- (BOOL)prefersStatusBarHidden {
//    return YES;
//}

@end
