//
//  ChooseViewController.m
//  TaoPiao
//
//  Created by 黎应明 on 2017/9/13.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import "ChooseViewController.h"
#import "ChoosePayWayCell.h"
#import "HaveCouponCell.h"
#import "PayTableViewController.h"
#import "CZViewController.h"
@interface ChooseViewController (){

    NSString *ZFBSelectImage;
    NSString *WXSelectImage;
    NSString *payWay;
}

@end

@implementation ChooseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择付款方式";
    ZFBSelectImage = @"icon_checkbox_circle_selected";
    WXSelectImage = @"checkbox_circle_red_normal";
    self.tableView.backgroundColor =  [[UIColor alloc]initWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1];
}




#pragma mark tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 3;
    
}

//创建并显示每行的内容

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        tableView.rowHeight = 50;
        HaveCouponCell *cell = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:@"HaveCouponCell"];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HaveCouponCell" owner:nil options:nil];
            cell = [nib objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.goodModel = _goodModel;
        return cell;
    }else{
        tableView.rowHeight = 70;
        ChoosePayWayCell *cell = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:@"ChoosePayWayCell"];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChoosePayWayCell" owner:nil options:nil];
            cell = [nib objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if (indexPath.row == 1) {
            cell.payWayImageView.image = [UIImage imageNamed:@"icon_alipay"];
            cell.payWayLabel.text = @"支付宝";
            cell.chooseBtn.image = [UIImage imageNamed:ZFBSelectImage];
        }else{
            cell.payWayImageView.image = [UIImage imageNamed:@"icon_wechat"];
            cell.payWayLabel.text = @"微信";
            cell.chooseBtn.image = [UIImage imageNamed:WXSelectImage];
        }
        return cell;
    }
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 1&&![ZFBSelectImage isEqualToString:@"icon_checkbox_circle_selected"]) {
        NSString *change = ZFBSelectImage;
        ZFBSelectImage = WXSelectImage;
        WXSelectImage = change;
        [tableView reloadData];
    }
    if (indexPath.row == 2&&![WXSelectImage isEqualToString:@"icon_checkbox_circle_selected"]) {
        NSString *change = ZFBSelectImage;
        ZFBSelectImage = WXSelectImage;
        WXSelectImage = change;
        [tableView reloadData];
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 100;

}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *footerView = [[UIView alloc]initWithFrame:(CGRectMake(0, 0, ScreenWidth, 100))];
    footerView.backgroundColor = [UIColor clearColor];
    
    UIButton *payBtn = [[UIButton alloc]initWithFrame:(CGRectMake(30, 30, ScreenWidth-60, 40))];
    payBtn.backgroundColor = [UIColor greenColor];
    [payBtn setTitle:@"确定" forState:0];
    [payBtn setTitleColor:[UIColor whiteColor] forState:0];
    payBtn.layer.masksToBounds = YES;
    payBtn.layer.cornerRadius = 5;
    [payBtn addTarget:self action:@selector(payForGood) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:payBtn];
    return footerView;
}
#pragma mark 点击确定按钮支付
-(void)payForGood{
    if ([ZFBSelectImage isEqualToString:@"icon_checkbox_circle_selected"]) {
        payWay = @"支付宝支付";
           }else{
        payWay = @"微信支付";
    }
    
    CZViewController *vc = [[CZViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];

    MLog(@"payWay%@",payWay);

}


@end
