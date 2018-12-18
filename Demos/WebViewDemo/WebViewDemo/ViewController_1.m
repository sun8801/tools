//
//  ViewController_1.m
//  WebViewDemo
//
//  Created by sun-zt on 2018/12/17.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import "ViewController_1.h"

@interface ViewController_1 ()

@end

@implementation ViewController_1

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.webView loadURLString:@"https://www.baidu.com"];
    
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@">>>dealloc>>>>>:%@",NSStringFromClass(self.class));
#endif
}



@end
