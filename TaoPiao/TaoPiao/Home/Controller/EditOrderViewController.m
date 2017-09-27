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
#import "ChooseViewController.h"
#import "ReciverAddressViewController.h"


#import "ExpressModel.h"
#import "BuyCouponModel.h"
#import "BuyGoodModel.h"
#import "MyOrderListViewController.h"
#import "OrderAddressModel.h"
@interface EditOrderViewController ()<ReciverAddressViewControllerDelegate>{
    int payNum;
    NSMutableArray *dataSoureArray;
    NSMutableArray *addressArray;//地址
    NSMutableArray *proviceArray;
    NSMutableArray *expressArray; //快递
    NSMutableArray *couponArray;//优惠券
    NSMutableArray *goodsArray;//优惠券
    NSString *price;
    
}

@property (strong,nonatomic)UILabel *moneyLabel;
@end

@implementation EditOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    payNum = 1;
    dataSoureArray = [NSMutableArray array];
    proviceArray = [NSMutableArray array];
    addressArray = [NSMutableArray array];
    expressArray = [NSMutableArray array];
    couponArray = [NSMutableArray array];
    goodsArray = [NSMutableArray array];
    
    self.title = @"填写订单";
    self.tableView.backgroundColor =  [[UIColor alloc]initWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1];
    [self getOrderDetial];
    [self setFootViewForPay];
}

-(void)getOrderDetial{
    __weak EditOrderViewController *weakSelf = self;
    [HttpHelper getDetialOrderWithGoodId:_goodModel.id type:@"b" buyNum:@"1" userId:[ShareManager shareInstance].userinfo.id success:^(NSDictionary *resultDic) {
        
        MLog(@"sharID%@,%@",[ShareManager shareInstance].userinfo.id,_goodModel.id);
        
        if ([[resultDic objectForKey:@"status"] integerValue] == 0) {
            [weakSelf handleloadResult:resultDic];
           
        }else
        {
            [Tool showPromptContent:[resultDic objectForKey:@"desc"] onView:self.view];
        }
     }fail:^(NSString *decretion){
        [Tool showPromptContent:@"网络出错了" onView:self.view];
    }];
}

- (void)handleloadResult:(NSDictionary *)resultDic
{
    NSString *needMoney= [[resultDic objectForKey:@"data"] objectForKey:@"all_price"];
    price = needMoney;
    _moneyLabel.textColor = [UIColor redColor];
     _moneyLabel.text = [NSString stringWithFormat:@"应付：¥%.2f",[price floatValue]];
    NSDictionary *address= [[resultDic objectForKey:@"data"] objectForKey:@"defaultAddress"];
    if (address)
    {
        MLog(@"address%@",address);
        if (addressArray.count > 0) {
            [addressArray removeAllObjects];
        }
        
        if ([address objectForKey:@"detail_address"]) {
            
            RecoverAddressListInfo *info = [address objectByClass:[RecoverAddressListInfo class]];
            
                [addressArray addObject:info];
           
        }
       
    }
    
    
    NSArray *exArray = [[resultDic objectForKey:@"data"] objectForKey:@"express_List"];
    if (exArray && exArray.count > 0)
    {
        if (expressArray.count > 0) {
            [expressArray removeAllObjects];
        }
        for (NSDictionary *dic in exArray)
        {
            ExpressModel *info = [dic objectByClass:[ExpressModel class]];
            [expressArray addObject:info];
            
        }
    }
    
    NSArray *couArray = [[resultDic objectForKey:@"data"] objectForKey:@"coupons_own_List"];
    if (couArray && couArray.count > 0)
    {
        if (couponArray.count > 0) {
            [couponArray removeAllObjects];
        }
        for (NSDictionary *dic in couArray)
        {
            BuyCouponModel *info = [dic objectByClass:[BuyCouponModel class]];
            [couponArray addObject:info];
            
        }
    }
    
    NSArray *gdArray = [[resultDic objectForKey:@"data"] objectForKey:@"goods_buy_List"];
    if (gdArray && gdArray.count > 0)
    {
        if (goodsArray.count > 0) {
            [goodsArray removeAllObjects];
        }
        for (NSDictionary *dic in gdArray)
        {
            BuyGoodModel *info = [dic objectByClass:[BuyGoodModel class]];
            [goodsArray addObject:info];
            
        }
    }

    
    [self.tableView reloadData];
}

