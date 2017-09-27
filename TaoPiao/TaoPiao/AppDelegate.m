//
//  AppDelegate.m
//  TaoPiao
//
//  Created by 黎应明 on 2017/8/30.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import "AppDelegate.h"
#import "BaseTabBarViewController.h"
#import "Tool.h"
//腾讯SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

//微信SDK头文件
#import "WXApi.h"

//新浪微博SDK头文件
#import "WeiboSDK.h"

#import "SPayClient.h"

#import <MeiQiaSDK/MQManager.h>
@interface AppDelegate ()<WXApiDelegate>
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    /*  获取服务器配置信息
     *
     *  1.校验版本判断是否正在进行苹果审核
     *  2.是否需要强制更新
     */
       [Tool getServerConfigure];
    
        BaseTabBarViewController *tabVC = [[BaseTabBarViewController alloc]init];
        self.window.rootViewController = tabVC;
    
        [[IQKeyboardManager sharedManager] setToolbarManageBehaviour:IQAutoToolbarByPosition];
        [[IQKeyboardManager sharedManager] setShouldShowTextFieldPlaceholder:NO];
        [Tool getUserInfoFromSqlite];
        [self autoLogin];
    //注册极光
        [self registerJGPushWithLaunchOptions:launchOptions];
    //推送注册
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8){
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
    
    // 微信注册
    [self initWXApi];
    
    [self initShareFunction];
    //#error 请填写您的美洽 AppKey
    [MQManager initWithAppkey:kMeiQiaAppKey completion:^(NSString *clientId, NSError *error) {
        if (!error) {
            NSLog(@"美洽 SDK：初始化成功");
        } else {
            NSLog(@"美洽error:%@", error);
        }
    }];
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    SPayClientWechatConfigModel *wechatConfigModel = [[SPayClientWechatConfigModel alloc] init];
    wechatConfigModel.appScheme = @"wxe76985ecf18269b0";
    wechatConfigModel.wechatAppid = @"wxe76985ecf18269b0";
    wechatConfigModel.isEnableMTA =YES;
    
    //配置微信APP支付
    [[SPayClient sharedInstance] wechatpPayConfig:wechatConfigModel];
    [[SPayClient sharedInstance] application:application
               didFinishLaunchingWithOptions:launchOptions];

    // 配置支付宝支付
    SPayClientAlipayConfigModel *alipayConfigModel = [[SPayClientAlipayConfigModel alloc] init];
    alipayConfigModel.appScheme = @"TaoPiao";
    [[SPayClient sharedInstance] alipayAppConfig:alipayConfigModel];
    
    _operationQueue = [[NSOperationQueue alloc] init];
    _operationQueue.maxConcurrentOperationCount = 1;
        return YES;
}

- (void)autoLogin
{
    if ([Tool islogin])
    {
        if (![ShareManager shareInstance].userinfo) {
            return;
        }
        
        // Token未失效, 不用自动登录
        BOOL tokenIsValid = [LoginModel validateToken];
        if (tokenIsValid) {
            return;
        }
        
        [Tool autoLoginSuccess:^(NSDictionary *resultDic) {
            
            NSInteger resultCode = [resultDic[@"status"] integerValue];
            if (resultCode != 0) {
                MLog(@"自动登录失败");
                //                [Tool showPromptContent:@"自动登录失败" onView:self.window];
            }else{
               MLog(@"自动登录成功");
            }
            
        } fail:^(NSString *description) {
            MLog(@"自动登录失败");
            //自动登录失败，显示登录对话框
            //            [Tool showPromptContent:@"自动登录失败" onView:self.window];
        }];
    }
}

