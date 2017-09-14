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
 * 获取充值记录
 */
+ (void)getCZRecordWithUserId:(NSString *)user_id
                      pageNum:(NSString *)pageNum
                     limitNum:(NSString *)limitNum
                         type:(NSString *)type
                      success:(void (^)(NSDictionary *resultDic))success
                         fail:(void (^)(NSString *description))fail
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (user_id) {
        [parameters setObject:user_id forKey:@"user_id"];
    }
    if (pageNum) {
        [parameters setObject:pageNum forKey:@"pageNum"];
    }
    if (limitNum) {
        [parameters setObject:limitNum forKey:@"limitNum"];
    }
    if (type) {
        [parameters setObject:type forKey:@"type"];
    }
    //拼接:URL_Server+keyURL
    NSString *URLString = [self getURLbyKey:URL_GetCZReord];
    
    [self postHttpWithDic:parameters urlStr:URLString success:success fail:fail];
}

/**
 * 充值
 * type:[weixin/zhifubao]
 */
+ (void)payCZWithUserId:(NSString *)user_id
                  money:(NSString *)money
                typeStr:(NSString *)typeStr
                success:(void (^)(NSDictionary *resultDic))success
                   fail:(void (^)(NSString *description))fail
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (user_id) {
        [parameters setObject:user_id forKey:@"user_id"];
    }
    if (money) {
        [parameters setObject:money forKey:@"money"];
    }
    if (typeStr) {
        [parameters setObject:typeStr forKey:@"type"];
    }
    //拼接:URL_Server+keyURL
    NSString *URLString = [self getURLbyKey:URL_PayCZ];
    
    [self postHttpWithDic:parameters urlStr:URLString success:success fail:fail];
}


/**
 * 获取中信支付参数
 *
 */
+ (void)getSpayInfoWithOrderNo:(NSString *)out_trade_no
                     total_fee:(NSString *)total_fee
              spbill_create_ip:(NSString *)spbill_create_ip
                          body:(NSString *)body
                        detail:(NSString *)detail
                       success:(void (^)(NSDictionary *resultDic))success
                          fail:(void (^)(NSString *description))fail
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (out_trade_no) {
        [parameters setObject:out_trade_no forKey:@"out_trade_no"];
    }
    
    if (total_fee) {
        [parameters setObject:total_fee forKey:@"total_fee"];
    }
    
    if (spbill_create_ip) {
        [parameters setObject:spbill_create_ip forKey:@"spbill_create_ip"];
    }else{
        [parameters setObject:@"" forKey:@"spbill_create_ip"];
    }
    
    if (body) {
        [parameters setObject:body forKey:@"body"];
    }else{
        [parameters setObject:@"" forKey:@"body"];
    }
    
    if (detail) {
        [parameters setObject:detail forKey:@"detail"];
    }else{
        [parameters setObject:@"" forKey:@"detail"];
    }
    
    NSString *user_id = [ShareManager shareInstance].userinfo.id;
    if (user_id) {
        [parameters setObject:user_id forKey:@"user_id"];
    }
    
    //拼接:URL_Server+keyURL
    NSString *URLString = [self getURLbyKey:@"appInterface/zxpayUnifiedorder.jhtml"];
    
    [self postHttpWithDic:parameters urlStr:URLString success:success fail:fail];
}

// 生成预订单
+ (void)getOrderWithGoods:(NSString *)goods_fight_ids
                orderType:(NSString *)order_type            // 订单/充值/欢乐豆
                    count:(int)goodsCount
           thricePurchase:(NSArray *)thricePurchaseArray
                   coupon:(NSString *)ticket_send_id
         costedThriceCoin:(int)costedThriceCoin
               totalPrice:(int)totalPrice
                 cutPrice:(int)cutPrice
          payCrowdfunding:(int)payCrowdfunding
                  success:(void (^)(NSDictionary *data))success
                  failure:(void (^)(NSString *description))failure
{
    //没有配置啥子三倍的东东
    NSString *fights_choices = @"";
    NSString *fights_counts = @"";
    NSString *goods_buy_nums = [NSString stringWithFormat:@"%d", goodsCount];
    NSString *happy_bean_num = [NSString stringWithFormat:@"%d", costedThriceCoin];
    NSString *total_fee = [NSString stringWithFormat:@"%d", cutPrice];
    NSString *all_price = [NSString stringWithFormat:@"%d", totalPrice];
    NSString *pay_dbb_num = [NSString stringWithFormat:@"%d", payCrowdfunding];
    
    
    order_type = order_type?:@"订单";
    goods_fight_ids = goods_fight_ids?:@"";
    ticket_send_id = ticket_send_id?:@"";
    fights_choices = fights_choices?:@"";
    fights_counts = fights_counts?:@"";
    goods_buy_nums = goods_buy_nums?:@"";
    happy_bean_num = happy_bean_num?:@"";
    total_fee = total_fee?:@"";
    all_price = all_price?:@"";
    pay_dbb_num = pay_dbb_num?:@"";
    
    
    if ([goods_fight_ids isKindOfClass:[NSNumber class]]) {
        goods_fight_ids = [NSString stringWithFormat:@"%lld", [goods_fight_ids longLongValue]];
    }
    
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:order_type forKey:@"order_type"];
    [parameters setObject:goods_fight_ids forKey:@"goods_fight_ids"];
    [parameters setObject:ticket_send_id forKey:@"ticket_send_id"];
    [parameters setObject:fights_choices forKey:@"fights_choices"];
    [parameters setObject:fights_counts forKey:@"fights_counts"];
    [parameters setObject:goods_buy_nums forKey:@"goods_buy_nums"];
    [parameters setObject:happy_bean_num forKey:@"happy_bean_num"];
    [parameters setObject:total_fee forKey:@"total_fee"];
    [parameters setObject:all_price forKey:@"all_price"];
    [parameters setObject:pay_dbb_num forKey:@"pay_dbb_num"];
    
    NSString *user_id = [ShareManager shareInstance].userinfo.id;
    if (user_id) {
        [parameters setObject:user_id forKey:@"user_id"];
    }
    
    NSString *path = [self apiWithPathExtension:@"genOrder.jhtml"];
    
    [self postHttpWithDic:parameters urlStr:path success:success fail:failure];
}


