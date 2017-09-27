//
//  EntBuyViewController.m
//  TaoPiao
//
//  Created by 黎应明 on 2017/9/20.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import "EntBuyViewController.h"
#import "CouponModel.h"
#import "EntBuyCouPonCell.h"
#import "EditOrderViewController.h"
@interface EntBuyViewController ()<EntBuyDelegate>{
    
    NSMutableArray *dataArray;
    NSMutableArray *goodsArray;
    NSMutableArray *payNumArray;
    NSMutableArray *goodsID;
    int page;
    int price;
}
@property (strong,nonatomic)UILabel *priceLabel;
@end

@implementation EntBuyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"优惠券";
    price = 0;
    dataArray = [NSMutableArray array];
    goodsArray = [NSMutableArray array];
    payNumArray = [NSMutableArray array];
    goodsID = [NSMutableArray array];
    [self setTabelViewRefresh];
    [self setFootViewForPay];
}

#pragma mark 获取历表数据
-(void)getListData{
    __weak EntBuyViewController *weakSelf = self;
    
    [HttpHelper getEntCouponListDataWithPageNum:[NSString stringWithFormat:@"%d",page] limitNum:@"20" success:^(NSDictionary *resultDic) {
        [weakSelf hideRefresh];
        if ([[resultDic objectForKey:@"status"] integerValue] == 0) {
            
            [weakSelf handleloadListResult:resultDic];
        }
        
    } fail:^(NSString *description) {
        [weakSelf hideRefresh];
        [Tool showPromptContent:@"网络出错了" onView:weakSelf.view];
    }];
}

- (void)handleloadListResult:(NSDictionary *)resultDic
{
    NSDictionary *dic = [resultDic objectForKey:@"data"];
    NSArray *goodArray = [dic objectForKey:@"rechargeGoodsList"];
    if (goodArray && goodArray.count > 0) {
        if (dataArray.count > 0&&page==1) {
            [dataArray removeAllObjects];
            [goodsArray removeAllObjects];
        }
        for (NSDictionary *dic in goodArray)
        {
            MLog(@"dic%@",dic);
            CouponModel *info = [dic objectByClass:[CouponModel class]];
            [dataArray addObject:info];
            HomeGoodModel *model = [dic objectByClass:[HomeGoodModel class]];
            [goodsArray addObject:model];
        }
    }
    
    if (goodArray.count < 100) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else{
        [self.tableView.mj_footer resetNoMoreData];
    }
    
    page++;
    
    //刷新
    [self.tableView reloadData];
}

-(void)setFootViewForPay{
    UIView *buyFooterView = [[UIView alloc]initWithFrame:(CGRectMake(0, ScreenHeight-64-52, ScreenWidth, 52))];
    buyFooterView.backgroundColor = [UIColor whiteColor];
    UILabel *line = [[UILabel alloc]initWithFrame:(CGRectMake(0, 0, ScreenWidth, 2))];
    line.backgroundColor = [UIColor lightGrayColor];
    [buyFooterView addSubview:line];
    
    _priceLabel = [[UILabel alloc]initWithFrame:(CGRectMake(10, 0, ScreenWidth/2-10, 50))];
    _priceLabel.text = [NSString stringWithFormat:@"共计:¥0.0"];
    _priceLabel.font = [UIFont systemFontOfSize:20];
    _priceLabel.textColor = [UIColor redColor];
    [buyFooterView addSubview:_priceLabel];
    
    UIButton *goPayBtn = [[UIButton alloc]initWithFrame:(CGRectMake(ScreenWidth/2, 2, ScreenWidth/2, 50))];
    [goPayBtn setTitle:@"立即购买" forState:0];
    [goPayBtn setTitleColor:[UIColor whiteColor] forState:0];
    goPayBtn.backgroundColor = [UIColor greenColor];
    [goPayBtn addTarget: self action:@selector(goPay) forControlEvents:UIControlEventTouchUpInside];
    [buyFooterView addSubview:goPayBtn];
    [self.view addSubview:buyFooterView];
}

