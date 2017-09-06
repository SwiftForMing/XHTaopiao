//
//  LoginViewController.m
//  DuoBao
//
//  Created by gthl on 16/2/11.
//  Copyright © 2016年 linqsh. All rights reserved.
//


#import "LoginViewController.h"
#import "ForgetPwdViewController.h"
#import "ResigterViewController.h"
#import "BangdingViewController.h"
#import <TKAlert&TKActionSheet/TKAlert&TKActionSheet.h>
#import "JMWhenTapped.h"

@interface LoginViewController ()<UINavigationControllerDelegate,ResigterViewControllerDelegate>

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置导航控制器的代理为self
    self.navigationController.delegate = self;
    [self initVariable];
    [self leftNavigationItem];
    [self rightItemView];
    //手势返回
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    if ([ShareManager shareInstance].userinfo.app_login_id.length > 0  && ![[ShareManager shareInstance].userinfo.app_login_id isEqualToString:@"<null>"]) {
        _phoneText.text = [ShareManager shareInstance].userinfo.app_login_id;
    }else{
        _phoneText.text = @"";
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    NSString *userID = [ShareManager shareInstance].userinfo.id;
    if (userID.length > 1) {
        NSString *loginHistory = [userID stringByAppendingString:@"_loginHistory"];
        NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:loginHistory];
        if ([value boolValue] == NO) {
            //            [self performSelector:@selector(showVoucher) withObject:nil afterDelay:1];
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:loginHistory];
        }
    }
    
}

- (void)initVariable
{
    //    self.title = @"登录";
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor whiteColor],
                                NSForegroundColorAttributeName, nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    
    _loginButton.layer.masksToBounds =YES;
    _loginButton.layer.cornerRadius = 5;
    
    
    if ([[ShareManager shareInstance].isShowThird isEqualToString:@"y"]) {
        /*
        if (([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) || ([QQApiInterface isQQInstalled] &&[QQApiInterface isQQSupportApi]))
        {
            _thirdLoginView.hidden = NO;
            
            if (![WXApi isWXAppInstalled] || ![WXApi isWXAppSupportApi])
            {
                _weixinLoginButton.hidden = YES;
            }
            if (![QQApiInterface isQQInstalled] || ![QQApiInterface isQQSupportApi])
            {
                _qqLoginButton.hidden = YES;
            }
        }else{
            _thirdLoginView.hidden = YES;
        }
         */
        
    }else{
        _thirdLoginView.hidden = YES;
    }
    
    
}


- (void)leftNavigationItem
{
   
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"new_close"] style:UIBarButtonItemStylePlain target:self action:@selector(clickLeftItemAction:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor grayColor];
    
    
}


- (void)rightItemView
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"免费注册" style:UIBarButtonItemStylePlain target:self action:@selector(clickRightItemAction:)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor redColor];
    return;
    }

#pragma mark - Button Action

- (void)clickLeftItemAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)clickRightItemAction:(id)sender
{
   
    ResigterViewController *vc = [[ResigterViewController alloc]initWithNibName:@"ResigterViewController" bundle:nil];
    vc.delegate = self;
    
    
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)clickLoginButtonAction:(id)sender
{
    [Tool hideAllKeyboard];
    [self httpLogin];

}


- (IBAction)clickFindPwdButtonAction:(id)sender
{
    ForgetPwdViewController *vc = [[ForgetPwdViewController alloc]initWithNibName:@"ForgetPwdViewController" bundle:nil];
    vc.title = @"找回密码";
    vc.isFindPwd = YES;
   
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)clickQQLoginButtonAction:(id)sender
{
    
  /*
    [ShareSDK authorize:SSDKPlatformTypeQQ
               settings:nil
         onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
     {
         switch (state) {
             case SSDKResponseStateSuccess:
             {
                 [self httpOtherLoginWithId:user.uid
                                  band_type:@"qq"
                                  nick_name:user.nickname
                                 user_photo:user.icon];
                 break;
             }
             case SSDKResponseStateFail:
             {
                 [Tool showPromptContent:@"授权失败" onView:self.view];
                 break;
             }
             case SSDKResponseStateCancel:
             {
                 break;
             }
             default:
                 break;
         }
     }];
    
   */
}

