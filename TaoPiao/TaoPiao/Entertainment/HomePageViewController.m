//
//  HomePageViewController.m
//  DuoBao
//
//  Created by gthl on 16/2/11.
//  Copyright © 2016年 linqsh. All rights reserved.
//

#import "HomePageViewController.h"
#import "BannerTableViewCell.h"
#import <objc/runtime.h>
#import "SafariViewController.h"
#import "SearchGoodsViewController.h"
#import "HomePageIconTableViewCell.h"
#import "HomePageJXListTableViewCell.h"

#import "GoodsDetailInfoViewController.h"
#import "ClassifyViewController.h"
#import "GoodsListViewController.h"
#import "ShaiDanViewController.h"
#import "SafariViewController.h"
#import "BannerInfo.h"
#import "radioInfo.h"
#import "JieXiaoInfo.h"
#import "GoodsListInfo.h"
#import "GoodsTypeInfo.h"
#import "SelectGoodsNumViewController.h"
#import "PayViewController.h"
#import "GoodsDetailInfo.h"
//#import "InviteViewController.h"
//#import "FreeGoTableViewController.h"
//#import "InviteWebKitViewController.h"
//#import "WebActivityViewController.h"
//#import "ThriceViewController.h"
#import "PurchaseNumberViewController.h"
//#import "PayTableViewController.h"
#import "MallCollectionViewController.h"
#import "newGoodsCell.h"

//#import "FillingTwoViewController.h"
//#import "AllRebackViewController.h"
#import "EntOrderViewController.h"
#import "ProfileTableViewController.h"
#import "JieXiaoViewController.h"
//
#import "EntBuyViewController.h"

//#import <Crashlytics/Crashlytics.h>

@interface HomePageViewController ()<UINavigationControllerDelegate,UISearchBarDelegate,HomePageJXListTableViewCellDelegate, SelectGoodsNumViewControllerDelegate, PayViewControllerDelegate, PurchaseNumberViewControllerDelegate,UIGestureRecognizerDelegate>
{
    UIControl *rqControl;
    UIControl *zxControl;
    UIControl *jdControl;
    UIControl *zxrcControl;
    
    UILabel *rqLine;
    UILabel *zxLine;
    UILabel *jdLine;
    UILabel *zxrcLine;
    
    UILabel *zxLabel;
    UILabel *zxscLabel;
    UILabel *jdLabel;
    UILabel *rqLabel;
    
    UIImageView *jdImage;
    UIImageView *zxrcImage;
    
    HomePageSelectOption slectType;
    
    int pageNum;
    NSInteger tapNum;
    BOOL isBannerTwo;
    
    NSMutableArray *bannerArray;
    NSMutableArray *radioArray;
    NSMutableArray *jiexiaoArray;
    
    GoodsTypeInfo *typeInfo;
    
    NSMutableArray *goodsDataSourceArray;
    NSMutableArray *needLoadArr;
    NSTimer *timer;
    NSMutableArray *totalTimeArray;
    
    BOOL isClickButton;
    BOOL isCreated;
    GoodsDetailInfo *_selectedGoodsInfo;
    GoodsListInfo *_selectedGoodsListInfo;
    
    
}
@property (nonatomic, copy) NSDate *updatedTime;     //点击首页tab，刷新间隔30秒，自动刷新
@property (nonatomic, strong) SearchGoodsViewController *searchViewController;
@property (nonatomic, strong) BannerTableViewCell *bannerCell;
@property (nonatomic, strong) HomePageIconTableViewCell *radioCell;


@property (nonatomic, copy) NSString *bannerListFlag;

@end

@implementation HomePageViewController

- (void)dealloc
{
    if (timer) {
        //关闭定时器
        [timer invalidate];
        timer = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachableNetworkStatusChange object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUpdateHomePageData object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
     [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.title =@"娱乐城";
    [self initParameter];
    [self setTabelViewRefresh];
    [self registerNotif];
    isCreated = false;
    _updatedTime = [NSDate date];
    self.myTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.myTableView.scrollIndicatorInsets = self.myTableView.contentInset;
    
   
}

-(void)back{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES];
    
    self.searchViewController = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Search view controller is not need navigation bar
    if (self.searchViewController == nil) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initParameter
{
    UIButton *backBtn = [[UIButton alloc]initWithFrame:(CGRectMake(0, 0, 30, 30))];
    [backBtn setImage:[UIImage imageNamed:@"new_back"] forState:0];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.backBarButtonItem = backItem;
    pageNum = 1;
    tapNum = 0;
    slectType = SelectOption_RQ;
    
    bannerArray = [NSMutableArray array];
    radioArray = [NSMutableArray array];
    jiexiaoArray = [NSMutableArray array];
    goodsDataSourceArray= [NSMutableArray array];
    needLoadArr = [NSMutableArray array];
    
    
}

- (void)setRightBarButtonItemSearch
{
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(leftBarButtonItemAction:)];
    button.tintColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = button;
}

- (void)updateSelectStatue
{
    rqLine.hidden = YES;
    zxLine.hidden = YES;
    jdLine.hidden = YES;
    zxrcLine.hidden = YES;
    
    zxLabel.textColor = [UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1];
    zxscLabel.textColor = [UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1];
    jdLabel.textColor = [UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1];
    rqLabel.textColor = [UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1];
    
    jdImage.image = [UIImage imageNamed:@"cont_updown"];
    zxrcImage.image = [UIImage imageNamed:@"cont_updown"];
    
    switch (slectType) {
        case SelectOption_RQ:
        {
            rqLine.hidden = NO;
            rqLabel.textColor = [UIColor colorWithRed:235.0/255.0 green:48.0/255.0 blue:48.0/255.0 alpha:1];
        }
            break;
        case SelectOption_ZX1:
        {
            zxLine.hidden = NO;
            zxLabel.textColor = [UIColor colorWithRed:235.0/255.0 green:48.0/255.0 blue:48.0/255.0 alpha:1];
        }
            break;
        case SelectOption_JD:
        {
            jdLine.hidden = NO;
            jdLabel.textColor = [UIColor colorWithRed:235.0/255.0 green:48.0/255.0 blue:48.0/255.0 alpha:1];
            jdImage.image = [UIImage imageNamed:@"cont_updown_2"];
            
        }
            break;
        case SelectOption_DuplicateJD:
        {
            jdLine.hidden = NO;
            jdLabel.textColor = [UIColor colorWithRed:235.0/255.0 green:48.0/255.0 blue:48.0/255.0 alpha:1];
            jdImage.image = [UIImage imageNamed:@"cont_updown_1"];
        }
            break;
        case SelectOption_ZXRC:
        {
            zxrcLine.hidden = NO;
            zxscLabel.textColor = [UIColor colorWithRed:235.0/255.0 green:48.0/255.0 blue:48.0/255.0 alpha:1];
            zxrcImage.image = [UIImage imageNamed:@"cont_updown_2"];
            
        }
            break;
        case SelectOption_DuplicateZXRC:
        {
            zxrcLine.hidden = NO;
            zxscLabel.textColor = [UIColor colorWithRed:235.0/255.0 green:48.0/255.0 blue:48.0/255.0 alpha:1];
            zxrcImage.image = [UIImage imageNamed:@"cont_updown_1"];
        }
            break;
            
        default:
            break;
    }
    
}

- (void)updateTableOffset
{
    CGFloat offset = 0;
    if (jiexiaoArray.count < 1) {
        offset = FullScreen.size.width*0.45+132;
    }else{
        offset = FullScreen.size.width*0.45+154+132;
    }
    if (offset + _myTableView.frame.size.height <= _myTableView.contentSize.height) {
        [_myTableView setMj_offsetY:offset];
    }else{
        [_myTableView setMj_offsetY:_myTableView.contentSize.height-_myTableView.frame.size.height];
    }
}


#pragma mark - notif Action
- (void)registerNotif
{
    /**
     *  监听网络状态变化
     */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkNetworkStatus:)
                                                 name:kReachableNetworkStatusChange
                                               object:nil];
    
    //刷新首页数据
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(updateHomePageData)
                                                name:kUpdateHomePageData
                                              object:nil];
}

