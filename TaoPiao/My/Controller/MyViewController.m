//
//  MyViewController.m
//  TaoPiao
//
//  Created by 黎应明 on 2017/8/30.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import "MyViewController.h"
#import "MyHeaderView.h"
#import "ClassifyTableViewCell.h"


//#import "BTBadgeView.h"
@interface MyViewController ()<BaseTableViewDelegate>

@end

@implementation MyViewController


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor purpleColor];
    
    MyHeaderView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"MyHeaderView" owner:nil options:nil] firstObject];
    headerView.width = ScreenWidth;
    headerView.height = 201 * UIAdapteRate;
    
    [headerView.headImage whenTapped:^{
        [self loginClick];
       
    }];

    self.tableView.tableHeaderView = headerView;
    self.navigationController.navigationBarHidden = YES;
    self.tableView.contentInset = UIEdgeInsetsZero;
    self.numOfSection = 2;
    self.hightForFooter = 20;
    
    
}

-(void)loginClick{

     [Tool loginWithAnimated:YES viewController:nil];

}

//tableViewDeteglate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0){
        return 4;
    }else{
    
        return 2;
    }
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIndentifier=@"cell";
   
    ClassifyTableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (cell == nil)
    {
        cell= [[[NSBundle  mainBundle]  loadNibNamed:@"ClassifyTableViewCell" owner:self options:nil]  firstObject];
    }
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                cell.desLabel.text = @"我的订单";
                break;
            case 1:
                cell.desLabel.text = @"我的心愿单";
                break;
            case 2:
                cell.desLabel.text = @"券豆商城";
                break;
            case 3:
                cell.desLabel.text = @"地址管理";
            break;
            default:
                break;
        }
    }else{
        switch (indexPath.row) {
            case 0:
                cell.desLabel.text = @"娱乐城";
                break;
            case 1:
                cell.desLabel.text = @"联系客服";
            break;
                
           
        }
    }

    return cell;
}
- (void)clickLeftControlAction:(id)sender{
   
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
               
                break;
            case 1:
               
                break;
            case 2:
               
                break;
            case 3:
               
                break;
            default:
                break;
        }
    }else{
        switch (indexPath.row) {
            case 0:
               
                break;
            case 1:{
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
                break;
                
            default:
                break;
               
        }
    }

}



@end
