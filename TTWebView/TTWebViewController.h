//
//  TTWebViewController.h
//  WebViewDemo
//
//  Created by sun-zt on 2018/12/17.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTWebView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTWebViewController : UIViewController

@property (nonatomic, strong, readonly) TTWebView *webView;

@end

NS_ASSUME_NONNULL_END
