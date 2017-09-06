//
//  AppDelegate.m
//  TaoPiao
//
//  Created by 黎应明 on 2017/8/30.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import "AppDelegate.h"
#import "BaseTabBarViewController.h"

//腾讯SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

//微信SDK头文件
#import "WXApi.h"

//新浪微博SDK头文件
#import "WeiboSDK.h"

#import <MeiQiaSDK/MQManager.h>
@interface AppDelegate ()<WXApiDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
        BaseTabBarViewController *tabVC = [[BaseTabBarViewController alloc]init];
        self.window.rootViewController = tabVC;
        [[IQKeyboardManager sharedManager] setToolbarManageBehaviour:IQAutoToolbarByPosition];
        [[IQKeyboardManager sharedManager] setShouldShowTextFieldPlaceholder:NO];
        [Tool getUserInfoFromSqlite];
    
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


        return YES;
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
    //    NSDictionary *dict = [dataStr objectFromJSONString];
    
  //  NSString *messageType = [dict objectForKey:@"messageType"];
  //  NSString *title = [dict objectForKey:@"title"];
  //  NSDictionary *data = [dict objectForKey:@"content"];
    
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
        
           }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // Required
    [JPUSHService registerDeviceToken:deviceToken];
    
    MLog(@"apple device token = %@", deviceToken);
    
    // 上传设备deviceToken，以便美洽自建推送后，迁移推送
   // [MQManager registerDeviceToken:deviceToken];
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