-(void)goPay{
    MLog(@"放开我 我要去付钱");
    MLog(@"payNum");
    
        NSString *ids=[goodsID componentsJoinedByString:@","];
        MLog(@"goodsis%@",ids);
    [HttpHelper getOrderWithOrderType:@"b" goods_id:ids buy_num:@"1" coupons_ids:@[] type:@"d" user_id:[ShareManager shareInstance].userinfo.id consignee_name:@"" consignee_tel:@"" consignee_address:@"" remark:@"" express_id:@"" success:^(NSDictionary *dictionary) {
        
        NSString *status = [dictionary objectForKey:@"status"];
//        NSString *description = [dictionary objectForKey:@"desc"];
        NSDictionary *order = [dictionary objectForKey:@"data"];
        NSString *orderNo = order[@"orderid"];
        NSString *price = order[@"all_price"];
        if (![status isEqualToString:@"0"]) {
             [Tool showPromptContent:@"哈哈哈垃圾" onView:self.view];
        }else{
            MLog(@"开始支付");
            [self payWith:orderNo price:price type:@"淘券支付"];
            
        }
        

    } failure:^(NSString *description) {
        [Tool showPromptContent:@"生成订单失败" onView:self.view];
    }];
    
}
-(void)payWith:(NSString*)orderNo price:(NSString *)allPriceStr type:(NSString *)order_type{
    
    [HttpHelper getZFBInfoWithOrderNo:orderNo
                            total_fee:allPriceStr
                     spbill_create_ip:@"127.0.0.1"
                                 body:order_type
                               detail:@"充值支付"
                              success:^(NSDictionary *resultDic){
                                  NSString *status = [resultDic objectForKey:@"status"];
                                  NSDictionary *data = [resultDic objectForKey:@"data"];
                                  NSString *transaction_id = [data objectForKey:@"orderInfo"];
                                  BOOL result = [status isEqualToString:@"0"];
                                  if (result) {
                                      //调用支付宝支付接口
                                      [[AlipaySDK defaultService] payOrder:transaction_id fromScheme:@"TaoPiao" callback:^(NSDictionary *resultDic) {
                                          MLog(@"resultDic%@",resultDic);
                                          
                                      }];
                                  }
                                  
                              }fail:^(NSString * description){
                                  [Tool showPromptContent:description onView:self.view];
                              }];
}


#pragma mark tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

//创建并显示每行的内容

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EntBuyCouPonCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:@"EntBuyCouPonCell"];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"EntBuyCouPonCell" owner:nil options:nil];
        cell = [nib objectAtIndex:0];
    }
    //设点点击选择的颜色(无)
    CouponModel *model = [dataArray objectAtIndex:indexPath.row];
    cell.couponModel = model;
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}
- (void)sendValue:(int)value Model:(CouponModel *)model{

    if (value<0) {
        MLog(@"hahah%@",model.good_name);
        if ([goodsID containsObject:model.id]) {
            [goodsID removeObject:model.id];
        }
    }
    if (value>0) {
        [goodsID addObject:model.id];
    }
    
    price += value;
    MLog(@"钱钱钱%d",value);
    _priceLabel.text = [NSString stringWithFormat:@"共计:¥ %d",price];

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 140;
}

- (void)setTabelViewRefresh
{
    __unsafe_unretained UITableView *tableView = self.tableView;
    __unsafe_unretained __typeof(self) weakSelf = self;
    // 下拉刷新
    tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        page = 1;
        [weakSelf getListData];
    }];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    tableView.mj_header.automaticallyChangeAlpha = YES;
    [tableView.mj_header beginRefreshing];
    // 上拉刷新
    tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf getListData];
        
    }];
    tableView.mj_footer.automaticallyHidden = YES;
}

- (void)hideRefresh
{
    
    if([self.tableView.mj_footer isRefreshing])
    {
        [self.tableView.mj_footer endRefreshing];
    }
    if([self.tableView.mj_header isRefreshing])
    {
        [self.tableView.mj_header endRefreshing];
    }
}

@end
