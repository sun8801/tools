//
//  TTViewController_4.m
//  ToolDemo
//
//  Created by sun-zt on 2018/11/21.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import "TTViewController_4.h"
#import "UIViewController+TTExtensionNavigationBar.h"

@interface TTViewController_4 ()

@end

@implementation TTViewController_4

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"VC4";
}
- (IBAction)dis:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}



- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