/**
 * 修改默认地址
 */
+ (void)changeDefaultAddressWithUserId:(NSString *)user_id
                             addressId:(NSString *)addressId
                               success:(void (^)(NSDictionary *resultDic))success
                                  fail:(void (^)(NSString *description))fail
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (user_id) {
        [parameters setObject:user_id forKey:@"user_id"];
    }
    if (addressId) {
        [parameters setObject:addressId forKey:@"id"];
    }
    //拼接:URL_Server+keyURL
    NSString *URLString = [self getURLbyKey:URL_ChangeDefaultAddress];
    
    [self postHttpWithDic:parameters urlStr:URLString success:success fail:fail];
}

/**
 * 收获地址列表
 */
+ (void)receiveAddressListWithUserId:(NSString *)user_id
                             success:(void (^)(NSDictionary *resultDic))success
                                fail:(void (^)(NSString *description))fail
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (user_id) {
        [parameters setObject:user_id forKey:@"user_id"];
    }
    //拼接:URL_Server+keyURL
    NSString *URLString = [self getURLbyKey:URL_GetAdressList];
    
    [self postHttpWithDic:parameters urlStr:URLString success:success fail:fail];
}


/**
 *添加或修改我的收获地址
 *
 */
+ (void)addAddressWithUserId:(NSString *)user_id
                   addressId:(NSString *)addressId
                    user_tel:(NSString *)user_tel
                   user_name:(NSString *)user_name
                 province_id:(NSString *)province_id
                     city_id:(NSString *)city_id
              detail_address:(NSString *)detail_address
                  is_default:(NSString *)is_default
                     success:(void (^)(NSDictionary *resultDic))success
                        fail:(void (^)(NSString *description))fail
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (user_id) {
        [parameters setObject:user_id forKey:@"user_id"];
    }
    if (addressId) {
        [parameters setObject:addressId forKey:@"id"];
    }else{
        [parameters setObject:@"" forKey:@"id"];
    }
    
    if (user_tel) {
        [parameters setObject:user_tel forKey:@"user_tel"];
    }
    if (user_name) {
        [parameters setObject:user_name forKey:@"user_name"];
    }
    if (province_id) {
        [parameters setObject:province_id forKey:@"province_id"];
    }
    if (city_id) {
        [parameters setObject:city_id forKey:@"city_id"];
    }
    if (detail_address) {
        [parameters setObject:detail_address forKey:@"detail_address"];
    }
    if (is_default) {
        [parameters setObject:is_default forKey:@"is_default"];
    }
    //拼接:URL_Server+keyURL
    NSString *URLString = [self getURLbyKey:URL_AddAddress];
    
    [self postHttpWithDic:parameters urlStr:URLString success:success fail:fail];
}


/**
 * 获取城市列表
 */
+ (void)getCityInfoWithProvinceId:(NSString *)provinceId
                          success:(void (^)(NSDictionary *resultDic))success
                             fail:(void (^)(NSString *description))fail
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (provinceId) {
        [parameters setObject:provinceId forKey:@"provinceId"];
    }
    //拼接:URL_Server+keyURL
    NSString *URLString = [self getURLbyKey:URL_GetCityInfo];
    
    [self postHttpWithDic:parameters urlStr:URLString success:success fail:fail];
}

/**
 * 删除地址
 */
