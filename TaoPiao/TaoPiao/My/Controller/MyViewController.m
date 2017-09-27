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
#import "UserInfoViewController.h"
#import "MyOrderListViewController.h"
#import "EntBuyViewController.h"
#import "EntHomeViewController.h"
//#import "WHCScrollVC.h"
//#import "BTBadgeView.h"
#import "HomePageViewController.h"
@interface MyViewController ()<BaseTableViewDelegate>
@property (nonatomic, strong) MyHeaderView *headerView;
@end

@implementation MyViewController


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    if ([ShareManager shareInstance].userinfo) {
        
        _headerView.userInfo = [ShareManager shareInstance].userinfo;
    }else{
    
        MLog(@"ShareManager我还没数据");
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    MyHeaderView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"MyHeaderView" owner:nil options:nil] firstObject];
    headerView.width = ScreenWidth;
    headerView.height = 150 * UIAdapteRate;
    _headerView = headerView;
    [_headerView.bgView whenTapped:^{
        [self profileAction];
    }];
    [_headerView.headImage whenTapped:^{
        [self loginClick];
    }];

    self.tableView.tableHeaderView = _headerView;
    self.navigationController.navigationBarHidden = YES;
    self.tableView.contentInset = UIEdgeInsetsZero;
    self.numOfSection = 2;
    
    
    
}

-(void)loginClick{
    
     [Tool loginWithAnimated:YES viewController:nil];
    
}

- (void)profileAction
{
    
    if (![Tool islogin]) {
        [Tool loginWithAnimated:YES viewController:nil];
        return;
    }
    UserInfoViewController *vc = [[UserInfoViewController alloc]initWithNibName:@"UserInfoViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
    
}


#pragma mark - notif Action

- (void)registerNotif
{
    /**
     *  监听网络状态变化
     */
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(checkNetworkStatus:)
//                                                 name:kReachableNetworkStatusChange
//                                               object:nil];
    
    //刷新首页数据
//    [[NSNotificationCenter defaultCenter]addObserver:self
//                                            selector:@selector(quitLoginReload)
//                                                name:kQuitLoginSuccess
//                                              object:nil];
    
    
    //我的tab点击事件
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(updateUserInfoFromServer)
                                                name:kLoginSuccess
                                              object:nil];
    
   }

- (void)updateUserInfoFromServer
{
//    [self updateUserInterface];
//    [self httpUserInfo];
}

- (void)httpUserInfo
{
    if (![ShareManager shareInstance].userinfo.islogin) {
        return;
    }
//    HttpHelper *helper = [HttpHelper helper];
//    __weak MyViewController *weakSelf = self;
//    [HttpHelper getUserInfoWithUserId:[ShareManager shareInstance].userinfo.id
//                          success:^(NSDictionary *resultDic){
//                              
//                              if ([[resultDic objectForKey:@"status"] integerValue] == 0)
//                              {
//                                  [weakSelf handleloadUserInfoResult:[resultDic objectForKey:@"data"]];
//                              }else{
//                                  [Tool showPromptContent:[resultDic objectForKey:@"desc"] onView:self.view];
//                              }
//                              
//                          }fail:^(NSString *decretion){
//                              [Tool showPromptContent:@"网络出错了" onView:self.view];
//                          }];
}

- (void)handleloadUserInfoResult:(NSDictionary *)resultDic
{
    UserInfo *info = [resultDic objectByClass:[UserInfo class]];
    [ShareManager shareInstance].userinfo = info;
    [Tool saveUserInfoToDB:YES];
    [self.tableView reloadData];
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                cell.desLabel.text = @"我的订单";
                break;
            case 1:
                cell.desLabel.text = @"我的心愿";
                break;
            case 2:
                cell.desLabel.text = @"券豆商城";
                break;
            case 3:
                cell.desLabel.text = @"娱乐城";
            break;
            default:
                break;
        }
    }else{
        switch (indexPath.row) {
            case 0:
                cell.desLabel.text = @"联系客服";
                break;
            case 1:
               cell.desLabel.text = @"关于我们";
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
            {
                MyOrderListViewController *vc = [[MyOrderListViewController alloc]initWithTableViewStyle:1];
                [self.navigationController pushViewController:vc animated:YES];
            
            }
                break;
            case 1:
               
                break;
            case 2:
               
                break;
            case 3:
            {
                HomePageViewController *homePageVC = [[HomePageViewController alloc] initWithNibName:@"HomePageViewController" bundle:nil];
//                EntHomeViewController *vc = [[EntHomeViewController alloc]init];
                [self.navigationController pushViewController:homePageVC animated:YES];
                
            }
                break;
            default:
                break;
        }
    }else{
        switch (indexPath.row) {
            case 1:
               
                break;
            case 0:{
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return 10;

}

@end