//禁止横屏
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - 各平台回调

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString *,id> *)options{
    MLog(@"optionsalipayURL%@",url);
    if([url.host isEqualToString:@"data_success"])
    {
        //在safari中支付成功
        [[NSNotificationCenter defaultCenter] postNotificationName:kPaySuccessInSafari object:nil userInfo:nil];
    }
    
    if ([url.host isEqualToString:@"safepay"])
    {
        NSString *str = url.query;
        NSDictionary *resultDict = [str.stringByRemovingPercentEncoding objectFromJSONString];
        if (resultDict) {
            NSDictionary *dict = [resultDict objectForKey:@"memo"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kAlipayNotification object:nil userInfo:dict];
        }
        
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url
                                                  standbyCallback:^(NSDictionary *resultDic) {
                                                      //【由于在跳转支付宝客户端支付的过程中,商户 app 在后台很可能被系统 kill 了,所以 pay 接口的 callback 就会失效,请商户对 standbyCallback 返回的回调结果进行处理,就是在这个方 法里面处理跟 callback 一样的逻辑】
                                                      NSLog(@"processOrderWithPaymentResult = %@",resultDic);
                                                      NSString *resultStatue = (NSString *)[resultDic objectForKey:@"resultStatus"];
                                                      [self handlePayResultNotification:resultStatue];
                                                  }];
    }
    
    if ([url.host isEqualToString:@"pay"])
    {
        [WXApi handleOpenURL:url delegate:self];
    }
    
    [[SPayClient sharedInstance] application:app openURL:url options:options];
    
    return YES;
};

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    MLog(@"sourceApplicationalipayURL%@",url);
    if([url.host isEqualToString:@"data_success"])
    {
        //在safari中支付成功
        [[NSNotificationCenter defaultCenter] postNotificationName:kPaySuccessInSafari object:nil userInfo:nil];
    }
    
    if ([url.host isEqualToString:@"safepay"])
    {
        
        
        NSString *str = url.query;
        NSDictionary *resultDict = [str.stringByRemovingPercentEncoding objectFromJSONString];
        if (resultDict) {
            NSDictionary *dict = [resultDict objectForKey:@"memo"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kAlipayNotification object:nil userInfo:dict];
        }
        
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url
                                                  standbyCallback:^(NSDictionary *resultDic) {
                                                      //【由于在跳转支付宝客户端支付的过程中,商户 app 在后台很可能被系统 kill 了,所以 pay 接口的 callback 就会失效,请商户对 standbyCallback 返回的回调结果进行处理,就是在这个方 法里面处理跟 callback 一样的逻辑】
                                                      NSLog(@"processOrderWithPaymentResult = %@",resultDic);
                                                      NSString *resultStatue = (NSString *)[resultDic objectForKey:@"resultStatus"];
                                                      [self handlePayResultNotification:resultStatue];
                                                  }];
    }
    
    if ([url.host isEqualToString:@"pay"])
    {
        [WXApi handleOpenURL:url delegate:self];
    }
    
    [[SPayClient sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    
    return YES;
    
    //    return [ShareSDK handleOpenURL:url
    //                 sourceApplication:sourceApplication
    //                        annotation:annotation
    //                        wxDelegate:self];
}

/**
 *  支付结果处理支付结果
 */
- (void)handlePayResultNotification:(NSString *)resultStatue
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kPaySuccess object:@{@"resultStatue":[resultStatue init]}];
    switch ([resultStatue intValue] ) {
            
        case 9000:
            [Tool showPromptContent:@"恭喜您，支付成功！" onView:self.window];
            break;
        case 8000:
            [Tool showPromptContent:@"正在处理中,请稍候查看！" onView:self.window];
            break;
        case 4000:
            [Tool showPromptContent:@"很遗憾，您此次支付失败，请您重新支付！" onView:self.window];
            break;
        case 6001:
            [Tool showPromptContent:@"您已取消了支付操作！" onView:self.window];
            break;
        case 6002:
            [Tool showPromptContent:@"网络连接出错，请您重新支付！" onView:self.window];
            break;
        default:
            break;
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    
    MLog(@"%@ %@", NSStringFromSelector(_cmd), url);
    
    return  [[SPayClient sharedInstance] application:application handleOpenURL:url];
    
    //    return [ShareSDK handleOpenURL:url  wxDelegate:self];
}

//#pragma mark - 微信支付回调
#pragma mark - WXApiDelegate

-(void) onReq:(BaseReq*)req
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

-(void)onResp:(BaseResp *)resp{

    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    NSString *strTitle;
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        strTitle = [NSString stringWithFormat:@"发送媒体消息结果"];
    }
    if ([resp isKindOfClass:[PayResp class]]) {
        strTitle = [NSString stringWithFormat:@"支付结果"];
        
        int isSuccess  = 0;
        
        switch (resp.errCode) {
            case WXSuccess:
            {
                NSLog(@"支付成功!");
                isSuccess = 0;
            }
                break;
            case WXErrCodeCommon:
                isSuccess = -1;
                break;
            case WXErrCodeUserCancel:
                isSuccess = -2;
                break;
            case WXErrCodeSentFail:
                isSuccess = -3;
                break;
            case WXErrCodeUnsupport:
                isSuccess = -5;
                break;
            case WXErrCodeAuthDeny:
                isSuccess = -4;
                break;
            default:
                break;
        }
        
        NSDictionary *parameters = nil;
        parameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",isSuccess],@"statue",nil];
        //登录成功通知
        [[NSNotificationCenter defaultCenter] postNotificationName:kWeiXinPayNotif object:nil userInfo:parameters];
        
    }
}


#pragma mark -

