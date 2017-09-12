//
//  HomeViewController.m
//  TaoPiao
//
//  Created by 黎应明 on 2017/8/30.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import "HomeViewController.h"
#import "BannerTableViewCell.h"
#import "HomeOddsCell.h"
#import "HomeTopCell.h"
#import "BannerInfo.h"
#import "HomeGoodModel.h"
#import "GetCouponViewController.h"
#import "GoodDetailViewController.h"
@interface HomeViewController (){
    
    NSMutableArray *bannerArray;
    BOOL isBannerTwo;
    NSMutableArray *goodsArray;
    NSMutableArray *discountArray;
    int page;
}
@property (nonatomic, strong) BannerTableViewCell *bannerCell;
@property (nonatomic, copy) NSString *bannerListFlag;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    page = 0;
    self.title = @"淘券";
    bannerArray = [NSMutableArray array];
    goodsArray = [NSMutableArray array];
    discountArray = [NSMutableArray array];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getData];
    [self setTabelViewRefresh];
}

-(void)getData{
     MLog(@"trytrytry");
    __weak HomeViewController *weakSelf = self;
    [HttpHelper getHttpWithUrlStr:URL_HomeBasics
                      success:^(NSDictionary *resultDic){
                        if ([[resultDic objectForKey:@"status"] integerValue] == 0) {
                            
                            [self handleloadResult:resultDic];
                          }
                      }fail:^(NSString *decretion){
                          [Tool showPromptContent:@"网络出错了" onView:weakSelf.view];
                      }];
}

- (void)handleloadResult:(NSDictionary *)resultDic
{
    NSDictionary *dic = [resultDic objectForKey:@"data"];
    
    NSArray *banArray = [dic objectForKey:@"advertisementList"];
    
    if (banArray && banArray.count > 0) {
        if (bannerArray.count > 0) {
            [bannerArray removeAllObjects];
        }
        for (NSDictionary *dic in banArray)
        {
             MLog(@"banArray:%@",dic);
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
    
    NSArray *goodArray = [dic objectForKey:@"todayDiscount"];
    if (goodArray && goodArray.count > 0) {
        if (discountArray.count > 0) {
            [discountArray removeAllObjects];
        }
        for (NSDictionary *dic in goodArray)
        {
            MLog(@"goodArray:%@",dic);
            HomeGoodModel *info = [dic objectByClass:[HomeGoodModel class]];
            [discountArray addObject:info];
        }
    }
    
    
    [self.tableView reloadData];
}
#pragma mark 获取历表数据
-(void)getListData{
    __weak HomeViewController *weakSelf = self;
        [HttpHelper getHomeListDataWithPageNum:[NSString stringWithFormat:@"%d",page] limitNum:@"20" success:^(NSDictionary *resultDic) {
            [weakSelf hideRefresh];
            if ([[resultDic objectForKey:@"status"] integerValue] == 0) {
                
                [self handleloadListResult:resultDic];
            }
            
        } fail:^(NSString *description) {
            [weakSelf hideRefresh];
            [Tool showPromptContent:@"网络出错了" onView:weakSelf.view];
        }];
}

- (void)handleloadListResult:(NSDictionary *)resultDic
{
    NSDictionary *dic = [resultDic objectForKey:@"data"];
    NSArray *goodArray = [dic objectForKey:@"goodsList"];
    if (goodArray && goodArray.count > 0) {
        if (goodsArray.count > 0&&page == 1) {
            [goodsArray removeAllObjects];
        }
        for (NSDictionary *dic in goodArray)
        {
            MLog(@"goodArray:%@",dic);
            HomeGoodModel *info = [dic objectByClass:[HomeGoodModel class]];
            [goodsArray addObject:info];
        }
    }
    
    if (goodArray.count < 100) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else{
        [self.tableView.mj_footer resetNoMoreData];
    }
    
     page++;

    //刷新
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:2];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
}
#pragma mark tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
          return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section!=2) {
        return 1;
    }else{
        return goodsArray.count;
    }
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
            HomeOddsCell *cell = nil;
            cell = [tableView dequeueReusableCellWithIdentifier:@"HomeOddsCell"];
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomeOddsCell" owner:nil options:nil];
                cell = [nib objectAtIndex:0];
                //设点点击选择的颜色(无)
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            return cell;
        }
            break;
        default:
        {
            HomeTopCell *cell = nil;
            cell = [tableView dequeueReusableCellWithIdentifier:@"HomeTopCell"];
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomeTopCell" owner:nil options:nil];
                cell = [nib objectAtIndex:0];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            //设点点击选择的颜色(无)
            HomeGoodModel *model = [goodsArray objectAtIndex:indexPath.row];
            cell.goodModel = model;
            [cell.lqBtn addTarget:self action:@selector(lqBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            cell.lqBtn.tag = indexPath.row;
            return cell;
        }
            break;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    switch (indexPath.section) {
        case 0:
             return FullScreen.size.width*0.45;
            break;
        case 1:
             return ScreenWidth/2+10;
            break;
        default:
             return 140;
            break;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 2 ) {
       return 30;
    }else{
        return 0.001;
    }
    

}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 2) {
        UIView *headerView = [[UIView alloc]initWithFrame:(CGRectMake(0, 0, ScreenWidth, 30))];
        headerView.backgroundColor = [UIColor grayColor];
        UILabel *headerTitle = [[UILabel alloc]initWithFrame:(CGRectMake(0, 0, 100, 30))];
        headerTitle.center = headerView.center;
        headerTitle.text = @"人气推荐";
        [headerView addSubview:headerTitle];
        return headerView;
    }else{
        return nil;
    }
   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section == 2) {
        GoodDetailViewController *vc = [[GoodDetailViewController alloc]initWithTableViewStyle:0];
        vc.goodModel = [goodsArray objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - 领取操作
-(void)lqBtnClick:(UIButton *)btn{
    GetCouponViewController *vc = [[GetCouponViewController alloc]initWithTableViewStyle:0];
    vc.goodModel = [goodsArray objectAtIndex:btn.tag];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - 上下刷新
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


#pragma mark -

- (void)bannerListDidChange:(NSArray *)array
{
    NSString *str = @"";
    for (BannerInfo *object in array) {
        NSString *identify = object.id;
        MLog(@"identify：%@",identify);
        if (identify.length > 0) {
            str = [str stringByAppendingString:identify];
        }
    }
    
    if (_bannerListFlag == nil || [_bannerListFlag isEqualToString:str] == NO) {
        _bannerListFlag = str;
         MLog(@"str：%@",str);
        [_bannerCell.bannerView reloadData];
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
         UIImageView *imageView = [[UIImageView alloc] init];
         return imageView;
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
        return 1;
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
    

}
//响应单击方法－跳转广告页面
- (void)tapBanner:(UITapGestureRecognizer *) tap
{
    
    
}
@end
