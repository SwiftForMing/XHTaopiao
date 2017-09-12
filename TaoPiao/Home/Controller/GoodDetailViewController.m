//
//  GoodDetailViewController.m
//  TaoPiao
//
//  Created by 黎应明 on 2017/9/12.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import "GoodDetailViewController.h"
#import "GoodDetialHaderCell.h"
#import "GetCouponOneCell.h"
#import "GetCouponViewController.h"
#import "EditOrderViewController.h"
@interface GoodDetailViewController ()

@end

@implementation GoodDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"详情";
    [self setRightBarButtonItem:@"兑换"];
    [self setFootViewForPay];
}
#pragma mark - 实现rightBar点击方法
- (void)rightBarButtonItemAction:(id)sender
{
    MLog(@"放开我死胖子，我要去兑换");
    
}
#pragma mark - 创建底部视图
-(void)setFootViewForPay{
    UIView *buyFooterView = [[UIView alloc]initWithFrame:(CGRectMake(0, ScreenHeight-64-52, ScreenWidth, 52))];
    buyFooterView.backgroundColor = [UIColor whiteColor];
    UILabel *line = [[UILabel alloc]initWithFrame:(CGRectMake(0, 0, ScreenWidth, 2))];
    line.backgroundColor = [UIColor lightGrayColor];
    [buyFooterView addSubview:line];
    //客服
    UIButton *kfBtn = [[UIButton alloc]initWithFrame:(CGRectMake(0, 22, ScreenWidth/6, 30))];
    [kfBtn setTitle:@"客服" forState:0];
    kfBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [kfBtn setTitleColor:[UIColor blackColor] forState:0];
    kfBtn.backgroundColor = [UIColor whiteColor];
    [kfBtn addTarget: self action:@selector(kfBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [buyFooterView addSubview:kfBtn];
    //分享
    UIButton *fxBtn = [[UIButton alloc]initWithFrame:(CGRectMake(ScreenWidth/6, 22, ScreenWidth/6, 30))];
    [fxBtn setTitle:@"分享" forState:0];
    fxBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [fxBtn setTitleColor:[UIColor blackColor] forState:0];
    fxBtn.backgroundColor = [UIColor whiteColor];
    [fxBtn addTarget: self action:@selector(fxBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [buyFooterView addSubview:fxBtn];
    
    //喜欢
    UIButton *likeBtn = [[UIButton alloc]initWithFrame:(CGRectMake(ScreenWidth/3, 22, ScreenWidth/6, 30))];
    [likeBtn setTitle:@"喜欢" forState:0];
    likeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [likeBtn setTitleColor:[UIColor blackColor] forState:0];
    likeBtn.backgroundColor = [UIColor whiteColor];
    [likeBtn addTarget: self action:@selector(likeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [buyFooterView addSubview:likeBtn];
    
    UIButton *goPayBtn = [[UIButton alloc]initWithFrame:(CGRectMake(ScreenWidth/2, 2, ScreenWidth/2, 50))];
    [goPayBtn setTitle:@"立即购买" forState:0];
    [goPayBtn setTitleColor:[UIColor whiteColor] forState:0];
    goPayBtn.backgroundColor = [UIColor greenColor];
    [goPayBtn addTarget: self action:@selector(goPay) forControlEvents:UIControlEventTouchUpInside];
    [buyFooterView addSubview:goPayBtn];
    [self.view addSubview:buyFooterView];
}
#pragma mark -底部按钮点击事件
-(void)kfBtnClick{
    MLog(@"?????");
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *versionString = [NSString stringWithFormat:@"iOS %@", version];
    MQChatViewConfig *chatViewConfig = [MQChatViewConfig sharedConfig];
    
    MQChatViewController *chatViewController = [[MQChatViewController alloc] initWithChatViewManager:chatViewConfig];
    [chatViewConfig setEnableOutgoingAvatar:false];
    [chatViewConfig setEnableRoundAvatar:YES];
    chatViewConfig.navTitleColor = [UIColor whiteColor];
    chatViewConfig.navBarTintColor = [UIColor whiteColor];
    [chatViewConfig setStatusBarStyle:UIStatusBarStyleLightContent];
    
    chatViewController.title = @"客服";
    [chatViewConfig setNavTitleText:@"客服"];
    [chatViewConfig setCustomizedId:@"127537"];
    [chatViewConfig setEnableEvaluationButton:NO];
    [chatViewConfig setAgentName:@"客服"];
    [chatViewConfig setClientInfo:@{@"name":@"黎胖子", @"version": versionString, @"identify": @"大胖子", @"telephone": @"15309015564"}];
    [chatViewConfig setUpdateClientInfoUseOverride:YES];
    [chatViewConfig setRecordMode:MQRecordModeDuckOther];
    [chatViewConfig setPlayMode:MQPlayModeMixWithOther];
    [self.navigationController pushViewController:chatViewController animated:YES];
    UIControl *leftItemControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 20, 44)];
    [leftItemControl addTarget:self action:@selector(clickLeftControlAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *back = [[UIImageView alloc] initWithFrame:CGRectMake(0, 13, 10, 18)];
    back.image = [UIImage imageNamed:@"new_back"];
    [leftItemControl addSubview:back];
    
    chatViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftItemControl];

}
- (void)clickLeftControlAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)fxBtnClick{
    
    
    
}

-(void)likeBtnClick{
    
    
}
-(void)goPay{
    MLog(@"放开我 我要去付钱");
    MLog(@"payNum");
    EditOrderViewController *vc = [[EditOrderViewController alloc]initWithTableViewStyle:1];
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
            GoodDetialHaderCell *cell = nil;
            cell = [tableView dequeueReusableCellWithIdentifier:@"GoodDetialHaderCell"];
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GoodDetialHaderCell" owner:nil options:nil];
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
                GetCouponOneCell *cell = nil;
                cell = [tableView dequeueReusableCellWithIdentifier:@"GetCouponOneCell"];
                if (cell == nil)
                {
                    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GetCouponOneCell" owner:nil options:nil];
                    cell = [nib objectAtIndex:0];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                }
                cell.goodModel = _goodModel;
                cell.getCouponBtn.hidden = NO;
                [cell.getCouponBtn addTarget:self action:@selector(getCoupon) forControlEvents:UIControlEventTouchUpInside];
                return cell;
            }
            break;
        default:
            return nil;
            break;
        }
            
            
    }
    
}

-(void)getCoupon{

    GetCouponViewController *vc = [[GetCouponViewController alloc]initWithTableViewStyle:0];
    vc.goodModel = _goodModel;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
      return 10;
    }else{
        return 0.001;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.section) {
        case 0:
        {
            return 400;
        }
            break;
        case 1:
        {
            return 130;
        }
            break;
            
        default:
            return 0;
            break;
    }
    
}
@end
