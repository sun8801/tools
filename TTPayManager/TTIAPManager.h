//
//  TTIPAManager.h
//  TT
//
//  Created by sunzongtang on 2017/8/31.
// 苹果内购


/**
 使用方法
 1、
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
 // Override point for customization after application launch.
 
    [[TTIAPManager sharedIAPManager] startManager];
 
    return YES;
 }
 
 2、修改TTIAPManager文件
    .m
 
    a、 修改-(void)saveReceipt:(SKPaymentTransaction *)transaction
 
    // FIXME: 设置交易凭证存在方式
    NSDictionary *receiptDic = @{
        TTIAPReceiptKey  : self.receipt,
        TTIAPOrderIdKey  : self.orderId,
        TTIAPProductIdKey: self.productId,
        TTIAPSandboxKey  : @(TTIAPEnvironment)
    };
 
    b、添加交易凭证上传服务端接口 - (void)sendReceiptToAPPServer:(NSDictionary *)receiptDict
 
 3、在需要内购的地方实现
 - (void)buy {
    [TTIAPManager sharedIAPManager].delegate = self;
    //通过api 从服务获取购买商品的ID和订单ID
    [[TTIAPManager sharedIAPManager] buyGoodsWithProductId:@"商品ID" orderId:@"订单ID"];
 }
 
 - (void)IAPTansactionResultCode:(TTIAPCodeType)codeType error:(NSString *)errorString {
    //获得当前交易回调
 }
 
 */


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TTIAPCodeType) {
    TTIAPCodeTypeAppleError                  = 0, // 苹果返回错误信息
    TTIAPCodeTypeCanNotMakePayment           = 1, // 用户禁止应用内付费购买
    TTIAPCodeTypeTransactionSucceed          = 2, // 交易成功
    TTIAPCodeTypeHasUnFinishedTransaction    = 3, // 有未完成的交易，稍等购买
    TTIAPCodeTypeCanNotGetProductInfromation = 4, // 无法获取产品信息，请重试
    
    TTIAPCodeTypeCancel                      = 5, // 用户取消交易
    TTIAPCodeTypeBuyFailed                   = 6, // 购买失败，请重试
    TTIAPCodeTypeEmptyGoods                  = 7, // 商品为空
    TTIAPCodeTypePurchasing                  = 8, // 正在购买ing
    TTIAPCodeTypeNetworkError                = 9, // 无网络
};

@protocol TTIAPTransactionResultDelegate <NSObject>

- (void)IAPTansactionResultCode:(TTIAPCodeType)codeType error:(NSString *)errorString;

@end

@interface TTIAPManager : NSObject

+ (instancetype)sharedIAPManager;

/**
 更新支付环境， 正式环境与开发环境，默认为开发环境

 @param isSanbox 是否是开发环境  初始时调用
 */
+ (void)updateIAPEnvironment:(BOOL) isSanbox;

@property (nonatomic, weak) id<TTIAPTransactionResultDelegate> delegate;

/**
 启动工具
 */
- (void)startManager;

/**
 结束工具
 */
- (void)stopManager;

/**
 购买商品
 是从服务端请求下来的
 @param productId 商品ID app申请的
 @param orderId   订单编号
 */
- (void)buyGoodsWithProductId:(NSString *)productId orderId:(NSString *)orderId;

/**
 主动上传交易凭证， 基本不需要手动触发
 */
- (void)uploadReceipts;

@end