- (void)initWXApi
{
    [WXApi registerApp:WeiXinKey];
    BOOL result = [WXApi isWXAppInstalled];
    MLog(@"isWXAppInstalled = %d", result);
    
    result = [WXApi isWXAppSupportApi];
    MLog(@"isWXAppSupportApi = %d", result);
    
    MLog(@"getApiVersion %@", [WXApi getApiVersion]);
}

#pragma mark - init sharesdk

- (void)initShareFunction
{
    // ShareSDK
    [ShareSDK registerApp:@"1c05c5f5ff82f"
          activePlatforms:@[@(SSDKPlatformTypeSinaWeibo),
                            @(SSDKPlatformTypeTencentWeibo),
                            @(SSDKPlatformTypeWechat),
                            @(SSDKPlatformTypeQQ)]
                 onImport:^(SSDKPlatformType platformType) {
                     
                     switch (platformType)
                     {
                         case SSDKPlatformTypeWechat:
                             [ShareSDKConnector connectWeChat:[WXApi class]];
                             break;
                         case SSDKPlatformTypeQQ:
                             [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                             break;
                         case SSDKPlatformTypeSinaWeibo:
                             [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                             break;
                         default:
                             break;
                     }
                     
                 }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
              
              switch (platformType)
              {
                  case SSDKPlatformTypeSinaWeibo:
                      //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                      [appInfo SSDKSetupSinaWeiboByAppKey:WeiBoKey
                                                appSecret:WeiBoSecret
                                              redirectUri:@"http://sns.whalecloud.com/sina2/callback"
                                                 authType:SSDKAuthTypeBoth];
                      break;
                case SSDKPlatformTypeWechat:
                      //设置微信应用信息
                      [appInfo SSDKSetupWeChatByAppId:WeiXinKey
                                            appSecret:WeiXinSecret];
                      break;
                  case SSDKPlatformTypeQQ:
                      //设置QQ应用信息，其中authType设置为只用SSO形式授权
                      [appInfo SSDKSetupQQByAppId:QQKey
                                           appKey:QQSecret
                                         authType:SSDKAuthTypeSSO];
                      break;
                  default:
                      break;
              }
          }];
    
}


#pragma mark - jpush
- (void)registerJGPushWithLaunchOptions:(NSDictionary *)launchOptions
{
    //    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
    //可以添加自定义categories
    [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                      UIUserNotificationTypeSound |
                                                      UIUserNotificationTypeAlert)
                                          categories:nil];
    
    BOOL isProduction = NO;
#if DEBUG
    isProduction = NO;
#else
    isProduction = YES;
#endif
    
    [JPUSHService setupWithOption:launchOptions appKey:JGPushKey channel:@"public" apsForProduction:isProduction];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jpfNetworkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
}

- (void)jpfNetworkDidReceiveMessage:(NSNotification *)notify
{
    MLog(@"%@", notify);
    NSDictionary *userInfo = notify.userInfo;
    NSDictionary *dict = [userInfo objectForKey:@"extras"];
    MLog(@"%@", [dict my_description]);
//        NSDictionary *dict = [dataStr objectFromJSONString];
    
    NSString *messageType = [dict objectForKey:@"messageType"];
//    NSString *title = [dict objectForKey:@"title"];
    NSDictionary *data = [dict objectForKey:@"content"];
    
    // 是否支持版本
    BOOL containThisVersion = NO;
    NSDictionary *versionsDict = [dict objectForKey:@"versions"];
    NSArray *versions = [[versionsDict objectForKey:@"ios"] componentsSeparatedByString:@","];
    NSString *currenVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    for (NSString *version in versions) {
        if ([version isEqualToString:currenVersion]) {
            containThisVersion = YES;
            break;
        }
    }
    
    // 字段为空支持所有版本
    if (versions.count == 0) {
        containThisVersion = YES;
    }
    
    if (containThisVersion) {
        if ([messageType isEqualToString:@"payResult_alert"]) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kPayNotification object:nil userInfo:data];
            
            // 配置信息发生变化
        } else if ([messageType isEqualToString:@"configs_Change"]) {
            
            [Tool getConfigurePaymentChannels];
            
            // 欢乐豆兑换比例发生变化
        }
//         [Tool getConfigurePaymentChannels];
        
           }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // Required
    [JPUSHService registerDeviceToken:deviceToken];
    
    MLog(@"apple device token = %@", deviceToken);
    
    // 上传设备deviceToken，以便美洽自建推送后，迁移推送
    [MQManager registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    MLog(@"%@ = %@", NSStringFromSelector(_cmd), userInfo);
    
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
       MLog(@"%@ = %@", NSStringFromSelector(_cmd), [userInfo my_description]);
    
        // IOS 7 Support Required
        [JPUSHService handleRemoteNotification:userInfo];
        completionHandler(UIBackgroundFetchResultNewData);
    }


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}



@end
