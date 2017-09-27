//
//  DuoBaoRecordViewController.m
//  DuoBao
//
//  Created by gthl on 16/2/14.
//  Copyright © 2016年 linqsh. All rights reserved.
//

#import "DuoBaoRecordViewController.h"
#import "DuoBaoRecordListTableViewCell.h"
#import "GoodsDetailInfoViewController.h"
#import "DBNumViewController.h"
#import "SelfDuoBaoRecordInfo.h"
#import "PurchaseRecordTableViewCell.h"
#import "GoodsDetailInfoViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
//#import "ThriceViewController.h"

#import "GoodsListViewController.h"
@interface DuoBaoRecordViewController ()
{
    int selectOptionType;//0全部 1 进行中 2 已揭晓
    int pageNum;
    NSMutableArray *dataSourceArray;
}

@end

@implementation DuoBaoRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initVariable];
    [self leftNavigationItem];
    [self setTabelViewRefresh];
    //手势返回
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initVariable
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"抽奖记录";
    selectOptionType = 0;
    [self updateHeadButtonView];
    pageNum = 1;
    _headIconWidth.constant = FullScreen.size.width/3;
    dataSourceArray = [NSMutableArray array];
}

- (void)leftNavigationItem
{
    UIControl *leftItemControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 20, 44)];
    [leftItemControl addTarget:self action:@selector(clickLeftItemAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *back = [[UIImageView alloc] initWithFrame:CGRectMake(0, 13, 10, 18)];
    back.image = [UIImage imageNamed:@"new_back"];
    [leftItemControl addSubview:back];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftItemControl];
}

- (void)updateHeadButtonView
{
    [_allButton setTitleColor:[UIColor colorWithRed:83.0/255.0 green:83.0/255.0 blue:83.0/255.0 alpha:1] forState:UIControlStateNormal];
    [_jxzButton setTitleColor:[UIColor colorWithRed:83.0/255.0 green:83.0/255.0 blue:83.0/255.0 alpha:1] forState:UIControlStateNormal];
    [_yjxButton setTitleColor:[UIColor colorWithRed:83.0/255.0 green:83.0/255.0 blue:83.0/255.0 alpha:1] forState:UIControlStateNormal];
    
    _allLine.hidden = YES;
    _jxzLine.hidden = YES;
    _yjxLine.hidden = YES;
    
    switch (selectOptionType) {
        case 0:
        {
            [_allButton setTitleColor:[UIColor colorWithRed:230.0/255.0 green:48.0/255.0 blue:48.0/255.0 alpha:1] forState:UIControlStateNormal];
            _allLine.hidden = NO;
        }
            break;
        case 1:
        {
            [_jxzButton setTitleColor:[UIColor colorWithRed:230.0/255.0 green:48.0/255.0 blue:48.0/255.0 alpha:1] forState:UIControlStateNormal];
            _jxzLine.hidden = NO;
        }
            break;
        default:
        {
            [_yjxButton setTitleColor:[UIColor colorWithRed:230.0/255.0 green:48.0/255.0 blue:48.0/255.0 alpha:1] forState:UIControlStateNormal];
            _yjxLine.hidden = NO;
        }
            break;
    }
    
}


#pragma mark - http

- (void)httpGetRecordList
{
    __weak DuoBaoRecordViewController *weakSelf = self;
    
    NSString *statusStr = nil;
    switch (selectOptionType) {
        case 0:
            statusStr = @"全部";
            break;
        case 1:
            statusStr = @"进行中";
            break;
        default:
            statusStr = @"已揭晓";
            break;
    }
    [self removeBgimage];
    [HttpHelper getDuoBaoRecordWithUserid:[ShareManager shareInstance].userinfo.id
                               status:statusStr
                              pageNum:[NSString stringWithFormat:@"%d",pageNum]
                             limitNum:@"20"
                              success:^(NSDictionary *resultDic){
                                  [weakSelf hideRefresh];
                                  if ([[resultDic objectForKey:@"status"] integerValue] == 0) {
                                      [weakSelf handleloadResult:resultDic];
                                  }else
                                  {
                                      
                                      [Tool showPromptContent:[resultDic objectForKey:@"desc"] onView:self.view];
                                      
                                  }
                              }fail:^(NSString *decretion){
                                  [weakSelf hideRefresh];
                                  [Tool showPromptContent:decretion onView:self.view];
                              }];
}

