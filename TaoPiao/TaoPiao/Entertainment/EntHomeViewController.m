//
//  EntHomeViewController.m
//  TaoPiao
//
//  Created by 黎应明 on 2017/9/21.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import "EntHomeViewController.h"
#import "GoodsListCollectionViewCell.h"
#import "EntBuyViewController.h"
#import "CollectionHeaderView.h"

#import "BannerTableViewCell.h"
#import "HomeOddsCell.h"
#import "HomeTopCell.h"
#import "BannerInfo.h"
#import "HomeGoodModel.h"
#import "GetCouponViewController.h"
#import "GoodDetailViewController.h"
#import "TadayDiscountViewController.h"
#import "CycleScrollView.h"
#import "GoodsListInfo.h"
#import "SelectGoodsNumViewController.h"
@interface EntHomeViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,SelectGoodsNumViewControllerDelegate>{
    int page;
    NSMutableArray *collGoodsArray;
    
    NSMutableArray *bannerArray;
    BOOL isBannerTwo;
    NSMutableArray *goodsArray;
    NSMutableArray *discountArray;
    NSMutableArray *goodsDataSourceArray;
    
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
    BOOL isClickButton;
    int pageNum;
    
    GoodsDetailInfo *_selectedGoodsInfo;
    GoodsListInfo *_selectedGoodsListInfo;
}
@property (nonatomic, strong) BannerTableViewCell *bannerCell;
@property (nonatomic, copy) NSString *bannerListFlag;
@property (nonatomic, strong) CollectionHeaderView *collectHeader;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowlayout;
@property(nonatomic,strong)UICollectionView *collectionview;
@end

@implementation EntHomeViewController

-(UICollectionView *)collectionview{
    if (!_collectionview) {
        _flowlayout = [[UICollectionViewFlowLayout alloc] init];
        _flowlayout.minimumLineSpacing = 10;
        _flowlayout.minimumInteritemSpacing = 10;
        _flowlayout.headerReferenceSize=CGSizeMake(ScreenWidth, FullScreen.size.width*0.45+40); //设置collectionView头视图的大小
        _collectionview = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, FullScreen.size.width, FullScreen.size.height-64) collectionViewLayout:_flowlayout];
        _collectionview.delegate = self;
        _collectionview.dataSource = self;
        
        _collectionview.backgroundColor = [UIColor whiteColor];
    }
    return _collectionview;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    collGoodsArray = [NSMutableArray array];
    bannerArray = [NSMutableArray array];
    goodsArray = [NSMutableArray array];
    discountArray = [NSMutableArray array];
    goodsDataSourceArray = [NSMutableArray array];
    slectType = SelectOption_RQ;

//    [self setTabelViewRefresh];
    pageNum = 1;
    self.view.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.collectionview];
    
     [_collectionview registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"firstHeader"];
    [_collectionview registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    
    [_collectionview registerClass:[GoodsListCollectionViewCell class] forCellWithReuseIdentifier:@"GoodsListCollectionViewCell"];

    self.title = @"娱乐城";
    [self setRightBarButtonItem:@"优惠券"];
    
    [self setTabelViewRefresh];
   
}

- (void)rightBarButtonItemAction:(id)sender
{
    EntBuyViewController *vc = [[EntBuyViewController alloc]initWithTableViewStyle:1];
    [self.navigationController pushViewController:vc animated:YES];
}



