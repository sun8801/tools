//
//  TTWebView.m
//  TT
//
//  Created by sunzongtang on 2017/9/1.
//  Copyright © 2017年 . All rights reserved.
//

#import "TTWebView.h"
#import <WebKit/WebKit.h>
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"

#define isCanWebKit NSClassFromString(@"WKWebView")

#pragma mark - TTWKWebView
@interface TTWKWebView : WKWebView<TTWebViewProtocol>

@end

#pragma mark - TTUIWebView
@interface TTUIWebView : UIWebView<TTWebViewProtocol>

@end

#pragma mark -TTWebJS
@interface TTWebViewJS : NSObject
+(NSString *)scalesPageToFitJS;
+(NSString *)imgsElement;
@end

#pragma mark -TTWebView
@interface TTWebView () <WKNavigationDelegate,UIWebViewDelegate,UIScrollViewDelegate,NJKWebViewProgressDelegate>
@property (nonatomic,strong)  id<TTWebViewProtocol>   webView;
@property (nonatomic, strong) UILabel                 *supportLabel;
@property (nonatomic,strong)  NJKWebViewProgressView  *progressView; //进度条
@property (nonatomic,copy)    NSString                *title;
@property (nonatomic,assign)  double                   estimatedProgress;
@property (nonatomic,assign)  float                    pageHeight;
@property (nonatomic,copy)    NJKWebViewProgress      *webViewProgress;
@property (nonatomic,strong)  UIActivityIndicatorView *indicatorView;
@property (nonatomic,strong)  TTWebViewConfiguration *configuration;
@property (nonatomic,copy)    NSArray                 *images;

@end
@implementation TTWebView

- (void)destory {
    self.delegate = nil;
    
    [_webView loadHTMLString:@"" baseURL:nil];
    [_webView stopLoading];
    
    if (!isCanWebKit) {
        [(TTUIWebView *)_webView setDelegate:nil];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitDiskImageCacheEnabled"];//自己添加的，原文没有提到。
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitOfflineWebApplicationCacheEnabled"];//自己添加的，原文没有提到。
        [[NSUserDefaults standardUserDefaults] synchronize];

        [(TTUIWebView *)_webView setDelegate:nil];
        [(TTUIWebView *)_webView removeFromSuperview];
    }else {
        //移除代理，否则在iOS8 上会报错
//[WKScrollViewDelegateForwarder release]: message sent to deallocated instance 
        [(TTWKWebView *)_webView setUIDelegate:nil];
        [(TTWKWebView *)_webView setNavigationDelegate:nil];
        [[(TTWKWebView *)_webView scrollView] setDelegate:nil];
        [(TTWKWebView *)_webView removeFromSuperview];
    }
    [self removeObserverWebKit];
    
    [_progressView removeFromSuperview];
    _progressView = nil;
    
    _webView = nil;
}


#pragma mark -初始化
+ (instancetype)webViewWithFrame:(CGRect)frame configuration:(TTWebViewConfiguration *)configuration {
    return [[self alloc] initWithFrame:frame configuration:configuration];
}

