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
 #define URL_EntOneServer @"http://192.168.31.170:8585/GetTreasureAppSesame/"
//    #define URL_Server @"http://1612i699s4.iok.la/TaoQuan/"
#else
 //正式的url
 #define URL_Server @"http://192.168.31.170:9595/TaoQuan/"
#endif

#define URL_Server_Still @"http://192.168.31.170:9595/TaoQuan/"

#define URL_ServerTest @""       // 测试服务器
//分享的url
#define URL_ShareServer @""


//图片地址
#define URL_UpdateImageUrl @"appInterface/uploadImg.jhtml"

//上架接口，判断是否隐藏第三方登录
#define URL_GetIsSJ @"appInterface/getStaticData.jhtml"


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

//获取一元购优惠劵
#define URL_EntCouponsList @"appInterface/getAmRechargeList.jhtml"
#define URL_AddCoupon @"appInterface/addCoupons.jhtml"

//获取版本号
#define URL_GetVersion @"appInterface/getAppVersion.jhtml"


//一元购
//获取首页数据
#define URL_GetGoodsInfoList @"appInterface/getIndexGoodsList.jhtml"
//获取往期揭晓数据
#define URL_GetOldDuoBaoData @"appInterface/getHistoryGoodsFightList.jhtml"
//查询是否有某期抽奖
#define URL_QueryPeriod @"appInterface/getGoodsFightIdByPeriod.jhtml"
//加载商品详情
#define URL_LoadGoodsDetailInfo @"appInterface/getGoodsInfoData.jhtml"
//加载抽奖记录
#define URL_LoadDuoBaoRecord @"appInterface/getFightRecordList.jhtml"
//刷新首页数据
#define kUpdateHomePageData @"kUpdateHomePageData"
//获取首页数据
#define URL_GetHomePageData @"appInterface/getIndexData.jhtml"
//抽奖记录
#define URL_GetDuoBaoRecordList @"appInterface/getFightRecordInfoList.jhtml"
//查看他人的抽奖记录
#define URL_GetOtherDuoBaoRecordList @"appInterface/getOtherFightWinRecordList.jhtml"
//中奖记录
#define URL_GetZJRecord @"appInterface/getFightWinRecordList.jhtml"

//晒单列表
#define URL_GetZoneList @"appInterface/getBaskList.jhtml"

//晒单分享详情
#define URL_GetZoneDetail @"appInterface/getBaskContent.jhtml"

//晒单分享回调或者app分享回调
#define URL_GetShaiDanOrAppShareBack @"appInterface/shareReturn.jhtml"

//修改中奖地址
#define URL_ChangeOrderAddress @"appInterface/saveOrderAddress.jhtml"
//选择充值卡兑换方式
#define URL_ChangeCardCollectPrize @"appInterface/saveOrderGetType.jhtml"
#define URL_ChangeCardCollectPrizeDonor @"appInterface/saveDonorOrderGetType.jhtml"
//发布晒单
#define URL_PublishFightBask @"appInterface/publishFightBask.jhtml"
//查看抽奖号码
#define URL_LoadDuoBaoLuckNum @"appInterface/getMoreFightNum.jhtml"
#pragma mark  － 最新揭晓

//获取分类下商品列表
#define URL_GetGoodsListOfType @"appInterface/getGoodsTypeList.jhtml"
//搜索商品
#define URL_SearchGoodsInfo @"appInterface/getGoodsSearchList.jhtml"
//获取最新揭晓
#define URL_GetZXJX @"appInterface/getWillDoGoodsList.jhtml"
@interface URLDefine : NSObject

@end
