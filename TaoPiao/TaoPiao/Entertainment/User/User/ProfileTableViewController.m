//
//  ProfileTableViewController.m
//  DuoBao
//
//  Created by clove on 2/10/17.
//  Copyright © 2017 linqsh. All rights reserved.
//

#import "ProfileTableViewController.h"

#import "DuoBaoRecordViewController.h"
#import "ZJRecordViewController.h"
#import "ShaiDanViewController.h"
//#import "JFDHViewController.h"
#import "SafariViewController.h"
#import "UserInfoViewController.h"
//#import "CouponsViewController.h"
//#import "CZViewController.h"
#import "LoginViewController.h"
//#import "SettingViewController.h"
//#import "InviteViewController.h"
#import "RechargeThriceTableViewController.h"

#import "MQChatViewManager.h"
#import "MQChatDeviceUtil.h"
#import <MeiQiaSDK/MeiQiaSDK.h>
#import "NSArray+MQFunctional.h"
#import "MQBundleUtil.h"
#import "MQAssetUtil.h"
#import "MQImageUtil.h"
#import "BTBadgeView.h"

@interface ProfileTableViewController ()<UINavigationControllerDelegate>


@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *prizeButton;
@property (weak, nonatomic) IBOutlet UIButton *reviewButton;
@property (weak, nonatomic) IBOutlet UIView *recordContainerView;


@end

@implementation ProfileTableViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = @"我的";
    self.tableView.contentInset = UIEdgeInsetsZero;
    

    float leftMargin = 40;
    _recordContainerView.width = ScreenWidth;
    _recordButton.left = leftMargin;
    _prizeButton.centerX = ScreenWidth/2;
    _reviewButton.right = ScreenWidth - leftMargin;
    