-(void)noDataUI
{
    UIImageView *bgImage = [[UIImageView alloc]initWithFrame:(CGRectMake(FullScreen.size.width/2-100, 130, 200, 200))];
    bgImage.image = [UIImage imageNamed:@"bg_duob"];
    bgImage.contentMode = UIViewContentModeScaleAspectFit;
    bgImage.tag = 100;
    
    UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, ScreenWidth, 162)];
    titlelabel.font = [UIFont systemFontOfSize:22];
    titlelabel.textColor = [UIColor lightGrayColor];
    titlelabel.textAlignment = NSTextAlignmentCenter;
    titlelabel.tag = 300;
    
    
    UIView *goJoin = [[UIView alloc]initWithFrame:(CGRectMake(0, FullScreen.size.height-113, FullScreen.size.width, 49))];
    goJoin.backgroundColor = [UIColor colorFromHexString:@"EFEFF4"];
    goJoin.tag = 200;
    UILabel *label = [[UILabel alloc]initWithFrame:(CGRectMake(60, 10, self.myTableView.frame.size.width-113, 26))];
    NSString *statusStr = nil;
    switch (selectOptionType) {
        case 0:
            statusStr = @"还没有参加抽奖？，万元大奖等你来";
            titlelabel.text =  @"你还没有开始抽奖哦～";
            break;
        case 1:
            statusStr = @"抽奖正在火热进行，赶快加入吧！";
            titlelabel.text =  @"抢得火热怎么可以少了你呢？";
            break;
        default:
            statusStr = @"不要放弃下一个中奖的就是你！";
            titlelabel.text =  @"幸运女神在对你微笑哦～";
            break;
    }
    
    label.text = statusStr;
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:13];
    
    label.textColor = [UIColor colorFromHexString:@"474747"];
    
    [goJoin addSubview:label];
    
    UIButton *jionBtn = [[UIButton alloc]initWithFrame:(CGRectMake(label.frame.size.width+10, 10, 86, 30))];
    jionBtn.backgroundColor = [UIColor whiteColor];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:@"立即参与"];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, [str length])];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorFromHexString:@"e6332e"] range:NSMakeRange(0, [str length])];
    [jionBtn setAttributedTitle:str forState:UIControlStateNormal];
    jionBtn.layer.masksToBounds = YES;
    jionBtn.layer.cornerRadius = 5;
    
    jionBtn.layer.borderWidth = 2;
    jionBtn.layer.borderColor = [[UIColor colorFromHexString:@"e6332e"] CGColor];
    [jionBtn addTarget:self action:@selector(join) forControlEvents:UIControlEventTouchUpInside];
    
    [goJoin addSubview:jionBtn];
    [self.myTableView addSubview:bgImage];
    [self.myTableView addSubview:titlelabel];
    [self.view addSubview:goJoin];
}

-(void)removeBgimage
{
    if ([self.myTableView viewWithTag:100]) {
        [[self.myTableView viewWithTag:100] removeFromSuperview];
        [[self.view viewWithTag:200] removeFromSuperview];
        [[self.myTableView viewWithTag:300] removeFromSuperview];
    }else{
        NSLog(@"没有东西");
    }
    
}
-(void)join
{
    GoodsListViewController *vc = [[GoodsListViewController alloc]initWithNibName:@"GoodsListViewController" bundle:nil];
    vc.typeId = @"";
    vc.typeName = @"商品列表";
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)handleloadResult:(NSDictionary *)resultDic
{
    
    NSArray *resourceArray = [[resultDic objectForKey:@"data"] objectForKey:@"fightRecordList"];
    
    if (dataSourceArray.count > 0 && pageNum == 1) {
        [dataSourceArray removeAllObjects];
        
    }
    
    if (resourceArray && resourceArray.count > 0 )
    {
        
        for (NSDictionary *dic in resourceArray)
        {
            SelfDuoBaoRecordInfo *info = [dic objectByClass:[SelfDuoBaoRecordInfo class]];
            [dataSourceArray addObject:info];
        }
        
        if (resourceArray.count < 20) {
            [_myTableView.mj_footer endRefreshingWithNoMoreData];
        }else{
            [_myTableView.mj_footer resetNoMoreData];
        }
        
        pageNum++;
        
    }else{
        if (pageNum == 1) {
            [Tool showPromptContent:@"暂无数据" onView:self.view];
            //在没有记录的情况下提升用户
            [self noDataUI];
            
        }
    }
    [_myTableView reloadData];
}


#pragma mark - Button Action

- (void)clickLeftItemAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickAllButtonAction:(id)sender
{
    selectOptionType = 0;
    [self updateHeadButtonView];
    [self removeBgimage];
    [self.myTableView.mj_header beginRefreshing];
}