//网络状态捕捉
- (void)checkNetworkStatus:(NSNotification *)notif
{
    NSDictionary *userInfo = [notif userInfo];
    if(userInfo)
    {
        //是否屏蔽支付接口
        [Tool httpGetIsShowThridView];
        [_myTableView.mj_header beginRefreshing];
    }
}

- (void)updateHomePageData
{
    //是否屏蔽支付接口
    [Tool httpGetIsShowThridView];
    [self httpShowData];
    pageNum = 1;
    [self httpGetGoodsList];
    
}

#pragma mark - Action

- (void)leftBarButtonItemAction:(id)sender
{
    [self clickSearchButtonAction:nil];
}

- (IBAction)clickSearchButtonAction:(id)sender
{
    SearchGoodsViewController *vc = [[SearchGoodsViewController alloc] initWithNibName:@"SearchGoodsViewController" bundle:nil];
    self.searchViewController = vc;
    [self.navigationController pushViewController:vc animated:YES];
}

//响应单击方法－跳转广告页面
- (void)tapBanner:(UITapGestureRecognizer *) tap
{
    
    BannerTableViewCell *cell = objc_getAssociatedObject(tap, "cell");
    if (cell.pageController.currentPage >= bannerArray.count ) {
        return;
    }
    BannerInfo *info = [bannerArray objectAtIndex:cell.pageController.currentPage];
    
    NSLog(@"content_txt %@",info.content_txt);
    NSString *str = [NSString stringWithFormat:@"[%@]_banner",info.title];
    
    
    // 跳转邀请好友
    if ([info.id isEqualToString:@"87"]) {
        NSString *path = info.url;
        
//        InviteWebKitViewController *vc = [[InviteWebKitViewController alloc] initWithAddress:path userScript:nil];
//        vc.title = @"邀请好友";
//
//        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
#if DEBUG
    // 跳乐购抽奖
    if ([info.id isEqualToString:@"113"]) {
        //#ifdef lgdb_prefix_pch
        //        NSURL *url = [NSURL URLWithString:@"zhimalegou://"];
        //        [[UIApplication sharedApplication] openURL:url];
        //        return;
        //#endif
        
#ifdef DuoBao_Prefix_pch
        NSURL *url = [NSURL URLWithString:@"legouduobao://"];
        //        if ([[UIApplication sharedApplication] canOpenURL:url]) {
        //            [[UIApplication sharedApplication] openURL:url];
        //            return;
        //        }
        if ([[UIApplication sharedApplication] openURL:url]) {
            return;
        }
#endif
        
    }
#endif
    
    
    // 跳转逢68
    if ([info.id isEqualToString:@"111"] || [info.id isEqualToString:@"112"]) {
        NSString *path = info.url;
        
        
        
//        WebActivityViewController *vc = [[WebActivityViewController alloc] initWithAddress:path];
//        vc.title = info.title;
//        NSLog(@"title %@",info.title);
//        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    // 三赔
    if ([info.id isEqualToString:@"115"] ) {
        
//
//        ThriceViewController *vc = [[ThriceViewController alloc] initWithTableViewStyleGrouped];
//        [self.navigationController pushViewController:vc animated:YES];
        
        return;
    }
    
    if ([info.id isEqualToString:@"120"] ) {
       
        
//        FillingTwoViewController *vc = [[FillingTwoViewController alloc]initWithTableViewStyleGrouped];
//        [self.navigationController pushViewController:vc animated:YES];
        
        return;
    }
    
    if ([info.id isEqualToString:@"122"] ) {
        
//        AllRebackViewController *vc = [[AllRebackViewController alloc]initWithTableViewStyleGrouped];
//        [self.navigationController pushViewController:vc animated:true];
        return;
    }
    
    if ([info.id isEqualToString:@"121"] ) {
        
//        CompensateViewController *vc = [[CompensateViewController alloc]initWithTableViewStyleGrouped];
//        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    if ([info.id isEqualToString:@"123"] ) {
        
        
//        LuckyViewController *vc = [[LuckyViewController alloc]init];
//        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    if([info.is_jump isEqualToString:@"y"])
    {
        if (!([info.image_url length]>0||[info.content_txt length]>0)) {
            SafariViewController *vc =[[SafariViewController alloc] initWithNibName:@"SafariViewController" bundle:nil];
            vc.title = info.title;
            vc.urlStr = info.url;
            [self.navigationController pushViewController:vc animated:YES];
        }else{
//            AdvertisementViewController *vc =[AdvertisementViewController alloc];
//            vc.image_url = info.image_url;
//            vc.content_txt = info.content_txt;
//            vc.h5UrlStr = info.url;
//            vc.myTitle = info.title;
//
//            [self.navigationController pushViewController:vc animated:true];
        }
    }
    
    
    
    // 0元购
    if ([info.id isEqualToString:@"105"]) {
        
        if (![Tool islogin]) {
            [Tool loginWithAnimated:YES viewController:nil];
            return;
        }
        
//        FreeGoTableViewController *vc = [[FreeGoTableViewController alloc]initWithNibName:@"FreeGoTableViewController" bundle:nil];
//        //谷歌分析0元购点击进入
//
//        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (void)clickRQButtonAction:(id)sender
{

    //谷歌分析人气点击
 
    isClickButton = YES;
    slectType = SelectOption_RQ;
    [self updateSelectStatue];
    pageNum = 1;
    [self httpGetGoodsList];
//    [self updateTableOffset];
    
}
- (void)clickZXButtonAction:(id)sender
{
    
    isClickButton = YES;
    slectType = SelectOption_ZX1;
    [self updateSelectStatue];
    pageNum = 1;
    [self httpGetGoodsList];
//    [self updateTableOffset];
}
- (void)clickJDButtonAction:(id)sender
{
    
    
    isClickButton = YES;
    if (slectType == SelectOption_JD) {
        slectType = SelectOption_DuplicateJD;
        
    }else{
        slectType = SelectOption_JD;
    }
    [self updateSelectStatue];
    pageNum = 1;
    [self httpGetGoodsList];
//    [self updateTableOffset];
    
}
- (void)clickZXRCButtonAction:(id)sender
{
    
    isClickButton = YES;
    if (slectType == SelectOption_ZXRC) {
        slectType = SelectOption_DuplicateZXRC;
        
    }else{
        slectType = SelectOption_ZXRC;
        
    }
    
    [self updateSelectStatue];
    pageNum = 1;
    [self httpGetGoodsList];
//    [self updateTableOffset];
}

- (void)clickIconButtonAction:(id)sender
{
    UIControl *control = (UIControl *)sender;
    switch (control.tag) {
        case 100:
        {
            EntBuyViewController *vc = [[EntBuyViewController alloc]initWithTableViewStyle:1];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 200:
        {
            
            JieXiaoViewController *jieXiaoVC = [[JieXiaoViewController alloc] initWithNibName:@"JieXiaoViewController" bundle:nil];
            [self.navigationController pushViewController:jieXiaoVC animated:YES];
        }
            break;
        case 300:
        {
           
            ShaiDanViewController *vc = [[ShaiDanViewController alloc]initWithNibName:@"ShaiDanViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        case 400:
        {
            if (![Tool islogin]) {
                [Tool loginWithAnimated:YES viewController:nil];
                return;
            }
            ProfileTableViewController * userCenterVC = [[ProfileTableViewController alloc] initWithNibName:@"ProfileTableViewController" bundle:nil];
            [self.navigationController pushViewController:userCenterVC animated:YES];
            
            break;
        }
            
        default: break;
    }
    
    
}

- (void)clickMoreButtonAction:(id)sender
{
    [self.tabBarController setSelectedIndex:1];
}

#pragma mark - http

- (void)httpShowData
{
   
    __weak HomePageViewController *weakSelf = self;
    [HttpHelper getEntHttpWithUrlStr:URL_GetHomePageData
                      success:^(NSDictionary *resultDic){
                          if ([[resultDic objectForKey:@"status"] integerValue] == 0) {
                              [weakSelf handleloadResult:resultDic];
                          }
                          //                        else
                          //                        {
                          //                            [Tool showPromptContent:[resultDic objectForKey:@"desc"] onView:self.view];
                          //                        }
                      }fail:^(NSString *decretion){
                          [Tool showPromptContent:@"网络出错了" onView:weakSelf.view];
                      }];
}

- (void)handleloadResult:(NSDictionary *)resultDic
{
    NSDictionary *dic = [resultDic objectForKey:@"data"];
    NSLog(@"dic %@",dic);
    //最新揭晓
    NSArray *array2 = [dic objectForKey:@"willKnowFightList"];
    if (array2 && array2.count > 0) {
        if (jiexiaoArray.count > 0) {
            [jiexiaoArray removeAllObjects];
        }
        for (NSDictionary *dic in array2)
        {
            JieXiaoInfo *info = [dic objectByClass:[JieXiaoInfo class]];
            [jiexiaoArray addObject:info];
        }
        [self startCountDown];
    }else{
        if (timer) {
            [timer setFireDate:[NSDate distantFuture]];
        }
    }
    
    NSArray *array = [dic objectForKey:@"advertisementList"];
    if (array && array.count > 0) {
        if (bannerArray.count > 0) {
            [bannerArray removeAllObjects];
        }
        for (NSDictionary *dic in array)
        {
            
            BannerInfo *info = [dic objectByClass:[BannerInfo class]];
            [bannerArray addObject:info];
        }
        
        if (bannerArray.count == 2) {
            isBannerTwo = YES;
            [bannerArray addObject:[bannerArray objectAtIndex:0]];
            [bannerArray addObject:[bannerArray objectAtIndex:1]];
        }
    }
    
    // banner有变化，更新界面
    [self bannerListDidChange:bannerArray];
    
    
    //广播
    NSArray *array1 = [dic objectForKey:@"radiolist"];
    if (array1 && array1.count > 0) {
        if (radioArray.count > 0) {
            [radioArray removeAllObjects];
        }
        for (NSDictionary *dic in array1)
        {
            RadioInfo *info = [dic objectByClass:[RadioInfo class]];
            [radioArray addObject:info];
        }
    }
    
    NSArray *array3 = [dic objectForKey:@"goodsTypeList"];
    if (array3 && array3.count > 0) {
        typeInfo = [[array3 objectAtIndex:0] objectByClass:[GoodsTypeInfo class]];
        
    }
    
    
    [_myTableView reloadData];
    
    
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [_radioCell.bannerView reloadData];
    });
}

- (void)httpGetGoodsList
{
    NSString *typeStr = nil;
    NSString *descStr = nil;
    
    /*
     * order_by_name: 排序字段名称[now_people(人气),create_time(最新),progress(进度),need_people(总需人次)
     * order_by_rule: 排序规则[desc,asc]
     */
    switch (slectType) {
        case SelectOption_RQ:
        {
            typeStr = @"now_people";
            descStr = @"desc";
        }
            break;
        case SelectOption_ZX1:
        {
            typeStr = @"create_time";
            descStr = @"desc";
        }
            break;
        case SelectOption_JD:
        {
            typeStr = @"progress";
            descStr = @"desc";
        }
            break;
        case SelectOption_DuplicateJD:
        {
            typeStr = @"progress";
            descStr = @"asc";
        }
            break;
        case SelectOption_ZXRC:
        {
            typeStr = @"need_people";
            descStr = @"desc";
            
        }
            break;
        case SelectOption_DuplicateZXRC:
        {
            typeStr = @"need_people";
            descStr = @"asc";
        }
            break;
            
        default:
            break;
    }
    
    __weak HomePageViewController *weakSelf = self;
    [HttpHelper getGoodsListWithOrder_by_name:typeStr
                            order_by_rule:descStr
                                  pageNum:[NSString stringWithFormat:@"%d",pageNum]
                                 limitNum:@"0"
                                  success:^(NSDictionary *resultDic){
                                      [weakSelf hideRefresh];
                                      if ([[resultDic objectForKey:@"status"] integerValue] == 0) {
                                          [weakSelf handleGetGoodsListLoadResult:resultDic];
                                      }
                                     
                                  }fail:^(NSString *decretion){
                                      [weakSelf hideRefresh];
                                      [Tool showPromptContent:decretion onView:weakSelf.view];
                                  }];
}

- (void)handleGetGoodsListLoadResult:(NSDictionary *)resultDic
{
    if (goodsDataSourceArray.count > 0 && pageNum == 1) {
        [goodsDataSourceArray removeAllObjects];
        
    }
    
    NSArray *resourceArray = [[resultDic objectForKey:@"data"] objectForKey:@"goodsList"];
    
    
    
    if (resourceArray && resourceArray.count > 0 )
    {
        for (NSDictionary *dic in resourceArray)
        {
            GoodsListInfo *info = [dic objectByClass:[GoodsListInfo class]];
            [goodsDataSourceArray addObject:info];
            
            
            
        }
        
        if (resourceArray.count < 100) {
            [_myTableView.mj_footer endRefreshingWithNoMoreData];
        }else{
            [_myTableView.mj_footer resetNoMoreData];
        }
        
        pageNum++;
    }
    
    
    
    //刷新
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:3];
    [_myTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    
    
    if (isClickButton) {
        [self updateTableOffset];
        isClickButton = NO;
    }
}

- (void)httpAddGoodsToShopCartWithGoodsID:(NSString *)goodIds buyNum:(NSString *)buyNum
{
//    HttpHelper *helper = [HttpHelper helper];
//    __weak HomePageViewController *weakSelf = self;
//    [helper addGoodsForShopCartWithUserId:[ShareManager shareInstance].userinfo.id
//                                goods_ids:goodIds
//                           goods_buy_nums:buyNum
//                                  success:^(NSDictionary *resultDic){
//
//                                      if ([[resultDic objectForKey:@"status"] integerValue] == 0) {
//                                          [weakSelf handleloadAddGoodsToShopCartResult:resultDic buyNum:buyNum];
//                                      }else
//                                      {
//                                          [Tool showPromptContent:[resultDic objectForKey:@"desc"] onView:weakSelf.view];
//                                      }
//                                  }fail:^(NSString *decretion){
//                                      [Tool showPromptContent:@"网络出错了" onView:weakSelf.view];
//                                  }];
}

- (void)handleloadAddGoodsToShopCartResult:(NSDictionary *)resultDic buyNum:(NSString *)buyNum
{
    [Tool getUserInfo];
    [Tool showPromptContent:[resultDic objectForKey:@"desc"] onView:self.view];
}

#pragma mark - 倒计时

//倒计时
- (void)startCountDown
{
    if (timer) {
        [timer setFireDate:[NSDate distantFuture]];
    }
    
    if (totalTimeArray.count > 0 && totalTimeArray) {
        [totalTimeArray removeAllObjects];
        for (int i = 0; i < jiexiaoArray.count; i++) {
            [totalTimeArray addObject:@"n"];
        }
    }else{
        if (!totalTimeArray) {
            totalTimeArray = [NSMutableArray array];
            for (int i = 0; i < jiexiaoArray.count; i++) {
                [totalTimeArray addObject:@"n"];
            }
        }
    }
    BOOL isShow = NO;
    for (int i = 0; i < jiexiaoArray.count; i++) {
        JieXiaoInfo *info = [jiexiaoArray objectAtIndex:i];
        if ([info.status isEqualToString:@"倒计时"] && [info.is_show_daojishi isEqualToString:@"y"])
        {
            [totalTimeArray replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%lld",[info.daojishi_time longLongValue]]];
            isShow = YES;
        }
    }
    
    if (isShow) {
        if (timer) {
            [timer setFireDate:[NSDate distantPast]];
        }
        [self handleTimer];
    }
    
}

- (void)handleTimer
{
    if (!timer)
    {
        timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                 target:self
                                               selector:@selector(handleTimer)
                                               userInfo:nil
                                                repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:UITrackingRunLoopMode];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:2];
    HomePageJXListTableViewCell *cell = (HomePageJXListTableViewCell *)[_myTableView cellForRowAtIndexPath:indexPath];
    
    for (int i = 0; i < totalTimeArray.count; i++) {
        
        NSString *timeStr = [totalTimeArray objectAtIndex:i];
        if ([timeStr isEqualToString:@"n"]) {
            continue;
        }
        long long timeValue = [timeStr longLongValue];
        timeValue = timeValue-10;
        if (timeValue < 0) {
            timeValue = 0;
            if (timer) {
                [timer setFireDate:[NSDate distantFuture]];
            }
            [cell updateTimeLabelUI:@"0" index:i];
            [totalTimeArray replaceObjectAtIndex:i withObject:@"0"];
            [self httpShowData];
            break;
        }else{
            [cell updateTimeLabelUI:timeStr index:i];
            [totalTimeArray replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%lld",timeValue]];
        }
    }
}


#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2) {
        if (jiexiaoArray.count < 1) {
            return 0;
        }else{
            return 1;
        }
    }
    //我的添加
    if (section == 3){
        
        return goodsDataSourceArray.count/2;
        
    }
    
    return 1;
}

//设置cell的行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return FullScreen.size.width*0.45;
            break;
        case 1:
            return 132;
            break;
        case 2:
        {
            //只创建一个cell用作测量高度
            static HomePageJXListTableViewCell *cell = nil;
            if (!cell)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomePageJXListTableViewCell" owner:nil options:nil];
                cell = [nib objectAtIndex:0];
                [cell initImageCollectView];
                cell.collectView.delegate = cell;
                cell.collectView.dataSource = cell;
            }
            
            [self loadCellContent:cell indexPath:indexPath];
            return [self getCellHeight:cell];
        }
            break;
        default:
        {
            
            //只创建一个cell用作测量高度
            /*
             static GoodsViewTableViewCell *cell = nil;
             if (!cell)
             {
             NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GoodsViewTableViewCell" owner:nil options:nil];
             cell = [nib objectAtIndex:0];
             [cell initImageCollectView];
             cell.collectView.delegate = cell;
             cell.collectView.dataSource = cell;
             }
             
             [self loadGoodsCellContent:cell indexPath:indexPath];
             return [self getGoodsCellHeight:cell];
             */
            return 204;
        }
            break;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section > 2)
    {
        return 40;
        
    }else{
        
        return 0;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (section < 3) {
        
        return nil;
    }
    
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width , 40);
    UIView *bgView = [[UIView alloc]initWithFrame:frame];
    bgView.backgroundColor = [UIColor whiteColor];
    
    UIView *lineview = [[UIView alloc]initWithFrame:CGRectMake(0, 39, FullScreen.size.width, 1)];
    lineview.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1];
    [bgView addSubview:lineview];
    
    //人气
    rqControl = [[UIControl alloc]initWithFrame:CGRectMake(0, 0, FullScreen.size.width/4, frame.size.height)];
    [rqControl addTarget:self action:@selector(clickRQButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    rqLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, rqControl.width, 20)];
    rqLabel.text = @"人气";
    rqLabel.center = rqControl.center;
    rqLabel.textColor = [UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1];
    rqLabel.textAlignment = NSTextAlignmentCenter;
    rqLabel.font = [UIFont systemFontOfSize:12];
    [rqControl addSubview:rqLabel];
    
    rqLine = [[UILabel alloc]initWithFrame:CGRectMake(8, rqControl.height-3, rqControl.width-16, 3)];
    rqLine.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:48.0/255.0 blue:48.0/255.0 alpha:1];
    [rqControl addSubview:rqLine];
    [bgView addSubview:rqControl];
    
    //最新
    zxControl = [[UIControl alloc]initWithFrame:CGRectMake(FullScreen.size.width/4, 0, FullScreen.size.width/4, frame.size.height)];
    [zxControl addTarget:self action:@selector(clickZXButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    zxLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 35, 20)];
    zxLabel.text = @"最新";
    zxLabel.center = CGPointMake(zxControl.width/2, zxControl.height/2);
    zxLabel.textColor = [UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1];
    zxLabel.textAlignment = NSTextAlignmentCenter;
    zxLabel.font = [UIFont systemFontOfSize:12];
    [zxControl addSubview:zxLabel];
    zxLine = [[UILabel alloc]initWithFrame:CGRectMake(8, rqControl.height-3, rqControl.width-16, 3)];
    zxLine.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:48.0/255.0 blue:48.0/255.0 alpha:1];
    [zxControl addSubview:zxLine];
    [bgView addSubview:zxControl];
    
    //进度
    jdControl = [[UIControl alloc]initWithFrame:CGRectMake(FullScreen.size.width/4*2, 0, FullScreen.size.width/4, frame.size.height)];
    [jdControl addTarget:self action:@selector(clickJDButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    jdLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 32, 20)];
    jdLabel.text = @"进度";
    jdLabel.center = CGPointMake(jdControl.width/2-2, jdControl.height/2);
    jdLabel.textColor = [UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1];
    jdLabel.textAlignment = NSTextAlignmentCenter;
    jdLabel.font = [UIFont systemFontOfSize:12];
    [jdControl addSubview:jdLabel];
    jdImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cont_updown"]];
    jdImage.frame = CGRectMake(0, 0, 8, 12);
    jdImage.center = CGPointMake(rqControl.center.x + 20, rqControl.center.y);
    [jdControl addSubview:jdImage];
    jdLine = [[UILabel alloc]initWithFrame:CGRectMake(8, rqControl.height-3, rqControl.width-16, 3)];
    jdLine.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:48.0/255.0 blue:48.0/255.0 alpha:1];
    [jdControl addSubview:jdLine];
    [bgView addSubview:jdControl];
    
    //总需人次
    zxrcControl = [[UIControl alloc]initWithFrame:CGRectMake(FullScreen.size.width/4*3, 0, FullScreen.size.width/4, frame.size.height)];
    [zxrcControl addTarget:self action:@selector(clickZXRCButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    zxscLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 20)];
    zxscLabel.text = @"总需人次";
    zxscLabel.textColor = [UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1];
    zxscLabel.center = CGPointMake(zxrcControl.width/2-5, zxrcControl.height/2);
    zxscLabel.textAlignment = NSTextAlignmentCenter;
    zxscLabel.font = [UIFont systemFontOfSize:12];
    [zxrcControl addSubview:zxscLabel];
    zxrcImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cont_updown"]];
    zxrcImage.frame = CGRectMake(0, 0, 8, 12);
    zxrcImage.center = CGPointMake(zxrcControl.width/2+29, zxrcControl.height/2);
    [zxrcControl addSubview:zxrcImage];
    zxrcLine = [[UILabel alloc]initWithFrame:CGRectMake(8, rqControl.height-3, rqControl.width-16, 3)];
    zxrcLine.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:48.0/255.0 blue:48.0/255.0 alpha:1];
    [zxrcControl addSubview:zxrcLine];
    [bgView addSubview:zxrcControl];
    
    [self updateSelectStatue];
    
    return bgView;
}