//    float space = 4;
    [_recordButton verticalImageAndTitle:2];
    [_prizeButton verticalImageAndTitle:2];
    [_reviewButton verticalImageAndTitle:2];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger num = 1;
    
    if (section == 1) {
        num = 2;
    }
    
    return num;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    
    NSString *imageName = @"icon_redpacket";
    NSString *title = @"我的红包";
    NSString *detail = @"";
    
    
    if (indexPath.section == 0) {

        _recordContainerView.top = 0;
        [cell.contentView addSubview:_recordContainerView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        
        if (indexPath.section == 1) {
            
            if (indexPath.row == 0) {
                imageName = @"icon_redpacket";
                title = @"我的红包";
                detail = @"";
            } else if (indexPath.row == 1) {
                imageName = @"icon_invite";
                title = @"邀请好友";
                detail = @"邀请有大礼";
            }
            
        } else if (indexPath.section == 2) {
            imageName = @"icon_service";
            title = @"联系客服";
            detail = @"";
            
            float width = 30;
            BTBadgeView *bagdeView = [[BTBadgeView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
//            bagdeView.value = @"1";
            [cell.contentView addSubview:bagdeView];
            bagdeView.right = ScreenWidth - 29;
            bagdeView.centerY = cell.height/2;
            bagdeView.shadow = NO;
            bagdeView.strokeWidth = 0;
            bagdeView.shine = NO;
            bagdeView.font = [UIFont systemFontOfSize:12 * UIAdapteRate];
            bagdeView.fillColor = [UIColor colorWithRed:0.9647 green:0.1176 blue:0.1373 alpha:1];
            
//            _badgeView = bagdeView;
        }
        
        cell.textLabel.text = title;
        cell.detailTextLabel.text = detail;
        cell.imageView.image = [UIImage imageNamed:imageName];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.textLabel.textColor = [UIColor colorFromHexString:@"474747"];
        cell.textLabel.font = [UIFont systemFontOfSize:16 * UIAdapteRate];
//        cell.detailTextLabel.textColor = [UIColor colorFromHexString:@""];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14 * UIAdapteRate];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44;
    if (indexPath.section == 0) {
        height = 85;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    [cell setSelected:NO animated:YES];
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self couponAction];
        } else if (indexPath.row == 1) {
            [self inviteAction];
        }
    } else if (indexPath.section == 2) {
        [self messageAction];
    }
}




- (void)voucherDismiss
{
    [self.tabBarController setSelectedIndex:3];
    [self couponAction];
}

//网络状态捕捉
- (void)checkNetworkStatus:(NSNotification *)notif
{
    NSDictionary *userInfo = [notif userInfo];
    if(userInfo)
    {
//        [self httpUserInfo];
    }
}

#pragma mark -

- (IBAction)rechargeCrowdfundingAction:(id)sender {
    
    
    if (![Tool islogin]) {
        [Tool loginWithAnimated:YES viewController:nil];
        return;
    }
//    CZViewController *vc = [[CZViewController alloc] initWithNibName:@"CZViewController" bundle:nil];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)rechargeThriceAction:(id)sender {
    
    if ([ShareManager shareInstance].isInReview == YES) {
        return;
    }
    
    
    if (![Tool islogin]) {
        [Tool loginWithAnimated:YES viewController:nil];
        return;
    }
    RechargeThriceTableViewController *vc = [[RechargeThriceTableViewController alloc]initWithNibName:@"RechargeThriceTableViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
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
- (IBAction)recordAction:(id)sender {

    if (![Tool islogin]) {
        [Tool loginWithAnimated:YES viewController:nil];
        return;
    }
    DuoBaoRecordViewController *vc = [[DuoBaoRecordViewController alloc] initWithNibName:@"DuoBaoRecordViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)winRecordAction:(id)sender {

    if (![Tool islogin]) {
        [Tool loginWithAnimated:YES viewController:nil];
        return;
    }
    ZJRecordViewController *vc = [[ZJRecordViewController alloc] initWithNibName:@"ZJRecordViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)reviewAction:(id)sender {


    if (![Tool islogin]) {
        [Tool loginWithAnimated:YES viewController:nil];
        return;
    }
    ShaiDanViewController *vc = [[ShaiDanViewController alloc] initWithNibName:@"ShaiDanViewController" bundle:nil];
    vc.userId = [ShareManager shareInstance].userinfo.id;
    [self.navigationController pushViewController:vc animated:YES];
}
//- (void)clickSignButtonAction:(id)sender
//{
//    if (![Tool islogin]) {
//        [Tool loginWithAnimated:YES viewController:nil];
//        return;
//    }
//    
//    [self httpUserSign];
//}

- (void)couponAction
{
  
    if (![Tool islogin]) {
        [Tool loginWithAnimated:YES viewController:nil];
        return;
    }
//    CouponsViewController *vc = [[CouponsViewController alloc]initWithNibName:@"CouponsViewController" bundle:nil];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)inviteAction
{

    if (![Tool islogin]) {
        [Tool loginWithAnimated:YES viewController:nil];
        return;
    }
//    InviteViewController *vc = [[InviteViewController alloc]initWithNibName:@"InviteViewController" bundle:nil];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)messageAction
{
   

    if (![Tool islogin]) {
        [Tool loginWithAnimated:YES viewController:nil];
        return;
    }
    
    UserInfo *userInfo = [ShareManager shareInstance].userinfo;
    NSString *userID = [ShareManager shareInstance].userinfo.id;
    userID = userID ? userID : @"";
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *versionString = [NSString stringWithFormat:@"iOS %@", version];
    NSString *alias = [ShareManager shareInstance].userinfo.nick_name;
    NSString *telephone = userInfo.user_tel ?:@"";
    NSString *mqID = [userID stringByAppendingFormat:@"_%@", alias];
    
    
    MQChatViewConfig *chatViewConfig = [MQChatViewConfig sharedConfig];
    
    MQChatViewController *chatViewController = [[MQChatViewController alloc] initWithChatViewManager:chatViewConfig];
    [chatViewConfig setEnableOutgoingAvatar:false];
    [chatViewConfig setEnableRoundAvatar:YES];
    chatViewConfig.navTitleColor = [UIColor whiteColor];
    chatViewConfig.navBarTintColor = [UIColor whiteColor];
    [chatViewConfig setStatusBarStyle:UIStatusBarStyleLightContent];
    
    chatViewController.title = @"客服";
    [chatViewConfig setNavTitleText:@"客服"];
    [chatViewConfig setCustomizedId:userID];
    [chatViewConfig setEnableEvaluationButton:NO];
    [chatViewConfig setAgentName:@"客服"];
    [chatViewConfig setClientInfo:@{@"name":alias, @"version": versionString, @"identify": userID, @"telephone": telephone}];
    [chatViewConfig setUpdateClientInfoUseOverride:YES];
    [chatViewConfig setRecordMode:MQRecordModeDuckOther];
    [chatViewConfig setPlayMode:MQPlayModeMixWithOther];
    [self.navigationController pushViewController:chatViewController animated:YES];
    
    UIControl *leftItemControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 20, 44)];
    [leftItemControl addTarget:self action:@selector(clickLeftControlAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *back = [[UIImageView alloc] initWithFrame:CGRectMake(0, 13, 16, 17)];
    back.image = [UIImage imageNamed:@"nav_back.png"];
    [leftItemControl addSubview:back];
    
    chatViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftItemControl];
}

- (void)clickLeftControlAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickLoginAction
{
    [Tool loginWithAnimated:YES viewController:nil];
}

- (IBAction)settingAction:(id)sender {
   

//    SettingViewController *vc = [[SettingViewController alloc]initWithNibName:@"SettingViewController" bundle:nil];
//    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -

- (void)httpUserInfo
{
    if (![ShareManager shareInstance].userinfo.islogin) {
        return;
    }
//    HttpHelper *helper = [HttpHelper helper];
//    __weak typeof(self) weakSelf = self;
    [HttpHelper getUserInfoWithUserId:[ShareManager shareInstance].userinfo.id
                          success:^(NSDictionary *resultDic){
                              
                              if ([[resultDic objectForKey:@"status"] integerValue] == 0)
                              {
                                  NSDictionary *dict = [resultDic objectForKey:@"data"];
                                  UserInfo *info = [dict objectByClass:[UserInfo class]];
                                  [ShareManager shareInstance].userinfo = info;
                                  [Tool saveUserInfoToDB:YES];
//                                  [weakSelf updateUserInterface];
                                
                              }else{
                                  [Tool showPromptContent:[resultDic objectForKey:@"desc"] onView:self.view];
                              }
                              
                          }fail:^(NSString *decretion){
                              [Tool showPromptContent:@"网络出错了" onView:self.view];
                          }];
}

- (void)updateUserInfoFromServer
{
//    [self updateUserInterface];
    [self httpUserInfo];
}

- (void)pushWinLotteryViewController
{
    [self winRecordAction:nil];
}

- (void)pushBettingRecordViewController
{
    [self recordAction:nil];
}

- (void)pushBettingRecordViewController:(NSDictionary *)dictionary
{
    
        
        if (![Tool islogin]) {
            [Tool loginWithAnimated:YES viewController:nil];
            return;
        }
        ZJRecordViewController *vc = [[ZJRecordViewController alloc] initWithNibName:@"ZJRecordViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
}

@end
