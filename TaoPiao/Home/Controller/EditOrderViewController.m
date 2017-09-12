//
//  EditOrderViewController.m
//  TaoPiao
//
//  Created by 黎应明 on 2017/9/12.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import "EditOrderViewController.h"
#import "EditAddressCell.h"
#import "SimGoodCell.h"
#import "HaveCouponCell.h"
#import "GoodPriceCell.h"
#import "AddAddressViewController.h"
@interface EditOrderViewController (){
    int payNum;
    
}
@property (strong,nonatomic)UILabel *moneyLabel;
@end

@implementation EditOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    payNum = 1;
    self.title = @"填写订单";
    self.tableView.backgroundColor =  [[UIColor alloc]initWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1];
    [self setFootViewForPay];
    
}

#pragma mark - 创建底部视图
-(void)setFootViewForPay{
    UIView *buyFooterView = [[UIView alloc]initWithFrame:(CGRectMake(0, ScreenHeight-64-60, ScreenWidth, 60))];
    _moneyLabel = [[UILabel alloc]initWithFrame:(CGRectMake(10, 5, ScreenWidth -130, 50))];
    _moneyLabel.text = [NSString stringWithFormat:@"应付：¥%.2f",[_goodModel.good_price floatValue]*payNum];
    [buyFooterView addSubview:_moneyLabel];
    buyFooterView.backgroundColor = [UIColor whiteColor];
    
    UIButton *goPayBtn = [[UIButton alloc]initWithFrame:(CGRectMake(ScreenWidth -130, 0, 130, 60))];
    [goPayBtn setTitle:@"去付款" forState:0];
    [goPayBtn setTitleColor:[UIColor whiteColor] forState:0];
    goPayBtn.backgroundColor = [UIColor greenColor];
    [goPayBtn addTarget: self action:@selector(goPay) forControlEvents:UIControlEventTouchUpInside];
    [buyFooterView addSubview:goPayBtn];
    [self.view addSubview:buyFooterView];
}
#pragma mark -跳转到付款页面
-(void)goPay{
    MLog(@"放开我 我要去付钱");
    MLog(@"payNum:%d",payNum);
}

#pragma mark tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 4;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
        return 1;
    
}

//创建并显示每行的内容

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            if ([ShareManager shareInstance].userinfo) {
                EditAddressCell *cell = nil;
                cell = [tableView dequeueReusableCellWithIdentifier:@"EditAddressCell"];
                if (cell == nil)
                {
                    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"EditAddressCell" owner:nil options:nil];
                    cell = [nib objectAtIndex:0];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                }
                
                return cell;
                
            }else{
                UITableViewCell *cell = nil;
                cell = [tableView dequeueReusableCellWithIdentifier:@"AddressCell"];
                if (cell == nil)
                {
                    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddressCell"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                }
                UILabel *label = [[UILabel alloc]initWithFrame:(CGRectMake(0, 0, ScreenWidth, cell.frame.size.height))];
                label.text = @"添加地址";
                label.font = [UIFont systemFontOfSize:20];
                label.textColor = [[UIColor alloc]initWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1];
                label.textAlignment = NSTextAlignmentCenter;
                label.backgroundColor = [UIColor whiteColor];
                [cell addSubview:label];
                return cell;
            
            }
            
        }
            break;
        case 1:
        {
            SimGoodCell *cell = nil;
            cell = [tableView dequeueReusableCellWithIdentifier:@"SimGoodCell"];
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SimGoodCell" owner:nil options:nil];
                cell = [nib objectAtIndex:0];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
            }
            cell.goodModel = _goodModel;
            return cell;
        }
            break;
        case 2:
        {
            HaveCouponCell *cell = nil;
            cell = [tableView dequeueReusableCellWithIdentifier:@"HaveCouponCell"];
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HaveCouponCell" owner:nil options:nil];
                cell = [nib objectAtIndex:0];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
            }
            
            return cell;
        }
            break;
        default:
        {
            GoodPriceCell *cell = nil;
            cell = [tableView dequeueReusableCellWithIdentifier:@"GoodPriceCell"];
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GoodPriceCell" owner:nil options:nil];
                cell = [nib objectAtIndex:0];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
            }
            cell.goodModel = _goodModel;
            return cell;
           
        }
            break;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.section) {
        case 0:
            return 80;
            break;
        case 1:
            return 100;
            break;
        case 2:
            return 50;
            break;
        case 3:
            return 100;
            break;
        default:
            return 140;
            break;
    }
    
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        AddAddressViewController *vc = [[AddAddressViewController alloc]initWithTableViewStyle:1];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

@end
