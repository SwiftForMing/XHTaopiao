//
//  HttpHelper.m
//  TaoPiao
//
//  Created by 黎应明 on 2017/9/1.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import "HttpHelper.h"
#import "AFNetworking.h"
#import "SecurityUtil.h"
#import "Tool.h"

@interface HttpHelper()


@end
@implementation HttpHelper

- (void)dealloc
{
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), NSStringFromClass([self class]));
}

+ (instancetype)helper
{
    HttpHelper *helper = [[HttpHelper alloc] init];
    return helper;
}
#pragma mark - 拼接:URL_Server+keyURL
/**
 * 拼接:URL_Server+keyURL
 */
+ (NSString *)getURL{
    
    NSString *str =  URL_Server;
    
//    if ([ShareManager shareInstance].isInReview == YES) {
//        str =  URL_ServerTest;
//    }
    
    return str;
}
#pragma mark - 获取版本号
/**
 * 获取版本号
 * 本地版本号 >= 服务器版本号，表示新版本正在审核阶段
 */
+ (void)getVersion:(void (^)(NSDictionary *resultDic))success
              fail:(void (^)(NSString *description))fail
{
    NSString *URLString = [NSMutableString stringWithFormat:@"%@%@", URL_Server_Still, URL_GetVersion];
    [self getHttpBaseQuestWithUrl:URLString success:success fail:fail];
}

#pragma mark - 注册、登录、获取验证码、找回密码
/**
 * 获取验证码
 * type:[1.注册,2.找回密码,3.修改电话号码和微信绑定]
 */
+ (void)getVerificationCodeByMobile:(NSString *)mobile
                               type:(NSString *)type
                            success:(void (^)(NSDictionary *resultDic))success
                               fail:(void (^)(NSString *description))fail
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (mobile) {
        [parameters setObject:mobile forKey:@"app_login_id"];
    }
    
    if (type) {
        [parameters setObject:type forKey:@"type"];
    }
    //拼接:URL_Server+keyURL
    NSString *URLString = [self getURLbyKey:URL_GetVerificationCode];
    
    [self postHttpWithDic:parameters urlStr:URLString success:success fail:fail];
}



/**
 * 注册
 */
+ (void)registerByWithMobile:(NSString *)mobile
                    password:(NSString *)password
           recommend_user_id:(NSString *)recommend_user_id
                   auth_code:(NSString *)auth_code
                     success:(void (^)(NSDictionary *resultDic))success
                        fail:(void (^)(NSString *description))fail
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (mobile) {
        [parameters setObject:mobile forKey:@"app_login_id"];
    }
    if (password) {
        [parameters setObject:password forKey:@"password"];
    }
    if (recommend_user_id) {
        [parameters setObject:recommend_user_id forKey:@"recommend_user_id"];
    }else{
        [parameters setObject:@"" forKey:@"recommend_user_id"];
    }
    if (auth_code) {
        [parameters setObject:auth_code forKey:@"auth_code"];
    }
    //拼接:URL_Server+keyURL
    NSString *URLString = [self getURLbyKey:URL_Register];
    
    [self postHttpWithDic:parameters urlStr:URLString success:success fail:fail];
}


/**
 * 手机号登录
 */
+ (void)loginByWithMobile:(NSString *)mobile
                 password:(NSString *)password
                 jpush_id:(NSString *)jpush_id
                  success:(void (^)(NSDictionary *resultDic))success
                     fail:(void (^)(NSString *description))fail
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (mobile) {
        
        [parameters setObject:mobile forKey:@"app_login_id"];
    }
    if (password) {
        
        [parameters setObject:password forKey:@"password"];
    }
    if (jpush_id) {
        
        [parameters setObject:jpush_id forKey:@"jpush_id"];
    }else{
        
        [parameters setObject:@"" forKey:@"jpush_id"];
    }
    
    
#if TARGET_IPHONE_SIMULATOR
    [parameters setObject:@"iOS test" forKey:@"jpush_id"];
#endif
    MLog(@"log%@",parameters);
    //拼接:URL_Server+keyURL
    NSString *URLString = [self getURLbyKey:URL_Login];
    
    [self loginWithAbsoluteURLString:URLString parameter:parameters success:success fail:fail];
}

/**
 * 第三方登录
 * jpush_id :极光推送id(registrationId)
 * type:登陆形式[weixin,qq]
 */