//创建并显示每行的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            BannerTableViewCell *cell = nil;
            cell = [tableView dequeueReusableCellWithIdentifier:@"BannerTableViewCell"];
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BannerTableViewCell" owner:nil options:nil];
                cell = [nib objectAtIndex:0];
                cell.bannerView.delegate = self;
                cell.bannerView.dataSource = self;
                cell.bannerView.autoScrollAble = YES;
                cell.bannerView.tag = 100;
                cell.bannerView.direction = CycleDirectionLandscape;
                
                objc_setAssociatedObject(cell.bannerView, "cell", cell, OBJC_ASSOCIATION_ASSIGN);
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBanner:)];
                tap.numberOfTapsRequired = 1;
                objc_setAssociatedObject(tap, "cell", cell, OBJC_ASSOCIATION_ASSIGN);
                [cell.bannerView addGestureRecognizer:tap];
                
                _bannerCell = cell;
            }
            //设点点击选择的颜色(无)
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            
        }
            break;
        case 1:
        {
            
            HomePageIconTableViewCell *cell = nil;
            cell = [tableView dequeueReusableCellWithIdentifier:@"HomePageIconTableViewCell"];
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomePageIconTableViewCell" owner:nil options:nil];
                cell = [nib objectAtIndex:0];
                
                cell.bannerView.delegate = self;
                cell.bannerView.dataSource = self;
                cell.bannerView.autoScrollAble = YES;
                cell.bannerView.tag = 200;
                cell.bannerView.direction = CycleDirectionPortait;
                objc_setAssociatedObject(cell.bannerView, "cell", cell, OBJC_ASSOCIATION_ASSIGN);
                _radioCell = cell;
            }
            
            cell.iconWidth.constant = (FullScreen.size.width -24-24)/4;
            cell.flControl.tag = 100;
            [cell.flControl addTarget:self action:@selector(clickIconButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.syControl.tag = 200;
            [cell.syControl addTarget:self action:@selector(clickIconButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.typeIcon.layer.masksToBounds =YES;
            cell.typeIcon.layer.cornerRadius = cell.typeIcon.frame.size.height/2;
            cell.sdControl.tag = 300;
            [cell.sdControl addTarget:self action:@selector(clickIconButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.cjwtControl.tag = 400;
            [cell.cjwtControl addTarget:self action:@selector(clickIconButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            
            //设点点击选择的颜色(无)
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
            break;
        case 2:
        {
            HomePageJXListTableViewCell *cell = nil;
            cell = [tableView dequeueReusableCellWithIdentifier:@"HomePageJXListTableViewCell"];
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomePageJXListTableViewCell" owner:nil options:nil];
                cell = [nib objectAtIndex:0];
                
                [cell initImageCollectView];
                cell.delegate = self;
                cell.collectView.delegate = cell;
                cell.collectView.dataSource = cell;
                
            }
            [cell.moreButton addTarget:self action:@selector(clickMoreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [self loadCellContent:cell indexPath:indexPath];
            //设点点击选择的颜色(无)
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //            cell.collectView.scrollEnabled = NO;
            //            tableView.scrollEnabled = NO;
            return cell;
        }
            break;
        default:
        {
            newGoodsCell *cell = nil;
            cell = [tableView dequeueReusableCellWithIdentifier:@"newGoodsCell"];
            
            if (cell==nil){
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"newGoodsCell" owner:nil options:nil];
                cell = [nib objectAtIndex:0];
            }
            
            GoodsListInfo *leftInfo = [goodsDataSourceArray objectAtIndex:2*indexPath.row];
            // 单击的 Recognizer
            UITapGestureRecognizer* singleRecognizer;
            singleRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(SingleTap:)];
            //点击的次数
            singleRecognizer.numberOfTapsRequired = 1; // 单击
            
            //给self.view添加一个手势监测；
            [cell.leftView addGestureRecognizer:singleRecognizer];
            cell.leftView.tag = 2*indexPath.row;
            cell.lefeNewProcess.progress = [leftInfo.progress doubleValue]/100.0;
            
            [cell.leftPhotoImage sd_setImageWithURL:[NSURL URLWithString:leftInfo.good_header] placeholderImage:PublicImage(@"defaultImage")];
            cell.leftTitleLabel.text = leftInfo.good_name;
            cell.leftProcessNumLabel.text = [NSString stringWithFormat:@"%@％",leftInfo.progress];
            cell.leftAddButton.tag = 2*indexPath.row;
            
            [cell.leftAddButton addTarget:self action:@selector(clickAddShopCarButtonWithBtn:) forControlEvents:UIControlEventTouchUpInside];
            cell.leftPriceButton.hidden = YES;
            
            //cell.leftPriceButton.frame = CGRectMake(10 * UIAdapteRate, 0, 28* UIAdapteRate, 31 * UIAdapteRate);
            
            
            if (leftInfo.good_single_price.intValue == 10) {
                cell.leftPriceButton.hidden = NO;
                [cell.leftPriceButton setBackgroundImage:[UIImage imageNamed:@"new10Icon"] forState:UIControlStateNormal];
                [cell.leftPriceButton setBackgroundImage:[UIImage imageNamed:@"new10Icon"] forState:UIControlStateSelected];
                float rate = 0.8 * UIAdapteRate;
                cell.leftPriceButton.frame = CGRectMake(8 * UIAdapteRate, 0, 27 * rate, 33.5 * rate);
            }
            
            NSString *str = leftInfo.part_sanpei;
            if ([str isEqualToString:@"y"]) {
                cell.leftPriceButton.hidden = NO;
                [cell.leftPriceButton setBackgroundImage:[UIImage imageNamed:@"icon_thrice"] forState:UIControlStateNormal];
                [cell.leftPriceButton setBackgroundImage:[UIImage imageNamed:@"icon_thrice"] forState:UIControlStateSelected];
                float rate = 0.8 * UIAdapteRate;
                cell.leftPriceButton.frame = CGRectMake(8 * UIAdapteRate, 4 * UIAdapteRate, 61 * rate, 37 * rate);
            }
            
            
            GoodsListInfo *rightInfo = [goodsDataSourceArray objectAtIndex:2*indexPath.row+1];
            // 单击的 Recognizer
            UITapGestureRecognizer* rightSingleRecognizer;
            
            rightSingleRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(SingleTap:)];
            //点击的次数
            rightSingleRecognizer.numberOfTapsRequired = 1; // 单击
            
            //给self.view添加一个手势监测；
            [cell.rightView addGestureRecognizer:rightSingleRecognizer];
            cell.rightView.tag = 2*indexPath.row+1;
            cell.rightNewProcess.progress = [rightInfo.progress doubleValue]/100.0;
            
            [cell.rightPhotoImage sd_setImageWithURL:[NSURL URLWithString:rightInfo.good_header] placeholderImage:PublicImage(@"defaultImage")];
            
            cell.rightTitleLabel.text = rightInfo.good_name;
            cell.rightProcessNumLabel.text = [NSString stringWithFormat:@"%@％",rightInfo.progress];
            
            cell.rightAddButton.tag = 2*indexPath.row+1;
            
            [cell.rightAddButton addTarget:self action:@selector(clickAddShopCarButtonWithBtn:) forControlEvents:UIControlEventTouchUpInside];
            cell.rightPriceButton.hidden = YES;
            
            //cell.rightPriceButton.frame = CGRectMake(10 * UIAdapteRate+self.view.frame.size.width, 0, 28* UIAdapteRate, 31 * UIAdapteRate);
            
            if (rightInfo.good_single_price.intValue == 10) {
                cell.rightPriceButton.hidden = NO;
                [cell.rightPriceButton setBackgroundImage:[UIImage imageNamed:@"new10Icon"] forState:UIControlStateNormal];
                [cell.rightPriceButton setBackgroundImage:[UIImage imageNamed:@"new10Icon"] forState:UIControlStateSelected];
                float rate = 0.8 * UIAdapteRate;
                cell.rightPriceButton.frame = CGRectMake(8 * UIAdapteRate+self.view.frame.size.width/2, 0, 27 * rate, 33.5 * rate);
            }
            
            
            NSString *rightStr = rightInfo.part_sanpei;
            if ([rightStr isEqualToString:@"y"]) {
                cell.rightPriceButton.hidden = NO;
                [cell.rightPriceButton setBackgroundImage:[UIImage imageNamed:@"icon_thrice"] forState:UIControlStateNormal];
                [cell.rightPriceButton setBackgroundImage:[UIImage imageNamed:@"icon_thrice"] forState:UIControlStateSelected];
                float rate = 0.8 * UIAdapteRate;
                cell.rightPriceButton.frame = CGRectMake(8 * UIAdapteRate+self.view.frame.size.width/2, 4 * UIAdapteRate, 61 * rate, 37 * rate);
            }
            //设点点击选择的颜色(无)
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            
        }
            break;
    }
    return nil;
}

-(void)SingleTap:(UITapGestureRecognizer*)recognizer
{
    //处理单击操作
  
    GoodsListInfo *info = goodsDataSourceArray[recognizer.view.tag];
    if ([info isThriceGoods]) {
        
//        ThriceViewController *vc = [[ThriceViewController alloc] initWithTableViewStyleGrouped];
//        [self.navigationController pushViewController:vc animated:YES];
    } else {
        
        GoodsDetailInfoViewController *vc = [[GoodsDetailInfoViewController alloc] initWithNibName:@"GoodsDetailInfoViewController" bundle:nil];
        vc.goodId = info.id;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}


- (void)loadCellContent:(HomePageJXListTableViewCell*)cell indexPath:(NSIndexPath*)indexPath
{
    cell.dataSourceArray = jiexiaoArray;
    [cell.collectView reloadData];
    
}

- (CGFloat)getCellHeight:(HomePageJXListTableViewCell*)cell
{
    
    [cell layoutIfNeeded];
    [cell updateConstraintsIfNeeded];
    CGFloat height = cell.collectView.contentSize.height;
    return height+26;
    
}


#pragma mark - tableview 上下拉刷新

- (void)setTabelViewRefresh
{
    __unsafe_unretained UITableView *tableView = self.myTableView;
    __unsafe_unretained __typeof(self) weakSelf = self;
    // 下拉刷新
    tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        pageNum = 1;
        [weakSelf httpShowData];
        [weakSelf httpGetGoodsList];
    }];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    tableView.mj_header.automaticallyChangeAlpha = YES;
    [tableView.mj_header beginRefreshing];
    // 上拉刷新
    tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf httpGetGoodsList];
        
    }];
    tableView.mj_footer.automaticallyHidden = YES;
}

