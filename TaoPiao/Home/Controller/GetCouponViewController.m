//
//  GetCouponViewController.m
//  TaoPiao
//
//  Created by 黎应明 on 2017/9/12.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import "GetCouponViewController.h"
#import "HomeGoodModel.h"
#import "GetCouponOneCell.h"
#import "GetCouponTwoCell.h"
#import "EditOrderViewController.h"
#import "ChooseViewController.h"
@interface GetCouponViewController ()
{
    int payNum;

}
@property (strong,nonatomic)UILabel *moneyLabel;

@end

@implementation GetCouponViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    payNum = 1;
    self.title = @"领卷";
    self.tableView.backgroundColor =  [[UIColor alloc]initWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1];
    [self setFootViewForPay];
}


#pragma mark - 创建底部视图
-(void)setFootViewForPay{
    UIView *buyFooterView = [[UIView alloc]initWithFrame:(CGRectMake(0, ScreenHeight-64-60, ScreenWidth, 60))];
    _moneyLabel = [[UILabel alloc]initWithFrame:(CGRectMake(10, 5, ScreenWidth -130, 50))];
    _moneyLabel.text = [NSString stringWithFormat:@"应付：¥%@",[NSString stringWithFormat:@"%.2f",[_goodModel.coupons_value floatValue]*payNum]];
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
    ChooseViewController *vc = [[ChooseViewController alloc]initWithTableViewStyle:1];
    _goodModel.good_price = [NSString stringWithFormat:@"%.2f",[_goodModel.coupons_value floatValue]*payNum];
    vc.goodModel = _goodModel;
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - tableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return  2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return 1;
    
}
//创建并显示每行的内容

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            GetCouponOneCell *cell = nil;
            cell = [tableView dequeueReusableCellWithIdentifier:@"GetCouponOneCell"];
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GetCouponOneCell" owner:nil options:nil];
                cell = [nib objectAtIndex:0];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;

            }
            cell.goodModel = _goodModel;
            return cell;
        }
            break;
        case 1:
        {
            {
                GetCouponTwoCell *cell = nil;
                cell = [tableView dequeueReusableCellWithIdentifier:@"GetCouponTwoCell"];
                if (cell == nil)
                {
                    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GetCouponTwoCell" owner:nil options:nil];
                    cell = [nib objectAtIndex:0];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                cell.numLabel.text = [NSString stringWithFormat:@"%d",payNum];
                cell.subBtn.tag = 100;
                [cell.subBtn addTarget:self action:@selector(payNumSelect:) forControlEvents:UIControlEventTouchUpInside];
                cell.addBtn.tag = 101;
                [cell.addBtn addTarget:self action:@selector(payNumSelect:) forControlEvents:UIControlEventTouchUpInside];
                int money = [_goodModel.coupons_value intValue];
                cell.beanNumLabel.text = [NSString stringWithFormat:@"赠%d豆",payNum*money];
                return cell;
            }
            break;
        default:
            return nil;
            break;
        }
            
            
    }

}
#pragma mark - 购买数量
-(void)payNumSelect:(UIButton *)btn{
    
    if (btn.tag == 100) {
        if (payNum == 0) {
            payNum = 0;
            _moneyLabel.text = @"应付: ¥0.00";
        }else{
            payNum--;
            NSString *str = [NSString stringWithFormat:@"应付: ¥%d.00",payNum*[_goodModel.coupons_value intValue]];
             _moneyLabel.text = str;
        }
    }else{
        payNum++;
        NSString *str = [NSString stringWithFormat:@"应付: ¥%d.00",payNum*[_goodModel.coupons_value intValue]];
        _moneyLabel.text = str;
    }
    //刷新
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:1];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
           return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{

    if (section == 1) {
        return 30;
    }else{
    
        return 0.0001;
    }
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 1) {
        UIView *footView = [[UIView alloc]initWithFrame:(CGRectMake(0, 0, ScreenWidth, 30))];
        footView.backgroundColor = [[UIColor alloc]initWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1];
        UIImageView *electImageView = [[UIImageView alloc]initWithFrame:(CGRectMake(10, 7.5, 15, 15))];
        electImageView.image = [UIImage imageNamed:@"icon_checkbox_selected"];
        electImageView.contentMode = UIViewContentModeScaleAspectFill;
        [footView addSubview:electImageView];
        
        UILabel *desLabel = [[UILabel alloc]initWithFrame:(CGRectMake(25, 5, ScreenWidth-50,20))];
        NSString *str = @"我也阅读并同意《淘卷服务协议》";
        NSMutableAttributedString *astr = [[NSMutableAttributedString alloc]initWithString:str];
        [astr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:[str rangeOfString:@"《淘卷服务协议》"]];
         [astr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:[str rangeOfString:str]];
         [astr addAttribute:NSStrokeColorAttributeName value:[UIColor lightGrayColor]range:[str rangeOfString:str]];
        desLabel.attributedText = astr;
        [footView addSubview:desLabel];
        return  footView;
    }else{
        
        return nil;
    }

}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
   
        UIView *headerView = [[UIView alloc]initWithFrame:(CGRectMake(0, 0, ScreenWidth, 30))];
        headerView.backgroundColor = [[UIColor alloc]initWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1];
        return headerView;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.section) {
        case 0:
        {
            return 130;
        }
            break;
        case 1:
        {
            return 100;
        }
            break;
 
        default:
            return 0;
            break;
    }
    
}


@end