+ (void)thirdloginByWithLoginId:(NSString *)app_login_id
                      nick_name:(NSString *)nick_name
                    user_header:(NSString *)user_header
                           type:(NSString *)type
                       jpush_id:(NSString *)jpush_id
                        success:(void (^)(NSDictionary *resultDic))success
                           fail:(void (^)(NSString *description))fail
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (app_login_id) {
        [parameters setObject:app_login_id forKey:@"app_login_id"];
    }
    if (nick_name) {
        
        [parameters setObject:nick_name forKey:@"nick_name"];
    }else{
        [parameters setObject:@"" forKey:@"nick_name"];
    }
    
    if (user_header) {
        
        [parameters setObject:user_header forKey:@"user_header"];
    }else{
        [parameters setObject:@"" forKey:@"user_header"];
    }
    
    if (type) {
        
        [parameters setObject:type forKey:@"type"];
    }else{
        [parameters setObject:@"" forKey:@"type"];
    }
    
    if (jpush_id) {
        
        [parameters setObject:jpush_id forKey:@"jpush_id"];
    }else{
        [parameters setObject:@"" forKey:@"jpush_id"];
    }
    
    //拼接:URL_Server+keyURL
    NSString *URLString = [self getURLbyKey:URL_ThirdLogin];
    
    [self loginWithAbsoluteURLString:URLString parameter:parameters success:success fail:fail];
}


// 登录接口统一增加uuid， 客户编号，token保存
+ (void)loginWithAbsoluteURLString:(NSString *)absoluteURL
                         parameter:(NSMutableDictionary *)parameters
                           success:(void (^)(NSDictionary *resultDic))success
                              fail:(void (^)(NSString *description))fail
{
    NSString *uuid = [Tool getUUID];
    NSString *clien_version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *clien_type = @"iOS";
    
    if (uuid) {
        [parameters setObject:uuid forKey:@"mac_address"];
    }
    
    if (clien_version) {
        [parameters setObject:clien_version forKey:@"clien_version"];
    }
    if (clien_type) {
        [parameters setObject:clien_type forKey:@"clien_type"];
    }
    
    [self postHttpWithDic:parameters urlStr:absoluteURL success:^(NSDictionary *resultDic) {
        
        // 保存token
        NSDictionary *data = [resultDic objectForKey:@"data"];
        if (data) {
            NSString *token = [data objectForKey:@"token"];
            NSString *nowTime = [data objectForKey:@"nowTime"];
            NSInteger timeDifference = [NSDate serverTimeDifference:[nowTime longLongValue]];
            
            [[ShareManager shareInstance] setToken:token];
            [[ShareManager shareInstance] setServerTimeDifference:timeDifference];
            
            // 保存登录信息
            UserInfo *userInfo = [data objectByClass:[UserInfo class]];
            userInfo.islogin = YES;
            [ShareManager shareInstance].userinfo = userInfo;
            [Tool saveUserInfoToDB:YES];
        }
        
        success(resultDic);
        
    } fail:^(NSString *description) {
        fail(description);
    }];
}


/**
 * 找回密码
 */
+ (void)findPwdByWithMobile:(NSString *)mobile
                   password:(NSString *)password
                  auth_code:(NSString *)auth_code
                    success:(void (^)(NSDictionary *resultDic))success
                       fail:(void (^)(NSString *description))fail
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (mobile) {
        [parameters setObject:mobile forKey:@"app_login_id"];
    }
    if (password) {
        [parameters setObject:password forKey:@"password"];
    }
    if (auth_code) {
        [parameters setObject:auth_code forKey:@"auth_code"];
    }
    //拼接:URL_Server+keyURL
    NSString *URLString = [self getURLbyKey:URL_FindPwd];
    
    [self postHttpWithDic:parameters urlStr:URLString success:success fail:fail];
}

/**
 * 第三方绑定
 */
+ (void)bangDingByWithLoginId:(NSString *)app_login_id
                         type:(NSString *)type
                      url_tel:(NSString *)url_tel
                    auth_code:(NSString *)auth_code
            recommend_user_id:(NSString *)recommend_user_id
                      success:(void (^)(NSDictionary *resultDic))success
                         fail:(void (^)(NSString *description))fail
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (app_login_id) {
        [parameters setObject:app_login_id forKey:@"app_login_id"];
    }
    if (type) {
        [parameters setObject:type forKey:@"type"];
    }
    if (url_tel) {
        [parameters setObject:url_tel forKey:@"user_tel"];
    }
    if (auth_code) {
        [parameters setObject:auth_code forKey:@"auth_code"];
    }
    if (recommend_user_id) {
        [parameters setObject:recommend_user_id forKey:@"recommend_user_id"];
    }
    
    //拼接:URL_Server+keyURL
    NSString *URLString = [self getURLbyKey:URL_BangDing];
    
    [self postHttpWithDic:parameters urlStr:URLString success:success fail:fail];
}