- (void)hideRefresh
{
    
    if([_myTableView.mj_footer isRefreshing])
    {
        [_myTableView.mj_footer endRefreshing];
    }
    if([_myTableView.mj_header isRefreshing])
    {
        [_myTableView.mj_header endRefreshing];
    }
}

#pragma mark - CycleScrollViewDataSource

- (UIView *)cycleScrollView:(CycleScrollView *)cycleScrollView viewAtPage:(NSInteger)page
{
    if (cycleScrollView.tag == 100) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.userInteractionEnabled = YES;
        BannerInfo *bannerInfo = [bannerArray objectAtIndex:page];
        NSString *url = [NSString stringWithFormat:@"%@",bannerInfo.header];
        [imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil];
        return imageView;
        
    }else{
        
        UILabel *warnLabel = [[UILabel alloc] init];
        RadioInfo *info = [radioArray objectAtIndex:page];
        
        NSString * reviewStr = [NSString stringWithFormat:@"恭喜<color1>“%@”</color1>获取第%@期，%@",info.nick_name,info.good_period,info.good_name];
        
        warnLabel.textColor = [UIColor colorWithRed:83.0/255.0 green:83.0/255.0 blue:83.0/255.0 alpha:1];
        
        NSDictionary* style = @{@"body":[UIFont systemFontOfSize:13],
                                @"color1":[UIColor colorWithRed:0.0/255.0 green:64.0/255.0 blue:128.0/255.0 alpha:1]};
        
        warnLabel.attributedText = [reviewStr attributedStringWithStyleBook:style];
        
        warnLabel.font = [UIFont systemFontOfSize:13];
        return warnLabel;
    }
}