#pragma mark 获取历表数据
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
    
    
   
    __weak EntHomeViewController *weakSelf = self;
    [HttpHelper getGoodsListWithOrder_by_name:typeStr
                            order_by_rule:descStr
                                  pageNum:[NSString stringWithFormat:@"%d",pageNum]
                                 limitNum:@"100"
                                  success:^(NSDictionary *resultDic){
                                      [weakSelf hideRefresh];
                                      if ([[resultDic objectForKey:@"status"] integerValue] == 0) {
                                          [weakSelf handleGetGoodsListLoadResult:resultDic];
                                      }
                                      //                                    else
                                      //                                    {
                                      //                                        [Tool showPromptContent:[resultDic objectForKey:@"desc"] onView:self.view];
                                      //                                    }
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
            MLog(@"一元购%@",dic);
            GoodsListInfo *info = [dic objectByClass:[GoodsListInfo class]];
            [goodsDataSourceArray addObject:info];
        }
        
        if (resourceArray.count < 100) {
            [self.collectionview.mj_footer endRefreshingWithNoMoreData];
        }else{
            [self.collectionview.mj_footer resetNoMoreData];
        }
        
        pageNum++;
    }
    
    [self.collectionview reloadData];
    
    if (isClickButton) {
//        [self updateTableOffset];
        isClickButton = NO;
    }
}

- (void)setTabelViewRefresh
{
    __unsafe_unretained UICollectionView *collectionView = self.collectionview;
    __unsafe_unretained __typeof(self) weakSelf = self;
    // 下拉刷新
    collectionView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        pageNum = 1;
//        [weakSelf httpShowData];
        [weakSelf httpGetGoodsList];
    }];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    collectionView.mj_header.automaticallyChangeAlpha = YES;
    [collectionView.mj_header beginRefreshing];
    // 上拉刷新
    collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf httpGetGoodsList];
        
    }];
    collectionView.mj_footer.automaticallyHidden = YES;
}

- (void)hideRefresh
{
//    
    if([self.collectionview.mj_footer isRefreshing])
    {
        [self.collectionview.mj_footer endRefreshing];
    }
    if([self.collectionview.mj_header isRefreshing])
    {
        [self.collectionview.mj_header endRefreshing];
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
        [_collectHeader.bannerView reloadData];
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


#pragma mark - collectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
        return goodsDataSourceArray.count;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{

    return 1;
}

#pragma mark - collectionView返回头视图

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


- (void)clickRQButtonAction:(id)sender
{
    isClickButton = YES;
    slectType = SelectOption_RQ;
    [self updateSelectStatue];
   
    
}
- (void)clickZXButtonAction:(id)sender
{
    isClickButton = YES;
    slectType = SelectOption_ZX1;
    [self updateSelectStatue];
 
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
   
}


//  返回头视图
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    //如果是头视图
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        UICollectionReusableView *header=[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"firstHeader" forIndexPath:indexPath];
        
        //添加头视图的内容
        CollectionHeaderView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"CollectionHeaderView" owner:nil options:nil] firstObject];
        headerView.width = ScreenWidth;
        headerView.height = 150 * UIAdapteRate;
        _collectHeader = headerView;
        headerView.bannerView.delegate = self;
        headerView.bannerView.dataSource = self;
        headerView.bannerView.autoScrollAble = YES;
        headerView.bannerView.tag = 100;
        headerView.bannerView.direction = CycleDirectionLandscape;
        
        objc_setAssociatedObject(headerView.bannerView, "headerView", header, OBJC_ASSOCIATION_ASSIGN);
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBanner:)];
        tap.numberOfTapsRequired = 1;
        objc_setAssociatedObject(tap, "headerView", headerView.bannerView, OBJC_ASSOCIATION_ASSIGN);
        [headerView.bannerView addGestureRecognizer:tap];

        //头视图添加view
        [header addSubview:headerView];
        
        
        
        CGRect frame = CGRectMake(0, 150 * UIAdapteRate, [UIScreen mainScreen].bounds.size.width , 40);
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
        
        [header addSubview:bgView];
        return header;
            
    }
        return nil;
        
}