#pragma mark - 拼接:URL_Server+keyURL
/**
 * 拼接:URL_Server+keyURL
 */
+ (NSString *)getURLbyKey:(NSString *)URLKey{
    
    NSString *str = [NSMutableString stringWithFormat:@"%@%@", URL_Server, URLKey];
   /*
    if ([ShareManager shareInstance].isInReview == YES) {
        str = [NSMutableString stringWithFormat:@"%@%@", URL_ServerTest, URLKey];
    }
    */
    
    return str;
}
#pragma mark - 获取分类相关数据
+(void)getSearchIDDataWithID:(NSString *)goodID
                     pageNum:(NSString *)page
                     limitNum:(NSString *)limit
                     success:(void (^)(NSDictionary *resultDic))success
                        fail:(void (^)(NSString *description))fail
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (goodID) {
        [parameters setObject:goodID forKey:@"goodsTypeId"];
    }else{
        MLog(@"缺少参赛goodID");
    }
    if (page) {
        [parameters setObject:page forKey:@"pageNum"];
    }else{
        MLog(@"缺少参赛page");
    }
    if (limit) {
        [parameters setObject:limit forKey:@"limitNum"];
    }else{
        MLog(@"缺少参赛page");;
    }
    
    //拼接:URL_Server+keyURL
    NSString *URLString = [self getURLbyKey:URL_GoodType];
    
    [self postHttpWithDic:parameters urlStr:URLString success:success fail:fail];
}

/**
 * 获取关键字搜索数据
 *
 */
+(void)getSearchKeyDataWithKeyWord:(NSString *)key success:(void (^)(NSDictionary *resultDic))success
                          fail:(void (^)(NSString *description))fail
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (key) {
        [parameters setObject:key forKey:@"searchKey"];
    }else{
        [parameters setObject:@"" forKey:@"searchKey"];
    }

    //拼接:URL_Server+keyURL
    NSString *URLString = [self getURLbyKey:URL_GoodsSearchKeyList];
    
    [self postHttpWithDic:parameters urlStr:URLString success:success fail:fail];

}

#pragma mark - 获取首页相关数据
+(void)getHomeListDataWithPageNum:(NSString *)page
                         limitNum:(NSString *)limit
                          success:(void (^)(NSDictionary *resultDic))success
                              fail:(void (^)(NSString *description))fail
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (page) {
        [parameters setObject:page forKey:@"pageNum"];
    }else{
        MLog(@"缺少参赛page");
    }
    if (limit) {
        [parameters setObject:limit forKey:@"limitNum"];
    }else{
        MLog(@"缺少参赛page");;
    }

    //拼接:URL_Server+keyURL
    NSString *URLString = [self getURLbyKey:URL_Recommend];
    
    [self postHttpWithDic:parameters urlStr:URLString success:success fail:fail];
    
}

#pragma mark - 获取优惠卷相关数据
+(void)getCouponListDataWithUserID:(NSString *)user_id
                           PageNum:(NSString *)page
                          limitNum:(NSString *)limit
                              type:(NSString *)type
                           success:(void (^)(NSDictionary *resultDic))success
                              fail:(void (^)(NSString *description))fail
{
    
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (user_id) {
        [parameters setObject:user_id forKey:@"user_id"];
    }else{
        MLog(@"缺少参赛goodID");
    }
    if (page) {
        [parameters setObject:page forKey:@"pageNum"];
    }else{
        MLog(@"缺少参赛page");
    }
    if (limit) {
        [parameters setObject:limit forKey:@"limitNum"];
    }else{
        MLog(@"缺少参赛page");;
    }
    if (type) {
        [parameters setObject:type forKey:@"type"];
    }else{
        MLog(@"缺少参赛type");
    }
    //拼接:URL_Server+keyURL
    NSString *URLString = [self getURLbyKey:URL_MyCouponsList];
    [self postHttpWithDic:parameters urlStr:URLString success:success fail:fail];
    
    
}