- (NSInteger)numberOfViewsInCycleScrollView:(CycleScrollView *)cycleScrollView
{
    if (cycleScrollView.tag == 100) {
        BannerTableViewCell *cell = objc_getAssociatedObject(cycleScrollView, "cell");
        if (isBannerTwo) {
            cell.pageController.numberOfPages = 2;
        }else{
            cell.pageController.numberOfPages = bannerArray.count;
        }
        
        return  bannerArray.count;
        
    }else{
        return radioArray.count;
    }
}

- (void)cycleScrollView:(CycleScrollView *)cycleScrollView didScrollView:(int)index
{
    if (cycleScrollView.tag == 100) {
        
        BannerTableViewCell *cell = objc_getAssociatedObject(cycleScrollView, "cell");
        if (isBannerTwo)
        {
            cell.pageController.currentPage = index%2;
            
        }else{
            cell.pageController.currentPage = index;
            
        }
    }
    
}

- (CGRect)frameOfCycleScrollView:(CycleScrollView *)cycleScrollView
{
    if (cycleScrollView.tag == 100) {
        return CGRectMake(0, 0, FullScreen.size.width,FullScreen.size.width*0.45);
    }else{
        return CGRectMake(0, 0, FullScreen.size.width-46,20);
    }
}

-(void)clickAddShopCarButtonWithBtn:(UIButton*)btn
{
    
    GoodsListInfo *info = [goodsDataSourceArray objectAtIndex:btn.tag];
    
    if (![Tool islogin]) {
        [Tool loginWithAnimated:YES viewController:nil];
        return;
    }
    
    _selectedGoodsInfo = [info covertToGoodsDetailInfo];
    _selectedGoodsListInfo = info;
    
    if ([info isThriceGoods]) {
        
        // 缓存红包
//        [[ShareManager shareInstance] refreshCoupons];
        
        PurchaseNumberViewController *vc = [[PurchaseNumberViewController alloc] initWithNibName:@"PurchaseNumberViewController" bundle:nil];
        vc.delegate = self;
        vc.data = [info dictionary] ;
//            [vc reloadWithData:_data];
        
        self.definesPresentationContext = YES; //self is presenting view controller
        vc.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        //        if ([self.navigationController.viewControllers.firstObject isKindOfClass:[self class]]) {
        //            [self.navigationController presentViewController:vc animated:YES completion:nil];
        //        } else {
        UIViewController * rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        [rootViewController presentViewController:vc animated:YES completion:nil];
        //        }
        
    } else {
        
        SelectGoodsNumViewController *vc = [[SelectGoodsNumViewController alloc] initWithNibName:@"SelectGoodsNumViewController" bundle:nil];
        
        //    vc.limitNum = [_goodsDetailInfo.good_single_price intValue];
        [vc reloadDetailInfoOnce: [info covertToGoodsDetailInfo]];
        vc.delegate = self;
        //    vc.canBuyNum =  [_goodsDetailInfo.need_people intValue]-[_goodsDetailInfo.now_people intValue];
        self.definesPresentationContext = YES; //self is presenting view controller
        vc.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        UIViewController * rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        [rootViewController presentViewController:vc animated:YES completion:nil];
    }
}

