//
//  TTWebViewController.m
//  WebViewDemo
//
//  Created by sun-zt on 2018/12/17.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import "TTWebViewController.h"

@interface TTWebViewController ()

@property (nonatomic, strong) TTWebView *webView;

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
- (BOOL)TT_webView:(id<TTWebViewProtocol>)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(TTWebViewNavigationType)navigationType {
    BOOL shouldStartLoad = YES;
    
    
    return shouldStartLoad;
}

- (void)TT_webViewDidStartLoad:(id<TTWebViewProtocol>)webView {
    
}

- (void)TT_webViewDidFinishLoad:(id<TTWebViewProtocol>)webView {
    
}

- (void)TT_webView:(id<TTWebViewProtocol>)webView didFailLoadWithError:(NSError *)error {
    
}


#pragma mark - go or forwoard
- (BOOL)canGoBack {
    return self.webView.canGoBack;
}

- (BOOL)canForward {
    return self.webView.canGoForward;
}

#pragma mark - private

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
