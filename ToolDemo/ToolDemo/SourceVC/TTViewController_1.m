//
//  TTViewController_1.m
//  ToolDemo
//
//  Created by sun-zt on 2018/11/21.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import "TTViewController_1.h"
#import "UIViewController+TTExtensionNavigationBar.h"
#import "UIViewController+TTParallaxDimming.h"

@interface TTViewController_1 ()

@end

@implementation TTViewController_1

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"VC1";
    
//    self.TT_navigationBarHidden = YES;
    
//    self.TT_navigationBarBackgroundColor = UIColor.redColor;
//    
//    self.TT_navigationBarBackgroundImage = [UIImage imageNamed:@"nav_bar1"];
    
//    self.TT_navigationBarAlpha = 0.8;
    
//    self.TT_navigationBarHidden = YES;
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.TT_parallaxColor = UIColor.redColor;
    NSLog(@"%@", self.view);
    
}


@end