#pragma mark - 创建底部视图
-(void)setFootViewForPay{
    UIView *buyFooterView = [[UIView alloc]initWithFrame:(CGRectMake(0, ScreenHeight-64-60, ScreenWidth, 60))];
    _moneyLabel = [[UILabel alloc]initWithFrame:(CGRectMake(10, 5, ScreenWidth -130, 50))];
    _moneyLabel.text = [NSString stringWithFormat:@"应付：¥%.2f",[price floatValue]];
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

    ChooseViewController *vc = [[ChooseViewController alloc]initWithTableViewStyle:1];
    _goodModel.good_price = [NSString stringWithFormat:@"%.2f",[price floatValue]];
    vc.num =[NSString stringWithFormat:@"%d",payNum];
    vc.type = @"b";
    vc.goodModel = _goodModel;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        return goodsArray.count;
}

//创建并显示每行的内容

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            if (addressArray.count>0) {
                EditAddressCell *cell = nil;
                cell = [tableView dequeueReusableCellWithIdentifier:@"EditAddressCell"];
                if (cell == nil)
                {
                    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"EditAddressCell" owner:nil options:nil];
                    cell = [nib objectAtIndex:0];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                RecoverAddressListInfo *info = [addressArray objectAtIndex:0];
                cell.addressModel = info;
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
            cell.buyModel = [goodsArray objectAtIndex:0];
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
            
            if (couponArray.count>0) {
                BuyCouponModel *model = [couponArray objectAtIndex:0];
                cell.buyCouponModel = model;
                _goodModel.coupons_id = model.id;
            }else{
            
            }
            cell.arrowImageView.hidden = YES;
            return cell;
        }
            break;
        case 3:{
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
        default:
        {
            UIView *footView = [[UIView alloc]initWithFrame:(CGRectMake(0, 0, ScreenWidth, 30))];
            footView.backgroundColor = [[UIColor alloc]initWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1];
            UIImageView *electImageView = [[UIImageView alloc]initWithFrame:(CGRectMake(10, 10, 10, 10))];
            electImageView.image = [UIImage imageNamed:@"icon_checkbox_selected"];
            electImageView.contentMode = UIViewContentModeScaleAspectFill;
            [footView addSubview:electImageView];
            
            UILabel *desLabel = [[UILabel alloc]initWithFrame:(CGRectMake(20, 5, ScreenWidth-50,20))];
            NSString *str = @"我也阅读并同意《淘卷服务协议》";
            NSMutableAttributedString *astr = [[NSMutableAttributedString alloc]initWithString:str];
            [astr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:[str rangeOfString:@"《淘卷服务协议》"]];
            [astr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:[str rangeOfString:str]];
            [astr addAttribute:NSStrokeColorAttributeName value:[UIColor lightGrayColor]range:[str rangeOfString:str]];
            desLabel.attributedText = astr;
            [footView addSubview:desLabel];
            
            UITableViewCell *cell = nil;
            cell = [tableView dequeueReusableCellWithIdentifier:@"ruler"];
            if (cell == nil)
            {
               
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ruler"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [cell addSubview:footView];
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
        case 4:
            return 30;
            break;
        default:
            return 140;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        ReciverAddressViewController *vc = [[ReciverAddressViewController alloc]init];
        vc.isSelectAddress = YES;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}

- (void)selectAddressWithInfo:(RecoverAddressListInfo *)info{

    [addressArray addObject:info];
    [self.tableView reloadData];

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}



@end
