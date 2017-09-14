//
//  TadayDiscountViewController.m
//  TaoPiao
//
//  Created by 黎应明 on 2017/9/13.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import "TadayDiscountViewController.h"
#import "HomeGoodModel.h"
#import "HomeTopCell.h"
#import "GetCouponViewController.h"
@interface TadayDiscountViewController (){

    NSMutableArray *discountArray;
}

@end

@implementation TadayDiscountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"今日特惠";
    discountArray = [NSMutableArray array];
    [self getData];
    
}
-(void)getData{
    MLog(@"TadayDiscountViewController");
    __weak TadayDiscountViewController *weakSelf = self;
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
    NSArray *goodArray = [dic objectForKey:@"todayDiscount"];
    if (goodArray && goodArray.count > 0) {
        if (discountArray.count > 0) {
            [discountArray removeAllObjects];
        }
        for (NSDictionary *dic in goodArray)
        {
        
            HomeGoodModel *info = [dic objectByClass:[HomeGoodModel class]];
            [discountArray addObject:info];
        }
    }
    [self.tableView reloadData];
}
#pragma mark tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return discountArray.count;
}
//创建并显示每行的内容

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
            HomeGoodModel *model = [discountArray objectAtIndex:indexPath.row];
            cell.goodModel = model;
            [cell.lqBtn addTarget:self action:@selector(lqBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            cell.lqBtn.tag = indexPath.row;
            return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 140;
    
}

#pragma mark - 领取操作
-(void)lqBtnClick:(UIButton *)btn{
    GetCouponViewController *vc = [[GetCouponViewController alloc]initWithTableViewStyle:0];
    vc.goodModel = [discountArray objectAtIndex:btn.tag];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
