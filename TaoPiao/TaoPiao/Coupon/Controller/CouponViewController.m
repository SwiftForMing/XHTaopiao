//
//  CouponViewController.m
//  TaoPiao
//
//  Created by 黎应明 on 2017/8/30.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import "CouponViewController.h"
#import "HomeTopCell.h"
#import "CouponModel.h"
#import "HomeGoodModel.h"
#import "GoodDetailViewController.h"
#import "GetCouponViewController.h"
#import "EntBuyCouPonCell.h"
@interface CouponViewController ()<UITextViewDelegate>{
    NSMutableArray *dataArray;
    NSMutableArray *goodsArray;
    int page;
    NSString *searchKey;
}
@property (nonatomic, strong) UITextView *searchTextView;

@end

@implementation CouponViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.tableView.contentOffset = CGPointMake(0, -20);
}


- (void)viewDidLoad {
    [super viewDidLoad];
     self.navigationController.navigationBarHidden = YES;
    dataArray = [NSMutableArray array];
    goodsArray = [NSMutableArray array];
    page = 1;
    searchKey = @"";
    self.view.backgroundColor = [UIColor blueColor];
    [self setHeaderView];
    [self setTabelViewRefresh];
}

//优惠卷码输入框
-(void)setHeaderView{
    UIView *headerView = [[UIView alloc]initWithFrame:(CGRectMake(0, 20, ScreenWidth, 44))];
    
    self.searchTextView = [[UITextView alloc]initWithFrame:(CGRectMake(30, 7, ScreenWidth-150, 30))];
    self.searchTextView.layer.masksToBounds = YES;
    self.searchTextView.layer.cornerRadius = 5;
    self.searchTextView.tintColor = [[UIColor alloc]initWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1];
    self.searchTextView.backgroundColor = [[UIColor alloc]initWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1];
    _searchTextView.delegate = self;
    self.searchTextView.textColor = [[UIColor alloc]initWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1];
    self.searchTextView.text = @"请输入优惠券码";
    headerView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:_searchTextView];
    
    UIButton *getCouponBtn = [[UIButton alloc]initWithFrame:(CGRectMake(ScreenWidth-100, 7, 80, 30))];
    getCouponBtn.backgroundColor = [UIColor greenColor];
    [getCouponBtn setTitle:@"兑换" forState:0];
    [getCouponBtn setTintColor:[UIColor whiteColor]];
    
    [getCouponBtn addTarget:self action:@selector(getCoupon) forControlEvents:UIControlEventTouchUpInside];
    getCouponBtn.layer.masksToBounds = YES;
    getCouponBtn.layer.cornerRadius = 5;
    [headerView addSubview:getCouponBtn];
//    [self.view addSubview:headerView];
    self.tableView.tableHeaderView = headerView;
}
#pragma mark兑换优惠卷
-(void)getCoupon{
    MLog(@"我就看看进来没有？");
    [self.searchTextView resignFirstResponder];
     __weak CouponViewController *weakSelf = self;
    [HttpHelper getAddCouponDataWithUserID:[ShareManager shareInstance].userinfo.id Coupons_secret:searchKey success:^(NSDictionary *resultDic) {
        
        MLog(@"resultDic%@",resultDic[@"desc"]);
        if ([[resultDic objectForKey:@"status"] integerValue] == 0) {
            
            [weakSelf setTabelViewRefresh];
        }else{
             [Tool showPromptContent:resultDic[@"desc"] onView:weakSelf.view];
        }
        
    } fail:^(NSString *description) {
         [Tool showPromptContent:@"网络出错了" onView:weakSelf.view];
    }];
}


- (void)textViewDidChange:(UITextView *)textView{
    
    searchKey = textView.text;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    self.searchTextView.text = @"";
    self.searchTextView.textColor = [UIColor blackColor];
    return YES;
}
#pragma mark 获取历表数据
-(void)getListData{
    __weak CouponViewController *weakSelf = self;
    
    [HttpHelper getCouponListDataWithUserID:[ShareManager shareInstance].userinfo.id PageNum:[NSString stringWithFormat:@"%d",page] limitNum:@"20" type:@"a"success:^(NSDictionary *resultDic) {
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
    NSArray *goodArray = [dic objectForKey:@"couponsList"];
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
            model.id = info.good_id;
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
    cell.leftBtn.hidden = YES;
    cell.rightBtn.hidden = YES;
    cell.numLabel.hidden = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchTextView resignFirstResponder];
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
    GoodDetailViewController *vc = [[GoodDetailViewController alloc]initWithTableViewStyle:0];
    vc.goodModel = [goodsArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
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