- (instancetype)initWithFrame:(CGRect)frame configuration:(TTWebViewConfiguration *)configuration {
    self = [super initWithFrame:frame];
    if (self) {
        _configuration = configuration;
        self.supportLabel.hidden = YES;
        self.progressView.hidden = NO;
        if (isCanWebKit) {
            if (configuration) {
                WKWebViewConfiguration *webViewconfiguration = [[WKWebViewConfiguration alloc] init];
                webViewconfiguration.allowsInlineMediaPlayback = configuration.allowsInlineMediaPlayback;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                webViewconfiguration.mediaPlaybackRequiresUserAction = configuration.mediaPlaybackRequiresUserAction;
                webViewconfiguration.mediaPlaybackAllowsAirPlay = configuration.mediaPlaybackAllowsAirPlay;
#pragma clang diagnostic pop
                if (@available(iOS 10.0, *)) {
                    webViewconfiguration.mediaTypesRequiringUserActionForPlayback = configuration.mediaPlaybackRequiresUserAction? WKAudiovisualMediaTypeAll: WKAudiovisualMediaTypeNone;
                }
                if (@available(iOS 9.0, *)) {
                    webViewconfiguration.allowsAirPlayForMediaPlayback = configuration.mediaPlaybackAllowsAirPlay;
                }
                
                webViewconfiguration.suppressesIncrementalRendering = configuration.suppressesIncrementalRendering;
                WKUserContentController *wkUController = [[WKUserContentController alloc] init];
                if (configuration.scalesPageToFit) {
                    NSString *jScript = [TTWebViewJS scalesPageToFitJS];
                    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
                    [wkUController addUserScript:wkUScript];
                }
                if (configuration.captureImage) {
                    NSString *jScript = [TTWebViewJS imgsElement];
                    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
                    [wkUController addUserScript:wkUScript];
                    
                }
                webViewconfiguration.userContentController = wkUController;
                _webView = (id)[[TTWKWebView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) configuration:webViewconfiguration];
            }
            else{
                _webView = (id)[[TTWKWebView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
            }
            [(TTWKWebView *)_webView setNavigationDelegate:self];
            [(TTWKWebView *)_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
            [(TTWKWebView *)_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
            
        }
        else{
            _webView = (id)[[TTUIWebView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
            if (configuration) {
                [(TTUIWebView *)_webView setAllowsInlineMediaPlayback:configuration.allowsInlineMediaPlayback];
                [(TTUIWebView *)_webView setMediaPlaybackRequiresUserAction:configuration.mediaPlaybackRequiresUserAction];
                [(TTUIWebView *)_webView setMediaPlaybackAllowsAirPlay:configuration.mediaPlaybackAllowsAirPlay];
                [(TTUIWebView *)_webView setSuppressesIncrementalRendering:configuration.suppressesIncrementalRendering];
                [(TTUIWebView *)_webView setScalesPageToFit:configuration.scalesPageToFit];
            }
            _webViewProgress = [[NJKWebViewProgress alloc] init];
            [(TTUIWebView *)_webView setDelegate:_webViewProgress];
            _webViewProgress.webViewProxyDelegate = self;
            _webViewProgress.progressDelegate = self;
            
        }
        if (configuration.loadingHUD) {
            [(UIView *)_webView addSubview:self.indicatorView];
        }
        _webView.scrollView.delegate = self;
        _webView.scrollView.backgroundColor = [UIColor clearColor];
        [(UIView *)_webView setOpaque:NO];
        [(UIView *)_webView setBackgroundColor:[UIColor clearColor]];
        [(UIView *)_webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [self addSubview:(UIView *)_webView];
        
        [self bringSubviewToFront:self.progressView];
    }
    return self;
}

#pragma mark - public method
-(UIScrollView *)scrollView {
    return _webView.scrollView;
}

- (void)loadRequest:(NSURLRequest *)request {
    [_webView loadRequest:request];
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
    [_webView loadHTMLString:string baseURL:baseURL];
}

- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType characterEncodingName:(NSString *)characterEncodingName baseURL:(NSURL *)baseURL {
    [_webView loadData:data MIMEType:MIMEType characterEncodingName:characterEncodingName baseURL:baseURL];
}

- (void)loadURLString:(NSString *)urlString {
    [_webView loadURLString:urlString];
}

- (void)loadURL:(NSURL *)url {
    [_webView loadURL:url];
}

- (void)reload {
    [_webView reload];
}
- (void)stopLoading
{
    [_webView stopLoading];
}

- (void)goBack {
    [_webView goBack];
}

- (void)goForward {
    [_webView goForward];
}

-(BOOL)canGoBack {
    return _webView.canGoBack;
}

-(BOOL)canGoForward {
    return _webView.canGoForward;
}

-(BOOL)isLoading {
    return _webView.isLoading;
}

- (NSURL *)URL {
    return _webView.URL;
}

- (void)TT_evaluateJavaScript:(NSString*)javaScriptString completionHandler:(void (^)(id, NSError*))completionHandler
{
    [_webView TT_evaluateJavaScript:javaScriptString completionHandler:completionHandler];
}

- (void)setEstimatedProgress:(double)estimatedProgress {
    _estimatedProgress = estimatedProgress;
    
    if (!_progressView) {
        return;
    }
    if (estimatedProgress < 1.0) {
        [self.progressView setProgress:estimatedProgress animated:YES];
    }else{
        [self.progressView setProgress:1.0 animated:NO];
    }
}

#pragma mark - NJKWebViewProgressDelegate
- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress {
    self.estimatedProgress = progress;
}

#pragma mark - KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"title"]) {
        self.title = change[NSKeyValueChangeNewKey];
    }
    else if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.estimatedProgress = [change[NSKeyValueChangeNewKey] doubleValue];
    }
}

#pragma mark - WKWebViewNavigation Delegate
- (void)webView:(WKWebView*)webView decidePolicyForNavigationAction:(WKNavigationAction*)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    [self bringSubviewToFront:_progressView];
    BOOL load = YES;
    if ([navigationAction.request isKindOfClass:[NSMutableURLRequest class]]) {
        [(NSMutableURLRequest *)navigationAction.request setTimeoutInterval:30];
    }
    if ([self.delegate respondsToSelector:@selector(TT_webView:shouldStartLoadWithRequest:navigationType:)]) {
        load = [self.delegate TT_webView:(TTWebView<TTWebViewProtocol>*)self shouldStartLoadWithRequest:navigationAction.request navigationType:[self navigationTypeConvert:navigationAction.navigationType]];
    }
    if (load) {
        decisionHandler(WKNavigationActionPolicyAllow);
    }else{
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    [_indicatorView startAnimating];
    if ([self.delegate respondsToSelector:@selector(TT_webViewDidStartLoad:)]) {
        [self.delegate TT_webViewDidStartLoad:(TTWebView<TTWebViewProtocol>*)self];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [_indicatorView stopAnimating];
    self.title = webView.title;
    self.supportLabel.text = [NSString stringWithFormat:@"此网页由 %@ 提供",webView.URL.host];
    
    if ([self.delegate respondsToSelector:@selector(TT_webViewDidFinishLoad:)]) {
        [self.delegate TT_webViewDidFinishLoad:(TTWebView<TTWebViewProtocol>*)self];
    }
    
    [self TT_evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(id heitht, NSError *error) {
        if (!error) {
            self.pageHeight = [heitht floatValue];
        }
    }];
    if (_configuration.captureImage) {
        [self TT_evaluateJavaScript:@"imgsElement()" completionHandler:^(NSString * imgs, NSError *error) {
            if (!error && imgs.length) {
                self.images = [imgs componentsSeparatedByString:@","];
            }
        }];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [_indicatorView stopAnimating];
    if ([self.delegate respondsToSelector:@selector(TT_webView:didFailLoadWithError:)]) {
        [self.delegate TT_webView:(TTWebView<TTWebViewProtocol>*)self didFailLoadWithError:error];
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [_indicatorView stopAnimating];
    if ([self.delegate respondsToSelector:@selector(TT_webView:didFailLoadWithError:)]) {
        [self.delegate TT_webView:(TTWebView<TTWebViewProtocol>*)self didFailLoadWithError:error];
    }
}

#pragma mark - UIWebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    [self bringSubviewToFront:_progressView];
    
    if ([request isKindOfClass:[NSMutableURLRequest class]]) {
        [(NSMutableURLRequest *)request setTimeoutInterval:30];
    }
    
    BOOL isLoad = YES;
    if ([self.delegate respondsToSelector:@selector(TT_webView:shouldStartLoadWithRequest:navigationType:)]) {
        isLoad = [self.delegate TT_webView:(TTWebView<TTWebViewProtocol>*)self shouldStartLoadWithRequest:request navigationType:[self navigationTypeConvert:navigationType]];
    }
    return isLoad;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [_indicatorView startAnimating];
    if ([self.delegate respondsToSelector:@selector(TT_webViewDidStartLoad:)]) {
        [self.delegate TT_webViewDidStartLoad:(TTWebView<TTWebViewProtocol>*)self];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_indicatorView stopAnimating];
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (self.configuration.showSupportHost) {
        self.supportLabel.text = [NSString stringWithFormat:@"此网页由 %@ 提供",webView.request.URL.host];
    }
    
    if ([self.delegate respondsToSelector:@selector(TT_webViewDidFinishLoad:)]) {
        [self.delegate TT_webViewDidFinishLoad:(TTWebView<TTWebViewProtocol> *)self];
    }
    [self TT_evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(id heitht, NSError *error) {
        if (!error) {
            self.pageHeight = [heitht floatValue];
        }
    }];
    if (_configuration.captureImage) {
        [self TT_evaluateJavaScript:[TTWebViewJS imgsElement] completionHandler:nil];
        [self TT_evaluateJavaScript:@"imgsElement()" completionHandler:^(NSString * imgs, NSError *error) {
            if (!error && imgs.length) {
                self.images = [imgs componentsSeparatedByString:@","];
            }
        }];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [_indicatorView stopAnimating];
    if ([self.delegate respondsToSelector:@selector(TT_webView:didFailLoadWithError:)]) {
        [self.delegate TT_webView:(TTWebView<TTWebViewProtocol>*)self didFailLoadWithError:error];
    }
}

#pragma mark - scrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //下拉隐藏网页提供方
    (scrollView.contentOffset.y >= -30) ? (_supportLabel.hidden = YES) : (_supportLabel.hidden = NO);
}

#pragma mark - Init
-(UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.hidesWhenStopped = YES;
    }
    return _indicatorView;
}

- (NJKWebViewProgressView *)progressView {
    if (_progressView == nil) {
        CGFloat progressH = 2.f;
        NJKWebViewProgressView *progressView = [[NJKWebViewProgressView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), progressH)];
        _progressView = progressView;
        
        [self addSubview:_progressView];
    }
    return _progressView;
}

- (UILabel *)supportLabel {
    if (_supportLabel == nil) {
        _supportLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width - 2 * 50, 50)];
        //网页来源提示居中
        CGPoint center = _supportLabel.center;
        center.x = self.frame.size.width / 2;
        _supportLabel.center = center;
        
        _supportLabel.font = [UIFont systemFontOfSize:12];
        _supportLabel.textAlignment = NSTextAlignmentCenter;
        _supportLabel.textColor = [UIColor lightGrayColor];
        _supportLabel.numberOfLines = 0;

        [self sendSubviewToBack:_supportLabel];
        [self addSubview:_supportLabel];
    }
    return _supportLabel;
}

#pragma mark -Privity
-(NSInteger)navigationTypeConvert:(NSInteger)type {
    NSInteger navigationType;
    if (isCanWebKit) {
        switch (type) {
            case WKNavigationTypeLinkActivated:
                navigationType = TTWebViewNavigationLinkClicked;
                break;
            case WKNavigationTypeFormSubmitted:
                navigationType = TTWebViewNavigationFormSubmitted;
                break;
            case WKNavigationTypeBackForward:
                navigationType = TTWebViewNavigationBackForward;
                break;
            case WKNavigationTypeReload:
                navigationType = TTWebViewNavigationReload;
                break;
            case WKNavigationTypeFormResubmitted:
                navigationType = TTWebViewNavigationResubmitted;
                break;
            case WKNavigationTypeOther:
                navigationType = TTWebViewNavigationOther;
                break;
            default:
                navigationType = TTWebViewNavigationOther;
                break;
        }
    }
    else{
        switch (type) {
            case UIWebViewNavigationTypeLinkClicked:
                navigationType = TTWebViewNavigationLinkClicked;
                break;
            case UIWebViewNavigationTypeFormSubmitted:
                navigationType = TTWebViewNavigationFormSubmitted;
                break;
            case UIWebViewNavigationTypeBackForward:
                navigationType = TTWebViewNavigationBackForward;
                break;
            case UIWebViewNavigationTypeReload:
                navigationType = TTWebViewNavigationReload;
                break;
            case UIWebViewNavigationTypeFormResubmitted:
                navigationType = TTWebViewNavigationResubmitted;
                break;
            case UIWebViewNavigationTypeOther:
                navigationType = TTWebViewNavigationOther;
                break;
            default:
                navigationType = TTWebViewNavigationOther;
                break;
        }
    }
    return navigationType;
}

-(void)layoutSubviews {
    _indicatorView.frame = CGRectMake(0, 0, 20, 20);
    _indicatorView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    [super layoutSubviews];
}

-(void)setNeedsLayout {
    [super setNeedsLayout];
    [(UIView *)_webView setNeedsLayout];
}

-(void)dealloc {
#ifdef DEBUG
    NSLog(@">>>dealloc>>>>>:%@",NSStringFromClass(self.class));
#endif
    if (_webView) {
        [self destory];
    }
}

- (void)removeObserverWebKit {
    if (isCanWebKit) {
        [(TTWebView *)_webView removeObserver:self forKeyPath:@"title"];
        [(TTWebView *)_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    }
}

@end


@implementation TTWKWebView

- (void)loadURLString:(NSString *)urlString {
    [self loadURL:[NSURL URLWithString:urlString]];
}

- (void)loadURL:(NSURL *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:(NSURLRequestUseProtocolCachePolicy) timeoutInterval:30];
    [self loadRequest:request];
}

-(void)TT_evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler {
    [self evaluateJavaScript:javaScriptString completionHandler:completionHandler];
}

@end

@implementation TTUIWebView

- (NSURL *)URL {
    return self.request.URL;
}

- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType characterEncodingName:(NSString *)characterEncodingName baseURL:(NSURL *)baseURL {
    [self loadData:data MIMEType:MIMEType textEncodingName:characterEncodingName baseURL:baseURL];
}

- (void)loadURLString:(NSString *)urlString {
    [self loadURL:[NSURL URLWithString:urlString]];
}

- (void)loadURL:(NSURL *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:(NSURLRequestUseProtocolCachePolicy) timeoutInterval:30];
    [self loadRequest:request];
}

-(void)TT_evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler {
    NSString* result = [self stringByEvaluatingJavaScriptFromString:javaScriptString];
    if (completionHandler) {
        completionHandler(result,nil);
    }
}

@end

@implementation TTWebViewConfiguration

+ (instancetype)defaultWebViewConfiguration {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _allowsInlineMediaPlayback       = NO;
        _mediaPlaybackRequiresUserAction = YES;
        _mediaPlaybackAllowsAirPlay      = YES;
        _suppressesIncrementalRendering  = NO;
        _scalesPageToFit                 = YES;
        _showSupportHost                 = YES;
    }
    return self;
}
@end

@implementation TTWebViewJS

+(NSString *)scalesPageToFitJS {
    return @"var meta = document.createElement('meta'); \
    meta.name = 'viewport'; \
    meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'; \
    var head = document.getElementsByTagName('head')[0];\
    head.appendChild(meta);";
}

+(NSString *)imgsElement {
    return @"function imgsElement(){\
    var imgs = document.getElementsByTagName(\"img\");\
    var imgScr = '';\
    for(var i=0;i<imgs.length;i++){\
    imgs[i].onclick=function(){\
    document.location='img'+this.src;\
    };\
    if(i == imgs.length-1){\
    imgScr = imgScr + imgs[i].src;\
    break;\
    }\
    imgScr = imgScr + imgs[i].src + ',';\
    };\
    return imgScr;\
    };";
}

@end
