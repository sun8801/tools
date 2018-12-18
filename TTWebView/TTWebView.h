//
//  TTWebView.h
//  TT
//
//  Created by sunzongtang on 2017/9/1.
//  Copyright © 2017年. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,TTWebViewNavigationType) {
    TTWebViewNavigationLinkClicked,
    TTWebViewNavigationFormSubmitted,
    TTWebViewNavigationBackForward,
    TTWebViewNavigationReload,
    TTWebViewNavigationResubmitted,
    TTWebViewNavigationOther = -1
};

@protocol TTWebViewProtocol <NSObject>

@optional
@property (nonatomic, readonly, strong) UIScrollView *scrollView;
@property (nonatomic, readonly, getter=canGoBack) BOOL canGoBack;
@property (nonatomic, readonly, getter=canGoForward) BOOL canGoForward;
@property (nonatomic, readonly, getter=isLoading) BOOL loading;
// use KVO
@property (nonatomic, readonly, copy) NSString *title;
// use KVO
@property (nonatomic, readonly) double estimatedProgress;
// use KVO
@property (nonatomic, readonly) float pageHeight;
@property (nonatomic, readonly, copy) NSArray * images;  // webview's images when captureImage is NO images = nil
@property (nonatomic, readonly, strong) NSURL *URL;

- (void)loadRequest:(NSURLRequest *)request;
- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;
- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType characterEncodingName:(NSString *)characterEncodingName baseURL:(NSURL *)baseURL;
- (void)loadURLString:(NSString *)urlString;
- (void)loadURL:(NSURL *)url;

- (void)reload;
- (void)stopLoading;
- (void)goBack;
- (void)goForward;
- (void)TT_evaluateJavaScript:(NSString*)javaScriptString completionHandler:(void (^)(id result, NSError* error))completionHandler;

@end

@protocol TTWebViewDelegate <NSObject>

@optional
- (BOOL)TT_webView:(id<TTWebViewProtocol>)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(TTWebViewNavigationType)navigationType;
- (void)TT_webViewDidStartLoad:(id<TTWebViewProtocol>)webView;
- (void)TT_webViewDidFinishLoad:(id<TTWebViewProtocol>)webView;
- (void)TT_webView:(id<TTWebViewProtocol>)webView didFailLoadWithError:(NSError *)error;

@end

@interface TTWebViewConfiguration : NSObject

+ (instancetype)defaultWebViewConfiguration;

@property (nonatomic) BOOL allowsInlineMediaPlayback; // iPhone Safari defaults to NO. iPad Safari defaults to YES
@property (nonatomic) BOOL mediaPlaybackRequiresUserAction; // iPhone and iPad Safari both default to YES
@property (nonatomic) BOOL mediaPlaybackAllowsAirPlay; // iPhone and iPad Safari both default to YES
@property (nonatomic) BOOL suppressesIncrementalRendering; // iPhone and iPad Safari both default to NO
@property (nonatomic) BOOL scalesPageToFit;     //default YES
@property (nonatomic) BOOL loadingHUD;          //default NO ,if YES webview will add HUD when loading
@property (nonatomic) BOOL captureImage;        //default NO ,if YES webview will capture all image in content;
@property (nonatomic) BOOL showSupportHost;     //default YES, show 网页来自...域名

@end

@interface TTWebView : UIView <TTWebViewProtocol>

@property (nonatomic, strong, readonly) UIView<TTWebViewProtocol> *webView;

- (instancetype)initWithFrame:(CGRect)frame configuration:(TTWebViewConfiguration *)configuration NS_DESIGNATED_INITIALIZER;

+ (instancetype)webViewWithFrame:(CGRect)frame configuration:(TTWebViewConfiguration *)configuration;

@property (nonatomic,weak) id<TTWebViewDelegate> delegate;

//销毁
- (void)destory;

//--不可使用--//
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end