+(void)getAddCouponDataWithUserID:(NSString *)user_id
                   Coupons_secret:(NSString *)secret
                          success:(void (^)(NSDictionary *resultDic))success
                             fail:(void (^)(NSString *description))fail{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (user_id) {
        [parameters setObject:user_id forKey:@"user_id"];
    }else{
        MLog(@"缺少参赛goodID");
    }
    if (secret) {
        [parameters setObject:secret forKey:@"coupons_secret"];
    }else{
        MLog(@"缺少参赛secret");
    }
        //拼接:URL_Server+keyURL
    NSString *URLString = [self getURLbyKey:URL_AddCoupon];
    [self postHttpWithDic:parameters urlStr:URLString success:success fail:fail];

}

+ (void)getHttpWithUrlStr:(NSString *)urlStr
                  success:(void (^)(NSDictionary *resultDic))success
                     fail:(void (^)(NSString *description))fail
{
    NSString *URLString = [self getURLbyKey:urlStr];
    [self getHttpBaseQuestWithUrl:URLString success:success fail:fail];
}

+ (void)getHttpBaseQuestWithUrl:(NSString *)urlstr
                        success:(void (^)(NSDictionary *resultDic))success
                           fail:(void (^)(NSString *description))fail
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [self postHttpWithDic:parameters urlStr:urlstr success:success fail:fail];
}


/**
 * Post请求数据
 */
+ (void)postHttpWithDic:(NSMutableDictionary *)parameter
                 urlStr:(NSString *)urlStr
                success:(void (^)(NSDictionary *resultDic))success //成功
                   fail:(void (^)(NSString *description))fail      //失败
{
    //当前时间戳 单位毫秒
    UInt64 recordTime = [[NSDate date] timeIntervalSince1970]*1000;
    NSString *requestTime = [NSString stringWithFormat:@"%lld",recordTime];
    [parameter setObject:requestTime forKey:@"request_time"];
    
    // iOS
    [parameter setObject:@"iOS" forKey:@"system"];
    
    // version
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [parameter setObject:version forKey:@"version"];
    
//    NSString *sign= [RSAEncrypt encryptString:requestTime publicKey:EncryptByRsaPublicKey];
//    [parameter setObject:sign forKey:@"sign"];
    
    NSArray *allkeys = [parameter allKeys];
    NSString *sign = nil;
    for (NSString *mkey in allkeys)
    {
        NSObject *value = [parameter objectForKey:mkey];
        if (!sign) {
            sign = [NSString stringWithFormat:@"%@",value];
        }else{
            sign = [NSString stringWithFormat:@"%@|$|%@",sign,value];
        }
    }
    NSString *str = [SecurityUtil encodeBase64Data:[SecurityUtil encryptAESData:sign]];
    [parameter setObject:str forKey:@"sign"];
    
    // 登录授权验证
    NSString *token = [[ShareManager shareInstance] token];
    if (token) {
        [parameter setObject:token forKey:@"token"];
    }
    
    NSData *jsParameters = [NSJSONSerialization dataWithJSONObject:parameter  options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString *aString = [[NSString alloc] initWithData:jsParameters encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    [parameters setObject:aString forKey:@"param"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    
    // create request
    NSURLRequest *request = [requestSerializer requestWithMethod:@"POST" URLString:urlStr parameters:parameters error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            
            NSData *data = error.userInfo[@"com.alamofire.serialization.response.error.data"];
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            MLog(@"---------------------------------------------------------------");
            MLog(@"post url = %@", urlStr);
            MLog(@"parameter = %@", parameter);
            MLog(@"result :%@", str);
            if (fail) {
                
                fail(@"网络请求失败了");
            }
        } else {
            
            
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                int code = [[(NSDictionary *)responseObject objectForKey:@"code"] intValue];
                int status = [[(NSDictionary *)responseObject objectForKey:@"status"] intValue];
                
                if (status == 0) {
                    if (code == 100 || code == 101) {
                        
                        [ShareManager shareInstance].userinfo.islogin = NO;
                        
                        [Tool autoLoginSuccess:^(NSDictionary *success) {
                        } fail:^(NSString *failure) {
                        }];
                        
                    } else {
                        // 刷新登录token
                        
//                        [LoginModel refreshToken];
                    }
                }
            }
            
            if (success) {
                success((NSDictionary *)responseObject);
                
            }
        }
    }];
    
    [dataTask resume];
}


@end
