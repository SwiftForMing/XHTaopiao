//
//  ClassifyTableViewController.m
//  TaoPiao
//
//  Created by 黎应明 on 2017/9/6.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import "ClassifyTableViewController.h"
#import "GoodTypeModel.h"
#import "HomeTopCell.h"
@interface ClassifyTableViewController ()
{
    NSMutableArray *_dataArray;
    
}
@end

@implementation ClassifyTableViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [NSMutableArray array];
    self.title = self.goodTitle;
    [self getData];
    self.numOfSection = 2;
    self.hightForFooter = 20;
}

-(void)getData{
    
    HttpHelper *helper = [HttpHelper helper];
    __weak ClassifyTableViewController *weakSelf = self;
    [helper getSearchIDDataWithID:self.goodID
                      success:^(NSDictionary *resultDic){
                          if ([[resultDic objectForKey:@"status"] integerValue] == 0) {
                              [weakSelf handleloadResult:resultDic];
                          }
                      }fail:^(NSString *decretion){
                          [Tool showPromptContent:@"网络出错了" onView:weakSelf.view];
                      }];
}

- (void)handleloadResult:(NSDictionary *)resultDic
{
    NSDictionary *dic = [resultDic objectForKey:@"data"];
    //推荐
    NSArray *tabArr = [dic objectForKey:@"goodsTypeList"];
    
    if (tabArr && tabArr.count > 0) {
        
        if (_dataArray.count > 0) {
            [_dataArray removeAllObjects];
        }
        
        for (NSDictionary *dict in tabArr)
        {
            HomeGoodModel* model = [dict objectByClass:[HomeGoodModel class]];
            
            [_dataArray addObject:model];
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
    
        return _dataArray.count;
   
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
                //设点点击选择的颜色(无)
                HomeGoodModel *model = [_dataArray objectAtIndex:indexPath.row];
                cell.goodModel = model;
                [cell.lqBtn setTitle:@"立即买劵" forState:0];
                cell.lqBtn.tag = indexPath.row;
                [cell.lqBtn addTarget:self action:@selector(getCoupon:) forControlEvents:UIControlEventTouchUpInside];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            return cell;
    
    }
//点击立即领卷的操作
-(void)getCoupon:(UIButton *)btn{

    MLog(@"btnTag%ld",(long)btn.tag);

    

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
            return 140;
}



@end
