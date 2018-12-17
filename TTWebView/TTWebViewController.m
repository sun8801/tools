//
//  TTWebViewController.m
//  WebViewDemo
//
//  Created by sun-zt on 2018/12/17.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import "TTWebViewController.h"

@interface TTWebViewController ()<TTWebViewDelegate>

@property (nonatomic, strong) TTWebView *webView;

@property (nonatomic, strong) NSMutableArray<UIImage *> *historyStack; //历史列表

@end

@implementation TTWebViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDefaultUI];
}

#pragma mark - method
- (void)setupDefaultUI {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.webView];
}


#pragma mark - delegate


#pragma mark - private
- (UIImage *)webViewTakeSnapshot {
    UIGraphicsBeginImageContextWithOptions(self.webView.bounds.size, NO, [UIScreen mainScreen].scale);
    [self.webView drawViewHierarchyInRect:self.webView.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - property
- (TTWebView *)webView {
    if (!_webView) {
        TTWebViewConfiguration *configuration = [TTWebViewConfiguration defaultWebViewConfiguration];
        _webView = [[TTWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
        _webView.delegate = self;
    }
    return _webView;
}

@end
