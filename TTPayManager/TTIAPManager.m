//
//  TTIPAManager.m
//  TT
//
//  Created by sunzongtang on 2017/8/31.
//

#import "TTIAPManager.h"
#import <StoreKit/StoreKit.h>

static NSString * const TTIAPReceiptKey   = @"receipt";
static NSString * const TTIAPProductIdKey = @"product_id";
static NSString * const TTIAPOrderIdKey   = @"orderId";
static NSString * const TTIAPSandboxKey   = @"sandbox"; //1：sanbox环境；0：正式环境

static NSInteger TTIAPEnvironment         = 1; //1：sanbox环境；0：正式环境

static NSString * const kTTReceiptKey     = @"TTReceiptKey";

@interface TTIAPManager ()<SKPaymentTransactionObserver, SKProductsRequestDelegate>

@property (nonatomic, assign) BOOL goodsRequestFinished; //判断一次请求是否完成

@property (nonatomic, copy) NSString *receipt;   //交易成功后拿到的一个64编码字符串 ,交易凭证
@property (nonatomic, copy) NSString *productId; //商品ID
@property (nonatomic, copy) NSString *orderId;   //订单Id

@property (nonatomic, strong) NSLock *lock;

@end

@implementation TTIAPManager {
    BOOL _hasStarted;
    dispatch_queue_t _IAP_Queue;
}

#pragma mark - singleton

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _IAPManager = [super allocWithZone:zone];
    });
    return _IAPManager;
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _IAPManager      = [super init];
        _IAPManager.lock = [[NSLock alloc] init];
        _IAPManager->_hasStarted = NO;
        _IAPManager->_IAP_Queue  = dispatch_queue_create("tt.iap.manager.pay.queue", DISPATCH_QUEUE_SERIAL);
    });
    return _IAPManager;
}

#pragma mark -public method

static TTIAPManager *_IAPManager;

+ (instancetype)sharedIAPManager {
    if (!_IAPManager) {
        _IAPManager = [[self alloc] init];
    }
    return _IAPManager;
}

+ (void)updateIAPEnvironment:(BOOL)isSanbox {
    TTIAPEnvironment = isSanbox? 1: 0;
}

- (void)startManager {
    @synchronized (self) {
        if (_hasStarted) {
            return;
        }
        _hasStarted = YES;
     
        self.goodsRequestFinished = YES;
        
        /***
         内购支付两个阶段：
         1.app直接向苹果服务器请求商品，支付阶段；
         2.苹果服务器返回凭证，app向公司服务器发送验证，公司再向苹果服务器验证阶段；
         */
        
        /**
         阶段一正在进中,app退出。
         在程序启动时，设置监听，监听是否有未完成订单，有的话恢复订单。
         */
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        /**
         阶段二正在进行中,app退出。
         在程序启动时，检测本地是否有receipt文件，有的话，去二次验证。
         */
        [self checkIAPReceiptFiles];
    }
}

- (void)stopManager {
    @synchronized (self) {
        if (!_hasStarted) {
            return;
        }
        _hasStarted = NO;
        [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    }
}

- (void)buyGoodsWithProductId:(NSString *)productId orderId:(NSString *)orderId{
    dispatch_async(_IAP_Queue, ^{
        if (!self.goodsRequestFinished) {
            NSLog(@"上次购买请求还未完成，请稍等");
            [self requestResultCode:TTIAPCodeTypeHasUnFinishedTransaction error:@"有未完成的交易，请稍等..."];
            return ;
        }
        
        if (![SKPaymentQueue canMakePayments]) { // 没有权限
            [self requestResultCode:TTIAPCodeTypeCanNotMakePayment error:@"用户禁止应用内付费购买"];
            return;
        }
        
        if (!productId.length || !orderId.length) {
            NSLog(@"商品为空");
            [self requestResultCode:TTIAPCodeTypeEmptyGoods error:@"商品为空"];
            return;
        }
        
        // 用户允许app内购
        self.orderId = orderId;
        self.productId = productId;
        self.goodsRequestFinished = NO; //正在请求
        
        NSArray *product = @[productId];
        NSSet *set = [NSSet setWithArray:product];
        
        SKProductsRequest *productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
        productRequest.delegate = self;
        [productRequest start];
        
        NSLog(@"%@商品正在请求中",productId);
    });
}

#pragma mark SKProductsRequestDelegate 查询成功后的回调
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    NSArray *product = response.products;
    
    if (product.count == 0) {
        
        NSLog(@"无法获取商品信息，请重试");
        
        [self requestResultCode:TTIAPCodeTypeCanNotGetProductInfromation error:@"无法获取商品信息，请重试"];
        self.goodsRequestFinished = YES; //失败，请求完成
        
    } else {
        //发起购买请求
        SKPayment *payment = [SKPayment paymentWithProduct:product[0]];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

#pragma mark SKProductsRequestDelegate 查询失败后的回调
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    [self requestResultCode:TTIAPCodeTypeAppleError error:error.localizedDescription];
    self.goodsRequestFinished = YES; //失败，请求完成
}

#pragma Mark 购买操作后的回调
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(nonnull NSArray<SKPaymentTransaction *> *)transactions {
    
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing://正在交易
                [self requestResultCode:TTIAPCodeTypePurchasing error:@"正在交易中..."];
                break;
                
            case SKPaymentTransactionStatePurchased://交易完成
                
                [self getReceipt]; //获取交易成功后的购买凭证
                
                [self saveReceipt:transaction]; //存储交易凭证
                
                [self checkIAPReceiptFiles];//把self.receipt发送到服务器验证是否有效
                
                [self completeTransaction:transaction];
                
                break;
                
            case SKPaymentTransactionStateFailed://交易失败
                
                [self failedTransaction:transaction];
                
                break;
                
            case SKPaymentTransactionStateRestored://已经购买过该商品
                
                [self restoreTransaction:transaction];
                
                break;
                
            default:
                
                break;
        }
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    self.goodsRequestFinished = YES; //成功，请求完成
}


- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"error :%@", [transaction.error localizedDescription]);
    
    if(transaction.error.code != SKErrorPaymentCancelled) {
        [self requestResultCode:TTIAPCodeTypeBuyFailed error:[transaction.error localizedDescription]];
        //购买失败
    } else {
        [self requestResultCode:TTIAPCodeTypeCancel error:@"取消了交易"];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    self.goodsRequestFinished = YES; //失败，请求完成
}


- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    self.goodsRequestFinished = YES; //恢复购买，请求完成
}

#pragma mark 获取交易成功后的购买凭证

- (void)getReceipt {
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
    self.receipt = [receiptData base64EncodedStringWithOptions:0];
}

#pragma mark  持久化存储用户购买凭证(这里最好还要存储当前日期，用户id等信息，用于区分不同的凭证)
-(void)saveReceipt:(SKPaymentTransaction *)transaction {

    if (!self.productId) {
        self.productId = transaction.payment.productIdentifier;
    }
    if (!self.receipt || !self.orderId || !self.productId) { //关闭交易
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        return;
    }
    
    // FIXME: 设置交易凭证存在方式
    
    NSDictionary *receiptDic = @{
                                 TTIAPReceiptKey  : self.receipt,
                                 TTIAPOrderIdKey  : self.orderId,
                                 TTIAPProductIdKey: self.productId,
                                 TTIAPSandboxKey  : @(TTIAPEnvironment)
                                 };
    self.orderId = nil;
    self.productId = nil;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *receipts = [NSMutableArray arrayWithArray:[userDefaults objectForKey:kTTReceiptKey]];
    [receipts addObject:receiptDic];
    
    [userDefaults setObject:receipts forKey:kTTReceiptKey];
    [userDefaults synchronize];
}


#pragma mark -private method

#pragma mark 将存储到本地的IAP文件发送给服务端 验证receipt失败,App启动后再次验证
- (void)checkIAPReceiptFiles{
    
    NSArray *receipts = [[NSUserDefaults standardUserDefaults] objectForKey:kTTReceiptKey];
    for (NSDictionary *receiptDict in receipts) {
        [self sendReceiptToAPPServer:receiptDict];
    }
}

#pragma mark -发送receipt 给APP服务器
- (void)sendReceiptToAPPServer:(NSDictionary *)receiptDict {
    if (!receiptDict || !receiptDict[TTIAPReceiptKey]) {
        return;
    }
    // FIXME: 设置网络请求 发送交易凭证给服务端
    /**
     1、如果请求成功 调用
        {
            [weakSelf requestResultCode:TTIAPCodeTypeTransactionSucceed error:@"交易成功"];
            [weakSelf removeReceipt:receiptDict];
        }
     2、如果是服务器错误（服务出错） 需重新发送
        {
            [weakSelf sendReceiptToAPPServer:receiptDict];
        }
     3、如果校验失败 直接删除小票
        {
            [weakSelf requestResultCode:TTIAPCodeTypeBuyFailed error:msg];
            [weakSelf removeReceipt:receiptDict];
        }
     4、网络问题，直接弹出
        {
            [weakSelf requestResultCode:TTIAPCodeTypeNetworkError error:@"无网络"];
        }
     */
    __weak typeof(self) weakSelf = self;
//    [TTRequestManager pay_appstorePayCheckParamDict:receiptDict showHUDInView:nil success:^(NSDictionary *resultDict, NSInteger code, NSString *msg) {
//        if (code == 1) {
//            [weakSelf requestResultCode:TTIAPCodeTypeTransactionSucceed error:@"交易成功"];
//            [weakSelf removeReceipt:receiptDict];
//        }else if (code == 2){//服务器错误，需要重新请求
//            [weakSelf sendReceiptToAPPServer:receiptDict];
//        }else {
//           [weakSelf requestResultCode:TTIAPCodeTypeBuyFailed error:msg];
//            [weakSelf removeReceipt:receiptDict];
//        }
//    } failure:^(NSError *error) {
//       [weakSelf requestResultCode:TTIAPCodeTypeNetworkError error:@"无网络"];
//    }];
}

#pragma mark -删除本地receipt
- (void)removeReceipt:(NSDictionary *)receiptDict {
    [self.lock lock];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *orderId = receiptDict[TTIAPOrderIdKey];
    NSMutableArray *receipts = [NSMutableArray arrayWithArray: [userDefaults objectForKey:kTTReceiptKey]];
    [receipts enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *orderId_t = obj[TTIAPOrderIdKey];
        if ([orderId isEqualToString:orderId_t]) {
            [receipts removeObjectAtIndex:idx];
            *stop = YES;
        }
    }];
    [userDefaults setObject:receipts forKey:kTTReceiptKey];
    [userDefaults synchronize];
    [self.lock unlock];
}

#pragma mark -错误信息反馈
- (void)requestResultCode:(TTIAPCodeType)codeType error:(NSString *)errorString {
    if (self.delegate && [self.delegate respondsToSelector:@selector(IAPTansactionResultCode:error:)]) {
        if (NSThread.isMainThread) {
            [self.delegate IAPTansactionResultCode:codeType error:errorString];
        }else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate IAPTansactionResultCode:codeType error:errorString];
            });
        }
    }
}

@end