+ (void)deleteAddressWithAddressId:(NSString *)addressId
                           success:(void (^)(NSDictionary *resultDic))success
                              fail:(void (^)(NSString *description))fail
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (addressId) {
        [parameters setObject:addressId forKey:@"id"];
    }
    //拼接:URL_Server+keyURL
    NSString *URLString = [self getURLbyKey:URL_DeleteMyAddress];
    
    [self postHttpWithDic:parameters urlStr:URLString success:success fail:fail];
}


/**
 * 拼接:URL_Server+keyURL
 */
+ (NSString *)apiWithPathExtension:(NSString *)pathExtension{
    
    NSString *str = [NSMutableString stringWithFormat:@"%@appInterface/%@", URL_Server, pathExtension];
    
    if ([ShareManager shareInstance].isInReview == YES) {
        str = [NSMutableString stringWithFormat:@"%@appInterface/%@", URL_ServerTest, pathExtension];
    }
    
    return str;
}


// 直接购买 = 生成与订单 -> 夺宝币欢乐豆均足够可直接购买
+ (void)purchaseGoodsFightID:(NSString *)goods_fight_ids
                       count:(int)goodsCount
              thricePurchase:(NSArray *)thricePurchaseArray
                  isShopCart:(NSString *)is_shop_cart
                      coupon:(NSString *)ticket_send_id
         exchangedThriceCoin:(int)exchangedThriceCoin
                     goodsID:(NSString *)goods_ids
                     buyType:(NSString *)buyType
                     success:(void (^)(NSDictionary *data))success
                     failure:(void (^)(NSString *description))failure
{
    NSString *payType = @"money";
    NSString *fights_choices = @"[ServerProtocol fights_choices:thricePurchaseArray]";
    NSString *fights_counts = @"[ServerProtocol fights_counts:thricePurchaseArray]";
    NSString *goods_buy_nums = [NSString stringWithFormat:@"%d", goodsCount];
    NSString *happy_bean_price = [NSString stringWithFormat:@"%d", exchangedThriceCoin];
    
    
    is_shop_cart = is_shop_cart?:@"n";
    goods_fight_ids = goods_fight_ids?:@"";
    ticket_send_id = ticket_send_id?:@"";
    fights_choices = fights_choices?:@"";
    fights_counts = fights_counts?:@"";
    goods_buy_nums = goods_buy_nums?:@"";
    happy_bean_price = happy_bean_price?:@"";
    goods_ids = goods_ids?:@"";
    buyType = buyType?:@"";
    
    
    if ([goods_fight_ids isKindOfClass:[NSNumber class]]) {
        goods_fight_ids = [NSString stringWithFormat:@"%lld", [goods_fight_ids longLongValue]];
    }
    if ([goods_ids isKindOfClass:[NSNumber class]]) {
        goods_ids = [NSString stringWithFormat:@"%lld", [goods_ids longLongValue]];
    }
    
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:payType forKey:@"payType"];
    [parameters setObject:goods_fight_ids forKey:@"goods_fight_ids"];
    [parameters setObject:is_shop_cart forKey:@"is_shop_cart"];
    [parameters setObject:ticket_send_id forKey:@"ticket_send_id"];
    [parameters setObject:fights_choices forKey:@"fights_choices"];
    [parameters setObject:fights_counts forKey:@"fights_counts"];
    [parameters setObject:goods_buy_nums forKey:@"goods_buy_nums"];
    [parameters setObject:happy_bean_price forKey:@"happy_bean_price"];
    [parameters setObject:goods_ids forKey:@"goods_ids"];
    [parameters setObject:buyType forKey:@"buyType"];
    
    NSString *user_id = [ShareManager shareInstance].userinfo.id;
    if (user_id) {
        [parameters setObject:user_id forKey:@"user_id"];
    }
    
    NSString *path = [self apiWithPathExtension:@"paymentGoodsFight.jhtml"];
    
    [self postWithDictionary:parameters path:path success:success fail:failure];
}
#pragma mark - 底层 post数据请求和图片上传

+ (void)postWithDictionary:(NSMutableDictionary *)parameter
                      path:(NSString *)path
                   success:(void (^)(NSDictionary *resultDictionary))success //成功
                      fail:(void (^)(NSString *description))fail      //失败
{
    [self postHttpWithDic:parameter
                   urlStr:path success:^(NSDictionary *responseObject) {
                       
                       BOOL result = NO;
                       NSString *description = @"";
                       NSDictionary *data = nil;
                       
                       if ([responseObject isKindOfClass:[NSDictionary class]]) {
                           NSDictionary *responseDict = (NSDictionary *)responseObject;
                           
                           int status = [[responseDict objectForKey:@"status"] intValue];
                           description = [responseDict objectForKey:@"desc"];
                           data = [responseDict objectForKey:@"data"];
                           
                           if (status == 0) {
                               result = YES;
                           }
                       }
                       
                       if (result) {
                           success(data);
                       } else {
                           fail(description);
                       }
                       
                   } fail:fail];
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
