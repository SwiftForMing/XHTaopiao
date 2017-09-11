//
//  HttpHelper.h
//  TaoPiao
//
//  Created by 黎应明 on 2017/9/1.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpHelper : NSObject

+ (instancetype)helper;
/**
*获取公共资源 get请求
*/

+ (void)getHttpWithUrlStr:(NSString *)urlStr
success:(void (^)(NSDictionary *resultDic))success
                     fail:(void (^)(NSString *description))fail;

/**
 *获取服务器接口
 */
+ (NSString *)getURL;
#pragma mark - System

/**
 * 获取版本号
 */
+ (void)getVersion:(void (^)(NSDictionary *resultDic))success
              fail:(void (^)(NSString *description))fail;

#pragma mark - 登录、注册、找回密码

/**
 * 获取验证码
 */
+ (void)getVerificationCodeByMobile:(NSString *)mobile
                               type:(NSString *)type
                            success:(void (^)(NSDictionary *resultDic))success
                               fail:(void (^)(NSString *description))fail;
/**
 * 注册
 */
+ (void)registerByWithMobile:(NSString *)mobile
                    password:(NSString *)password
           recommend_user_id:(NSString *)recommend_user_id
                   auth_code:(NSString *)auth_code
                     success:(void (^)(NSDictionary *resultDic))success
                        fail:(void (^)(NSString *description))fail;
/**
 * 登录
 */
+ (void)loginByWithMobile:(NSString *)mobile
                 password:(NSString *)password
                 jpush_id:(NSString *)jpush_id
                  success:(void (^)(NSDictionary *resultDic))success
                     fail:(void (^)(NSString *description))fail;

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
                           fail:(void (^)(NSString *description))fail;
/**
 * 找回密码
 */
+ (void)findPwdByWithMobile:(NSString *)mobile
                   password:(NSString *)password
                  auth_code:(NSString *)auth_code
                    success:(void (^)(NSDictionary *resultDic))success
                       fail:(void (^)(NSString *description))fail;

/**
 * 第三方绑定
 */
+ (void)bangDingByWithLoginId:(NSString *)app_login_id
                         type:(NSString *)type
                      url_tel:(NSString *)url_tel
                    auth_code:(NSString *)auth_code
            recommend_user_id:(NSString *)recommend_user_id
                      success:(void (^)(NSDictionary *resultDic))success
                         fail:(void (^)(NSString *description))fail;
#pragma mark - 获取分类相关数据

/**
 * 关键字搜索
 */
+(void)getSearchKeyDataWithKeyWord:(NSString *)key
                           success:(void (^)(NSDictionary *resultDic))success
                              fail:(void (^)(NSString *description))fail;
/**
 * ID搜索
 */
+(void)getSearchIDDataWithID:(NSString *)goodID
                     pageNum:(NSString *)page
                    limitNum:(NSString *)limit
                     success:(void (^)(NSDictionary *resultDic))success
                        fail:(void (^)(NSString *description))fail;
#pragma mark - 获取首页相关数据

+(void)getHomeListDataWithPageNum:(NSString *)page
                         limitNum:(NSString *)limit
                          success:(void (^)(NSDictionary *resultDic))success
                             fail:(void (^)(NSString *description))fail;
#pragma mark - 获取口袋相关数据
+(void)getCouponListDataWithUserID:(NSString *)user_id
                           PageNum:(NSString *)page
                          limitNum:(NSString *)limit
                           success:(void (^)(NSDictionary *resultDic))success
                              fail:(void (^)(NSString *description))fail;
+(void)getAddCouponDataWithUserID:(NSString *)user_id
                   Coupons_secret:(NSString *)secret
                          success:(void (^)(NSDictionary *resultDic))success
                             fail:(void (^)(NSString *description))fail;
@end
