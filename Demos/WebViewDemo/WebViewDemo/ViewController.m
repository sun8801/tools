//
//  ViewController.m
//  WebViewDemo
//
//  Created by sun-zt on 2018/12/17.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+TTStretchBorder.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = UIColor.blueColor;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 100, 50.8, 80)];
    [self.view addSubview:imageView];
    
    UIImage *image = [UIImage imageNamed:@"combinedShapeCopy"];
    
    image = [image stretchBothSidesImageDesSize:imageView.bounds.size stretchLeftBorder:10 topBorder:15 bottomBorder:25];

    imageView.image = image;
    
}


@end
