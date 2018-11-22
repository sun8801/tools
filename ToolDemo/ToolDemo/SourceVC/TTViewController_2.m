//
//  TTViewController_2.m
//  ToolDemo
//
//  Created by sun-zt on 2018/11/21.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import "TTViewController_2.h"
#import "UIViewController+TTExtensionNavigationBar.h"
#import "UINavigationController+TTParallaxDimming.h"

@interface TTViewController_2 ()

@end

@implementation TTViewController_2

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"VC2";
    
//    self.TT_navigationBarHidden = YES;
    
    self.parallaxColor = UIColor.orangeColor;
    
//    self.TT_navigationBarAlpha = 0.2;
//    self.TT_navigationBarBackgroundColor = UIColor.blueColor;
}


@end
