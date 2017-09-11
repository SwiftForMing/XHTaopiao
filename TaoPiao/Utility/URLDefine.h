//
//  URLDefine.h
//  Esport
//
//  Created by linqsh on 15/5/12.
//  Copyright (c) 2015年 linqsh. All rights reserved.
//

#import <Foundation/Foundation.h>

/*** Server URL ***/

#if DEBUG
//测试的url
 #define URL_Server @"http://192.168.31.170:9595/TaoQuan/"

#else
 //正式的url
 #define URL_Server @""
#endif

#define URL_Server_Still @""

#define URL_ServerTest @""       // 测试服务器
//分享的url
#define URL_ShareServer @""

//图片地址
#define URL_UpdateImageUrl @"appInterface/uploadImg.jhtml"

//上架接口，判断是否隐藏第三方登录
#define URL_GetIsSJ @"appInterface/getStaticData.jhtml"

#pragma mark  wap地址


#pragma mark  登录注册模块

//获取验证码
#define URL_GetVerificationCode @"appInterface/getCode.jhtml"

//注册
#define URL_Register @"appInterface/addUser.jhtml"

//登陆
#define URL_Login @"appInterface/userLogin.jhtml"

//第三方登陆
#define URL_ThirdLogin @"appInterface/otherAddUser.jhtml"

//找回密码
#define URL_FindPwd @"appInterface/updateUserPassword.jhtml"

//第三方绑定接口
#define URL_BangDing @"appInterface/otherUserFirstLogin.jhtml"

#pragma mark  首页 
//获取基础数据
#define URL_HomeBasics @"appInterface/getIndexData.jhtml"
//获取人气推荐
#define URL_Recommend @"appInterface/getIndexGoodsList.jhtml"


#pragma mark  分类
//获取热门搜索
#define URL_HotSearchData @"appInterface/getHotSearchData.jhtml"
//获取分类数据
#define URL_GoodType @"appInterface/getGoodsTypeList.jhtml"
//获取分类数据
#define URL_GoodsSearchKeyList @"appInterface/getGoodsSearchList.jhtml"

#pragma mark  口袋
//获取优惠劵
#define URL_MyCouponsList @"appInterface/getMyCouponsList.jhtml"
#define URL_AddCoupon @"appInterface/addCoupons.jhtml"

//获取版本号
#define URL_GetVersion @"appInterface/getIosCheckStats.jhtml"

@interface URLDefine : NSObject

@end