- (CGFloat)minimumInteritemSpacing {
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GoodsListCollectionViewCell *cell = (GoodsListCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"GoodsListCollectionViewCell" forIndexPath:indexPath];
    
    cell.processView.layer.masksToBounds =YES;
    cell.processView.layer.cornerRadius = cell.processView.frame.size.height/2;
    
    GoodsListInfo *info = [goodsDataSourceArray objectAtIndex:indexPath.row];
    
    cell.processLabelWidth.constant = ((collectionView.frame.size.width)/2- 58 - 3*8 + 2)*([info.progress doubleValue]/100.0);
    //    cell.processLabelWidth.constant = cell.processView.width * ([info.progress doubleValue]/100.0);
    
    [cell.photoImage sd_setImageWithURL:[NSURL URLWithString:info.good_header] placeholderImage:PublicImage(@"defaultImage")];
    cell.titleLabel.text = info.good_name;
    cell.processNumLabel.text = [NSString stringWithFormat:@"%@％",info.progress];
    cell.addButton.tag = indexPath.row;
    [cell.addButton addTarget:self action:@selector(clickAddButonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    cell.priceButton.hidden = YES;
    cell.priceButton.frame = CGRectMake(10 * UIAdapteRate, 0, 28* UIAdapteRate, 31 * UIAdapteRate);
    
    if (info.good_single_price.intValue == 10) {
        cell.priceButton.hidden = NO;
        [cell.priceButton setBackgroundImage:[UIImage imageNamed:@"cont_ten_flag.png"] forState:UIControlStateNormal];
        [cell.priceButton setBackgroundImage:[UIImage imageNamed:@"cont_ten_flag.png"] forState:UIControlStateSelected];
    }
    
    NSString *str = info.part_sanpei;
    if ([str isEqualToString:@"y"]) {
        cell.priceButton.hidden = NO;
        [cell.priceButton setBackgroundImage:[UIImage imageNamed:@"icon_thrice"] forState:UIControlStateNormal];
        [cell.priceButton setBackgroundImage:[UIImage imageNamed:@"icon_thrice"] forState:UIControlStateSelected];
        float rate = 0.8 * UIAdapteRate;
        cell.priceButton.frame = CGRectMake(8 * UIAdapteRate, 4 * UIAdapteRate, 61 * rate, 37 * rate);
    }
    
    MLog(@"cell = %@", indexPath);
    
    
    return cell;
    
}

- (void)clickAddShopCarButtonWithIndex:(NSInteger)index
{
    if (![Tool islogin]) {
        [Tool loginWithAnimated:YES viewController:nil];
        return;
    }
    
    GoodsListInfo *info = [goodsDataSourceArray objectAtIndex:index];
    //    [self httpAddGoodsToShopCartWithGoodsID:info.good_id buyNum:@"1"];
    
   
    
    _selectedGoodsInfo = [info covertToGoodsDetailInfo];
    _selectedGoodsListInfo = info;
//
//    if ([info isThriceGoods]) {
//        
//        // 缓存红包
//        [[ShareManager shareInstance] refreshCoupons];
//        
//        PurchaseNumberViewController *vc = [[PurchaseNumberViewController alloc] initWithNibName:@"PurchaseNumberViewController" bundle:nil];
//        vc.delegate = self;
//        vc.data = [info dictionary] ;
//        //    [vc reloadWithData:_data];
//        
//        self.definesPresentationContext = YES; //self is presenting view controller
//        vc.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
//        vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
//        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//        
//        //        if ([self.navigationController.viewControllers.firstObject isKindOfClass:[self class]]) {
//        //            [self.navigationController presentViewController:vc animated:YES completion:nil];
//        //        } else {
//        UIViewController * rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
//        [rootViewController presentViewController:vc animated:YES completion:nil];
//        //        }
//        
//    } else {
//        
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
//    }
}

#pragma mark - SelectGoodsNumViewControllerDelegate

- (void)selectGoodsNum:(int)num goodsInfo:(GoodsDetailInfo *)goodsInfo
{
    if (_selectedGoodsListInfo) {
        NSDictionary *data = [_selectedGoodsListInfo dictionary];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:data];
        [dict setObject:@(num) forKey:@"Crowdfunding"];
        
//        if (dict) {
//            PayTableViewController *vc = [PayTableViewController createWithData:dict];
//            [self.navigationController pushViewController:vc animated:YES];
//        }
    }
}


//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake( (collectionView.frame.size.width)/2,200);
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
   
}





@end
