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
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 100, 320, 24)];
    [self.view addSubview:imageView];
    
    UIImage *image = [UIImage imageNamed:@"md_vorder_room_activity_celebration_logo_border_1_yes"];
    
    image = [image stretchBothSidesImageDesSize:imageView.bounds.size stretchLeftBorder:10 topBorder:15 bottomBorder:25];

    imageView.image = image;
    
//    self.view.maskView = imageView;
    
}


@end