- (IBAction)clickJXZButtonAction:(id)sender
{
    selectOptionType = 1;
    [self updateHeadButtonView];
    [self removeBgimage];
    [self.myTableView.mj_header beginRefreshing];
}

- (IBAction)clickYJXButtonAction:(id)sender
{
    selectOptionType = 2;
    [self updateHeadButtonView];
    [self removeBgimage];
    [self.myTableView.mj_header beginRefreshing];
}


- (void)clickSeeNumButtonAction:(UIButton *)btn
{
    SelfDuoBaoRecordInfo *info = [dataSourceArray objectAtIndex:btn.tag];
    DBNumViewController *vc = [[DBNumViewController alloc]initWithNibName:@"DBNumViewController" bundle:nil];
    vc.userId = [ShareManager shareInstance].userinfo.id;
    vc.goodId = info.id;
    vc.userName = [ShareManager shareInstance].userinfo.nick_name;
    vc.goodName = [NSString stringWithFormat:@"[第%@期]%@",info.good_period,info.good_name];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - UITableViewDelegate

//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataSourceArray.count;
}

//设置cell的行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 160;
    
    SelfDuoBaoRecordInfo *info = [dataSourceArray objectAtIndex:indexPath.row];
    if ([info hasBettingThrice]) {
        height += 112;
    }
    
    return height;
}

//创建并显示每行的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SelfDuoBaoRecordInfo *info = [dataSourceArray objectAtIndex:indexPath.row];
    
    PurchaseRecordTableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:@"PurchaseRecordTableViewCell"];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PurchaseRecordTableViewCell" owner:nil options:nil];
        cell = [nib firstObject];
        MLog(@"nil cell");
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell reloadWithData:info ofUser:[ShareManager shareInstance].userinfo.id];
    
    cell.purchaseNextButtonInRunLottery.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        [self pushPurchaseAgain:info];
        
        return [RACSignal empty];
    }];
    cell.purchaseNextButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        [self pushPurchaseAgain:info];
        
        return [RACSignal empty];
    }];
    cell.purchaseMoreButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        [self pushPurchaseAgain:info];
        
        return [RACSignal empty];
    }];
    cell.moreRecordButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        DBNumViewController *vc = [[DBNumViewController alloc]initWithNibName:@"DBNumViewController" bundle:nil];
        [vc reloadWithData:info];
        vc.userId = [ShareManager shareInstance].userinfo.id;
        vc.goodId = info.id;
        vc.userName = [ShareManager shareInstance].userinfo.nick_name;
        vc.goodName = [NSString stringWithFormat:@"[第%@期]%@",info.good_period,info.good_name];
        [self.navigationController pushViewController:vc animated:YES];
        return [RACSignal empty];
    }];
    
    return cell;
}

- (void)pushPurchaseAgain:(SelfDuoBaoRecordInfo *)info
{
    if ([info isThriceGoods]) {
        
//        ThriceViewController *vc = [[ThriceViewController alloc] initWithTableViewStyleGrouped];
//        [self.navigationController pushViewController:vc animated:YES];
    } else {
        
        
        GoodsDetailInfoViewController *vc = [[GoodsDetailInfoViewController alloc]initWithNibName:@"GoodsDetailInfoViewController" bundle:nil];
        vc.goodId = info.id;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    SelfDuoBaoRecordInfo *info = [dataSourceArray objectAtIndex:indexPath.row];
    
    //    if (info.isThriceGoods == YES) {
    //
    //        ThriceViewController *vc = [[ThriceViewController alloc] initWithTableViewStyleGrouped];
    //        [self.navigationController pushViewController:vc animated:YES];
    //    } else {
    
    GoodsDetailInfoViewController *vc = [[GoodsDetailInfoViewController alloc]initWithNibName:@"GoodsDetailInfoViewController" bundle:nil];
    vc.goodId = info.id;
    //谷歌分析用户一般从哪里进入商品详情1
    [self.navigationController pushViewController:vc animated:YES];
    //    }
}

#pragma mark - 上下刷新
- (void)setTabelViewRefresh
{
    __unsafe_unretained UITableView *tableView = self.myTableView;
    __unsafe_unretained __typeof(self) weakSelf = self;
    // 下拉刷新
    tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        pageNum = 1;
        [weakSelf httpGetRecordList];
    }];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    tableView.mj_header.automaticallyChangeAlpha = YES;
    [tableView.mj_header beginRefreshing];
    // 上拉刷新
    tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf httpGetRecordList];
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


@end