#pragma mark - SelectGoodsNumViewControllerDelegate

- (void)selectGoodsNum:(int)num goodsInfo:(GoodsDetailInfo *)goodsInfo
{
    if (_selectedGoodsListInfo) {
        NSDictionary *data = [_selectedGoodsListInfo dictionary];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:data];
        [dict setObject:@(num) forKey:@"Crowdfunding"];
        
        if (dict) {
            MLog(@"dict%@",dict);
            EntOrderViewController *vc = [EntOrderViewController createWithData:dict];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark - PurchaseNumberViewControllerDelegate

- (void)purchaseNumberDidSelected:(NSDictionary *)bettingData
{
    if (_selectedGoodsListInfo) {
        NSDictionary *data = [_selectedGoodsListInfo dictionary];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:data];
        
        if (bettingData) {
            [dict addEntriesFromDictionary:bettingData];
            MLog(@"bettingData%@",dict);
          EntOrderViewController *vc = [EntOrderViewController createWithData:dict];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark -  PayViewControllerDelegate
- (void)payForBuyGoodsSuccess
{
    
}

#pragma mark - HomePageJXListTableViewCellDelegate

- (void)selectJXGoodsInfo:(NSInteger)index
{
    JieXiaoInfo *info = [jiexiaoArray objectAtIndex:index];
    
   
    if ([info isThriceGoods]) {
        
//        ThriceViewController *vc = [[ThriceViewController alloc] initWithTableViewStyleGrouped];
//        [self.navigationController pushViewController:vc animated:YES];
    } else {
        
        GoodsDetailInfoViewController *vc = [[GoodsDetailInfoViewController alloc]initWithNibName:@"GoodsDetailInfoViewController" bundle:nil];
        vc.goodId = info.id;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Refresh

- (void)autorefresh
{
    NSDate *date = [NSDate date];
    NSDate *previousDate = _updatedTime;
    NSInteger seconds = [date secondsAfterDate:previousDate];
    
    // 刷新间隔时间超过30秒，自动刷新
    if (seconds >= 30) {
        
        __unsafe_unretained UITableView *tableView = self.myTableView;
        [tableView setContentOffset:CGPointZero];
        [tableView.mj_header beginRefreshing];
        //
        //        [self httpShowData];
        //        [self httpGetGoodsList];
        
        _updatedTime = date;
    }
}


#pragma mark - 

- (void)bannerListDidChange:(NSArray *)array
{
    NSString *str = @"";
    for (BannerInfo *object in array) {
        NSString *identify = object.id;
        if (identify.length > 0) {
            str = [str stringByAppendingString:identify];
        }
    }
    
    if (_bannerListFlag == nil || [_bannerListFlag isEqualToString:str] == NO) {
        _bannerListFlag = str;
        
        [_bannerCell.bannerView reloadData];
    }
}




@end
