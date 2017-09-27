//
//  EntOrderViewController.m
//  TaoPiao
//
//  Created by 黎应明 on 2017/9/26.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import "EntOrderViewController.h"
#import "ClassifyTableViewCell.h"
#import "AgreementCheckbox.h"
#import "FooterButtonView.h"
#import "EntBuyViewController.h"
#import "PaySuccessTableViewController.h"
@interface EntOrderViewController ()
@property (nonatomic, strong) AgreementCheckbox *agreementCheckbox;
@property (nonatomic) BOOL footerButtonHasTapped;
@property (nonatomic, strong) UIButton *footerButton;
@end

@implementation EntOrderViewController

+ (EntOrderViewController *)createWithData:(NSDictionary *)data
{
    EntOrderViewController *vc = [[EntOrderViewController alloc]initWithTableViewStyle:1];
    vc.data = data;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"支付订单";
    FooterButtonView *footerView = [[FooterButtonView alloc] initWithTitle:@"立即购买"];
    [footerView.button addTarget:self action:@selector(footerButtonAction) forControlEvents:UIControlEventTouchUpInside];
    _footerButton = footerView.button;
    self.tableView.tableFooterView = footerView;
    
}
- (void)footerButtonAction
{
    MLog(@"购买");
    if (_footerButtonHasTapped) {
        return;
    }
    _footerButtonHasTapped = YES;
    
   
    
    NSDictionary *dict = _data;
    NSString *goods_fight_ids = [dict objectForKey:@"id"];
    NSString *goods_ids = [dict objectForKey:@"good_id"];
    NSString *buyType = @"now";
    MLog(@"我还有好多钱%f",[ShareManager shareInstance].userinfo.user_money);
    
     int crowdfundingBettingCount = [[dict objectForKey:@"Crowdfunding"] intValue]*BeanExchangeRate;
    
    if ([ShareManager shareInstance].userinfo.user_money<crowdfundingBettingCount) {
        EntBuyViewController *vc = [[EntBuyViewController alloc]initWithTableViewStyle:1];
        [self.navigationController pushViewController:vc animated:YES];
    
    }else{
        [HttpHelper purchaseGoodsFightID:goods_fight_ids count:crowdfundingBettingCount thricePurchase:@[] isShopCart:@"" coupon:@"" exchangedThriceCoin:0 goodsID:goods_ids buyType:buyType success:^(NSDictionary *data) {
            
             if ([[data objectForKey:@"status"] integerValue] == 0) {
                 
            [ShareManager shareInstance].userinfo.user_money  = [ShareManager shareInstance].userinfo.user_money - crowdfundingBettingCount;
                 
                 MLog(@"crowdfundingBettingCount%f",[ShareManager shareInstance].userinfo.user_money);
            [Tool showPromptContent:@"购买成功" onView:self.view];
                 NSMutableDictionary *psDate = [NSMutableDictionary dictionary];
                 [psDate setDictionary:_data];
                 
                 [psDate setValue:@"success" forKey:@"result"];
                 
            PaySuccessTableViewController *vc = [PaySuccessTableViewController createWithData:psDate];
            [self.navigationController pushViewController:vc animated:YES];
                 
             }
        } failure:^(NSString *description) {
            [Tool showPromptContent:description onView:self.view];
        }];
        
    }
   
    
    
}
//tableViewDeteglate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIndentifier=@"cell";
    tableView.rowHeight = 60;
    ClassifyTableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (cell == nil)
    {
        cell= [[[NSBundle  mainBundle]  loadNibNamed:@"ClassifyTableViewCell" owner:self options:nil]  firstObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.row == 0) {
        cell.desLabel.text = [NSString stringWithFormat:@"参与%@欢乐豆抽奖",_data[@"good_name"]];;
    } else if (indexPath.row == 1){
        cell.desLabel.text = @"参与方式:欢乐豆抽奖";
    }else{
        cell.desLabel.text = [NSString stringWithFormat:@"消耗欢乐豆%d",[_data[@"Crowdfunding"] intValue]*BeanExchangeRate];
    }
    return cell;
}


- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section   
{
    UIView *view = nil;
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 50)];
        // Tabel section separation line
        UIImageView *separationLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, ScreenWidth, 0.5)];
        separationLine.backgroundColor = [UIColor defaultTableViewSeparationColor];
        [view addSubview:separationLine];
        
        // 服务协议
        if (_agreementCheckbox == nil) {
            _agreementCheckbox = [[AgreementCheckbox alloc] initWithController:self];
        }
        
        AgreementCheckbox *checkboxView = _agreementCheckbox;
        checkboxView.centerX = view.width / 2;
        checkboxView.top = 0;
        [view addSubview:_agreementCheckbox];
    return view;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 50;
    
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;    // fixed font style. use custom view (UILabel) if you want something different
{
    NSString *str = nil;
        str = @"订单详情";
    return str;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 40;
    
}
@end