- (IBAction)clickWeiXinLoginButtonAction:(id)sender
{
   /*
    [ShareSDK authorize:SSDKPlatformTypeWechat
               settings:nil
         onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
     {
         switch (state) {
             case SSDKResponseStateSuccess:
             {
                 [self httpOtherLoginWithId:user.uid
                                  band_type:@"weixin"
                                  nick_name:user.nickname
                                 user_photo:user.icon];
                 break;
             }
             case SSDKResponseStateFail:
             {
                 [Tool showPromptContent:@"授权失败" onView:self.view];
                 break;
             }
             case SSDKResponseStateCancel:
             {
                 break;
             }
             default:
                 break;
         }
     }];
    
    */
  
}



#pragma mark http

- (void)httpLogin
{
    
    if ( _phoneText.text.length < 1) {
        [Tool showPromptContent:@"请输入手机号" onView:self.view];
        return;
    }
    
    if(![Tool validateMobile:_phoneText.text] )
    {
        [Tool showPromptContent:@"请输入正确手机号" onView:self.view];
        return;
    }
    
    if (_pwdText.text.length < 1) {
        [Tool showPromptContent:@"请输入密码" onView:self.view];
        return;
    }
    MBProgressHUD * HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.labelText = @"登录中...";
    HttpHelper *helper = [HttpHelper helper];
    
    NSString *telephone = _phoneText.text;
    __weak LoginViewController *weakSelf = self;
    [helper loginByWithMobile:_phoneText.text
                     password:_pwdText.text
                     jpush_id:[JPUSHService registrationID]
                      success:^(NSDictionary *resultDic){
                          [HUD hide:YES];
                          if ([[resultDic objectForKey:@"status"] integerValue] == 0) {
                              [weakSelf handleloadResult:[resultDic objectForKey:@"data"]];
                          }else
                          {
                              [Tool showPromptContent:[resultDic objectForKey:@"desc"] onView:weakSelf.view];
                          }
                          
                      }fail:^(NSString *decretion){
                          [HUD hide:YES];
                          [Tool showPromptContent:@"网络出错了" onView:weakSelf.view];
                      }];
    
}

- (void)handleloadResult:(NSDictionary *)resultDic
{
    //登录成功通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccess object:nil];
    
    //    [Tool showPromptContent:@"登录成功" onView:self.view];
    [self performSelector:@selector(clickLeftItemAction:) withObject:nil afterDelay:1.5];
    
}

//第三方登录
- (void)httpOtherLoginWithId:(NSString *)band_id
                   band_type:(NSString *)band_type
                   nick_name:(NSString *)nick_name
                  user_photo:(NSString *)user_photo
{
    MBProgressHUD * HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.labelText = @"登录中...";
    
    HttpHelper *helper = [HttpHelper helper];
    __weak LoginViewController *weakSelf = self;
    [helper thirdloginByWithLoginId:band_id
                          nick_name:nick_name
                        user_header:user_photo
                               type:band_type
                           jpush_id:[JPUSHService registrationID]
                            success:^(NSDictionary *resultDic){
                                [HUD hide:YES];
                                if ([[resultDic objectForKey:@"status"] integerValue] == 0) {
                                    [weakSelf handleloadOtherLoginResult:[resultDic objectForKey:@"data"]];
                                }else
                                {
                                    [Tool showPromptContent:[resultDic objectForKey:@"desc"] onView:weakSelf.view];
                                }
                            }fail:^(NSString *decretion){
                                [HUD hide:YES];
                                [Tool showPromptContent:@"网络出错了" onView:weakSelf.view];
                            }];
    
}

- (void)handleloadOtherLoginResult:(NSDictionary *)resultDic
{
    UserInfo *info = [ShareManager shareInstance].userinfo;
    if (info.user_tel.length >0 && ![info.user_tel isEqualToString:@"<null>"]) {
        //登录成功通知
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccess object:nil];
        //        [Tool showPromptContent:@"登录成功" onView:self.view];
        [self performSelector:@selector(clickLeftItemAction:) withObject:nil afterDelay:1.5];
    }
    else{
        [Tool saveUserInfoToDB:NO];
        BangdingViewController *vc = [[BangdingViewController alloc]initWithNibName:@"BangdingViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark -

- (void)resigterSuccess:(NSString *)account
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - UINavigationControllerDelegate
// 将要显示控制器
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 判断要显示的控制器是否是自己
    BOOL isShowHomePage = [viewController isKindOfClass:[self class]];
    if (isShowHomePage) {
        self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        [UINavigationBar appearance].translucent = NO;
        self.navigationController.navigationBar.subviews[0].subviews[0].hidden = YES;
        
    }
    
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBar.barTintColor = [UIColor colorFromHexString:@"D31E0D"];
}

-(void)dealloc{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
}

@end
