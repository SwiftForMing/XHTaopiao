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
#import "PaySelectedController.h"
#import "CZRecordListViewController.h"

#import "MyOrderListViewController.h"
@interface ChooseViewController (){

    NSString *ZFBSelectImage;
    NSString *WXSelectImage;
    NSString *payWay;

}
@property (nonatomic, strong) PaySelectedController *paySelectedController;
@end

@implementation ChooseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择付款方式";
    ZFBSelectImage = @"icon_checkbox_circle_selected";
    WXSelectImage = @"checkbox_circle_red_normal";
    self.tableView.backgroundColor =  [[UIColor alloc]initWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1];
//    self.view.backgroundColor = [UIColor clearColor];
    PaySelectedController *tableViewController = [[PaySelectedController alloc] initWithNibName:@"PaySelectedController" bundle:nil];
    [self.view addSubview:tableViewController.tableView];
    [self addChildViewController:tableViewController];
    tableViewController.tableView.top = self.tableView.top + 60;
    _paySelectedController = tableViewController;
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(payNotifi:)
                                                name:kPaySuccess
                                              object:nil];

}
#pragma mark 支付结果处理逻辑
- (void)payNotifi:(NSNotification *)notification{
    NSDictionary * infoDic = [notification object];
    NSString *states = infoDic[@"resultStatue"];
    // 这样就得到了我们在发送通知时候传入的字典了
     NSString *message = nil;
    if ([states isEqualToString:@"9000"]) {

        MyOrderListViewController *vc = [[MyOrderListViewController alloc]initWithTableViewStyle:1];
        [self.navigationController pushViewController:vc animated:YES];
    }
    if ([states isEqualToString:@"8000"]) {

        message =  @"正在处理中,请稍候查看！";
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"支付提示" message:message delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alter show];
    }

//    if ([states isEqualToString:@"4000"]) {
//        message = @"很遗憾，您此次支付失败，请您重新支付！";
//        [Tool showPromptContent:message onView:self.view];
//    }
//
//    if ([states isEqualToString:@"6001"]) {
////         [Tool showPromptContent:@"您已取消了支付操作！" onView:self.window];
//        message = @"您已取消了支付操作！";
//        [Tool showPromptContent:message onView:self.view];
//    }
//    if ([states isEqualToString:@"6002"]) {
////        [Tool showPromptContent:@"网络连接出错，请您重新支付！" onView:self.window];
//        message = @"网络连接出错，请您重新支付！";
//        [Tool showPromptContent:message onView:self.view];
//    }
//
    
}


#pragma mark tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
//    return 3;
    return 1;
    
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
    
    return 200;

}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *footerView = [[UIView alloc]initWithFrame:(CGRectMake(0, 0, ScreenWidth, 200))];
    footerView.backgroundColor = [UIColor clearColor];
    
    UIButton *payBtn = [[UIButton alloc]initWithFrame:(CGRectMake(30, 130, ScreenWidth-60, 40))];
    payBtn.backgroundColor = [UIColor greenColor];
    [payBtn setTitle:@"确定" forState:0];
    [payBtn setTitleColor:[UIColor whiteColor] forState:0];
    payBtn.layer.masksToBounds = YES;
    payBtn.layer.cornerRadius = 5;
    [payBtn addTarget:self action:@selector(payForGood) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:payBtn];
    return footerView;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _paySelectedController.tableView.contentOffset = self.tableView.contentOffset;
    
    _paySelectedController.view.frame = CGRectMake(0, -self.tableView.contentOffset.y+60, _paySelectedController.view.frame.size.width, _paySelectedController.view.frame.size.height);
}

#pragma mark 点击确定按钮支付
-(void)payForGood{

    
    if ([ShareManager shareInstance].isInReview == YES) {
        
        NSString *url = [NSString stringWithFormat:@"%@%@user_id=%@&goods_fight_ids=%@&goods_buy_nums=%@&is_shop_cart=%@",URL_Server,Wap_PayMoneyView,[ShareManager shareInstance].userinfo.id, @"234",@"5",@"n"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        
    }else{
        [self httpGetPayOrderInfo];
    }

}

//支付成功页面
- (void)presentCZSuccessVC
{
    MLog(@"zhifu成功%@",_goodModel.good_price);
//    //进度支付结果页面
//    CZResultViewController *vc = [[CZResultViewController alloc]initWithNibName:@"CZResultViewController" bundle:nil];
//    vc.allMoney = [_goodModel.good_price doubleValue];
//    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
//    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
    
}

#pragma mark -

//获取订单号
- (void)httpGetPayOrderInfo
{
    NSString *purchasePermission = [_paySelectedController paymentPermission:[_goodModel.good_price doubleValue]];
    if (![purchasePermission isEqualToString:@"allow"]) {
        [Tool showPromptContent:purchasePermission];
        return;
    }
    
    __block typeof(self) wself = self;
    
    [_paySelectedController getZFBOrderWithModel:_goodModel num:_num type:_type completion:^(BOOL result, NSString *description, NSDictionary *dict) {
        if (result) {
            [wself presentCZSuccessVC];
        } else {
            [Tool showPromptContent:description onView:self.view];
        }
    }];
    
}

/**
 *  处理支付结果
 */
- (void)handlePayResultNotification:(NSDictionary *)userInfo
{
    NSString *message = nil;
    NSString *resultCode = (NSString*)[userInfo objectForKey:@"resCode"];
    if ([resultCode isEqualToString:@"00"] ||[resultCode isEqualToString:@"9000"]) {
        
        [self presentCZSuccessVC];
    }
    else if ([resultCode isEqualToString:@"01"] || [resultCode isEqualToString:@"4000"])
    {
        message = @"很遗憾，您此次支付失败，请您重新支付！";
        [Tool showPromptContent:message onView:self.view];
        
    }else if([resultCode isEqualToString:@"02"] || [resultCode isEqualToString:@"6001"]){
        message = @"您已取消了支付操作！";
        [Tool showPromptContent:message onView:self.view];
        
    }else if([resultCode isEqualToString:@"8000"]){
        message =  @"正在处理中,请稍候查看！";
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"支付提示" message:message delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alter show];
        
        
    }else if([resultCode isEqualToString:@"6002"]){
        message = @"网络连接出错，请您重新支付！";
        [Tool showPromptContent:message onView:self.view];
        
    }
    
}



@end
