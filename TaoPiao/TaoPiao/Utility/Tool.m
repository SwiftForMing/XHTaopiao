//
//  Tool.m
//  TaoPiao
//
//  Created by 黎应明 on 2017/8/31.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import "Tool.h"
#import "SJAvatarBrowser.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <CommonCrypto/CommonDigest.h>
#import "KeychainWrapper.h"
#import "LoginViewController.h"
#import "SystemConfigure.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "YYKitMacro.h"
#import "PaySelectedData.h"
#define IOS6_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)



@implementation Tool
+ (void)showPromptContent:(NSString *)content
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:window animated:YES];
    HUD.mode = MBProgressHUDModeText;
    HUD.labelText = content;
    HUD.margin = 10.f;
    HUD.yOffset = 90.f ;
    HUD.removeFromSuperViewOnHide = YES;
    [HUD hide:YES afterDelay:1.5];
}

/**
 *  显示提示信息
 *
 *  @param content  提示内容
 *  @param selfView 提示信息所在的页面
 */
+ (void)showPromptContent:(NSString *)content onView:(UIView *)selfView
{
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:selfView animated:YES];
    HUD.mode = MBProgressHUDModeText;
    HUD.labelText = content;
    HUD.margin = 10.f;
    HUD.yOffset = 90.f ;
    HUD.removeFromSuperViewOnHide = YES;
    [HUD hide:YES afterDelay:1.5];
    
}

+ (void)getServerConfigure
{
    //校验是否需要版本审核
    SystemConfigure *configure = [Tool getSystemConfigureFromDB];
    BOOL cantVerifyVersion = configure.cantVerifyVersion;
    
    // 需要校验版本判断是否正在进行苹果审核
    if (cantVerifyVersion == YES) {
        [ShareManager shareInstance].isInReview = NO;
    }
    
    [HttpHelper getVersion:^(NSDictionary *resultDic) {
        
        NSDictionary *dict1 = resultDic[@"data"];
        NSDictionary *dict =dict1[@"appIosMap"];
        if (dict) {
            
            NSString *serverVersion = dict[@"version"];
            NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            
            // 是否最新版本
            BOOL isNewestVersion = YES;
            
            // 版本号类型验证
            NSString *type = dict[@"type"];
            if ([type isEqualToString:@"Ios"]) {
                
                MLog(@"serverVersion%@",serverVersion);
                MLog(@"version%@",version);
                NSArray *serverNumbers = [serverVersion componentsSeparatedByString:@"."];
                NSArray *versionNumbers = [version componentsSeparatedByString:@"."];
                
                int serverNum = 0;
                int versionNum = 0;
                
                NSInteger count = serverNumbers.count - 1;
                for (NSInteger i= serverNumbers.count-1; i>=0; i--) {
                    
                    int rate = pow(100, i);
                    
                    NSNumber *m = [serverNumbers objectAtIndex:count-i];
                    serverNum += rate* [m intValue];
                    m = [versionNumbers objectAtIndex:count-i];
                    versionNum += rate* [m intValue];
                }
                
                if (versionNum < serverNum) {
                    isNewestVersion = NO;
                }
                
                // 本地版本号 > 服务器版本号, 表示正在审核阶段
                if (versionNum > serverNum) {
                    [ShareManager shareInstance].isInReview = YES;
                    configure.cantVerifyVersion = NO;
                    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:kShouldVerifyVersion];
                    [ShareManager shareInstance].isShowThird = @"n";
                } else {
                    [ShareManager shareInstance].isInReview = NO;
                    configure.cantVerifyVersion = YES;
                    [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:kShouldVerifyVersion];
                    [ShareManager shareInstance].isShowThird = @"y";
                }
                
                [Tool saveSystemConfigureToDB:configure];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                // 是否强制升级
                NSString *forceUpdate = [dict objectForKey:@"is_force_update"];
                
                //#if DEBUG
                //    forceUpdate = @"y";
                //#endif
                if (versionNum < serverNum) {
                    
                    if ([forceUpdate isEqualToString:@"y"]) {
                        
                        UIAlertView *chooseAlert = [[UIAlertView alloc] initWithTitle:@"您的客户端应用版本已经不再受到支持，请立即更新。" message:nil delegate:nil cancelButtonTitle:@"立即更新" otherButtonTitles:nil];
                        [chooseAlert show];
                        
                        [[chooseAlert rac_buttonClickedSignal] subscribeNext:^(NSNumber *indexNumber) {
                            
                            NSURL *url = [NSURL URLWithString:ShareLinkItunes];
                            [[UIApplication sharedApplication] openURL:url];
                            
                            sleep(2);
                            exit(0);
                        }];
                    } else {
                        
                        // 当前版本不是最新，本地保存的latestVersion字段没有被更新，即非强制更新只显示一次
                        if (isNewestVersion == NO && serverVersion && ![configure.latestVersion isEqualToString:serverVersion]) {
                            
                            configure.latestVersion = serverVersion;    // 更新服务器版本号
                            [Tool saveSystemConfigureToDB:configure];
                            
                            UIAlertView *chooseAlert = [[UIAlertView alloc] initWithTitle:@"有新版本啦！" message:@"！" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"立即升级", @"忽略此版本", nil];
                            [chooseAlert show];
                            
                            [[chooseAlert rac_buttonClickedSignal] subscribeNext:^(NSNumber *indexNumber) {
                                if ([indexNumber intValue] == 0) {
                                    
                                } else if ([indexNumber intValue] == 1) {
                                    NSURL *url = [NSURL URLWithString:ShareLinkItunes];
                                    [[UIApplication sharedApplication] openURL:url];
                                }
                            }];
                        }
                    }
                    
                }
            }
        }
    } fail:^(NSString *description) {
        
    }];
    
    // 获取服务器支付渠道配置信息
    [self getConfigurePaymentChannels];
}

/**
 *  获取数据库相关信息(用户信息)
 */
+ (SystemConfigure *)getSystemConfigureFromDB
{
    SystemConfigure *object = nil;
    
    LKDBHelper *DBHelper = [LKDBHelper getUsingLKDBHelper];
    
    if ([DBHelper getTableCreatedWithClass:[SystemConfigure class]]) {
//        NSArray *array = [DBHelper search:[SystemConfigure class] where:nil orderBy:nil offset:0 count:0];
//        object = [array firstObject];
//                if (array && array.count > 0) {
//                    for (SystemConfigure *info in array) {
//                        [ShareManager shareInstance].userinfo = info;
//                        break;
//                    }
//                }
//        
    }
    
    if (object == nil) {
        object = [[SystemConfigure alloc] init];
    }
    
    return object;
}


+ (void)saveSystemConfigureToDB:(SystemConfigure *)object
{
    LKDBHelper *DBHelper = [LKDBHelper getUsingLKDBHelper];
    
    if([DBHelper getTableCreatedWithClass:[SystemConfigure class]])
    {
        [DBHelper deleteWithClass:[SystemConfigure class] where:nil];
    }
    
    [DBHelper insertToDB:object];
}

+ (void)getConfigurePaymentChannels
{
      @weakify(self);
    // 获取配置信息
    [HttpHelper getConfigure:^(NSDictionary *resultDic) {
        @strongify(self);
        
        // 获取本地数据
        SystemConfigure *configure = [self getSystemConfigureFromDB];
        
        NSDictionary *data = [resultDic objectForKey:@"data"];
        NSString *status = [resultDic objectForKey:@"status"];
        if (data && [status isEqualToString:@"0"]) {
            
            NSArray *array = [data objectForKey:@"pay_channel"];
            NSString *exchangeRateStr = [data objectForKey:@"happy_specific"];
            NSString *is_happy_shop = [data objectForKey:@"is_happy_shop"];
            
            NSMutableArray *configureArray = [NSMutableArray array];
            for (NSDictionary *dict in array) {
                MLog(@"支付方式%@",dict);
                if ([dict isKindOfClass:[NSDictionary class]]) {
                    PaySelectedData *object = [dict objectByClass:[PaySelectedData class]];
                    [configureArray addObject:object];
                }
            }
            
            configure.exchangeRate = [exchangeRateStr doubleValue];
            configure.paymentChannels = configureArray;
            configure.is_happy_shop = is_happy_shop;
            [ShareManager shareInstance].configureArray = [NSArray arrayWithArray:configureArray];
            [ShareManager shareInstance].configure = configure;
            [Tool saveSystemConfigureToDB:configure];
        }
        
    } fail:^(NSString *description) {
        
    }];
}






/**
 *  present ViewController
 *
 *  @param viewController        presenting viewController
 *  @param presentViewController presented viewController
 *  @param animated              animation
 */
+ (void)presentModalFromViewController:(UIViewController *)viewController
                 presentViewController:(UIViewController *)presentViewController
                              animated:(BOOL)animated
{
    if (IOS6_OR_LATER)
    {
        [viewController presentViewController:presentViewController
                                     animated:animated
                                   completion:nil];
    }
    else
    {
        [viewController presentViewController:presentViewController animated:YES completion:nil];
    }
}

+ (void)getUserInfo
{
    
    [HttpHelper getUserInfoWithUserId:[ShareManager shareInstance].userinfo.id
                          success:^(NSDictionary *resultDic){
                              if ([[resultDic objectForKey:@"status"] integerValue] == 0)
                              {
                                  UserInfo *info = [[resultDic objectForKey:@"data"] objectByClass:[UserInfo class]];
                                  [ShareManager shareInstance].userinfo = info;
                                  [Tool saveUserInfoToDB:YES];
                              }
                          }fail:^(NSString *decretion){
                          }];
}

/**
 *  dismiss viewController
 *
 *  @param dismissViewController dismissed viewController
 *  @param animated              animation
 */
+ (void)dismissModalViewController:(UIViewController *)dismissViewController
                          animated:(BOOL)animated
{
    if (IOS6_OR_LATER)
    {
        [dismissViewController dismissViewControllerAnimated:animated completion:nil];
    }
    else
    {
        [dismissViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

/**
 *  16进制颜色值转RGB
 *
 *  @param hexString 16进制字符串色值
 *
 *  @return RGB色值
 */
+ (UIColor *)colorWithHexString:(NSString *)hexString
{
    NSString *cString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([cString length] < 6)
        return [UIColor clearColor];;
    
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    NSRange range = NSMakeRange(0, 2);
    
    unsigned int red, green, blue;
    [[NSScanner scannerWithString:[cString substringWithRange:range]] scanHexInt:&red];
    
    range.location = 2;
    [[NSScanner scannerWithString:[cString substringWithRange:range]] scanHexInt:&green];
    
    range.location = 4;
    [[NSScanner scannerWithString:[cString substringWithRange:range]] scanHexInt:&blue];
    
    return [UIColor colorWithRed:((float)red / 255.0f)
                           green:((float)green / 255.0f)
                            blue:((float)blue / 255.0f)
                           alpha:1.0f];
}


+ (NSString*)getUUID
{
    NSString* UUID = [KeychainWrapper keychainStringFromMatchingIdentifier:[KeychainWrapper UUID]];
    if (UUID == nil || UUID.length == 0) {
        CFUUIDRef CFUUIDRef = CFUUIDCreate(kCFAllocatorDefault);
        if (CFUUIDRef) {
            UUID = (__bridge NSString *)(CFUUIDCreateString(kCFAllocatorDefault, CFUUIDRef));
            [KeychainWrapper createKeychainNSStringValue:UUID forIdentifier:[KeychainWrapper UUID]];
        }
    }
    
    return UUID;
}

/**
 *  保存图片到document
 */
+ (void)saveImage:(UIImage *)tempImage WithName:(NSString *)imageName
{
    NSData* imageData = UIImageJPEGRepresentation(tempImage,0.5);
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    // Now we get the full path to the file
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:imageName];
    // and then we write it out
    [imageData writeToFile:fullPathToFile atomically:NO];
}

/**
 *  压缩图片
 */
+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

/**
 *  获取公共图片
 */
+ (UIImage *)imageInPublic:(NSString *)imageName{
    NSString *imgName = [NSString stringWithFormat:@"%@.png", imageName];
    return [UIImage imageNamed:imgName];
}


/**
 *  获取连接的wifi的信息
 */
+ (NSDictionary *)wifiInfo
{
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    
    id info = nil;
    for (NSString *ifnam in ifs)
    {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        
        if (info && [info count])
        {
            NSMutableDictionary *proccessWifiInfo = [NSMutableDictionary dictionary];
            [proccessWifiInfo setObject:[info objectForKey:@"SSID"] forKey:@"SSID"];
            [proccessWifiInfo setObject:[info objectForKey:@"SSIDDATA"] forKey:@"SSIDDATA"];
            
            NSString *bssid = [info objectForKey:@"BSSID"];
            NSArray *array = [bssid componentsSeparatedByString:@":"];
            
            NSMutableString *proccessBSSID = [NSMutableString string];
            for (int i=0; i<array.count; i++)
            {
                NSString *ipComponent = [array objectAtIndex:i];
                if (ipComponent.length == 1) {
                    [proccessBSSID appendFormat:@"0%@", ipComponent];
                }else{
                    [proccessBSSID appendString:ipComponent];
                }
                
                if (i != array.count-1) {
                    [proccessBSSID appendString:@":"];
                }
            }
            
            [proccessWifiInfo setObject:proccessBSSID forKey:@"BSSID"];
            
            return proccessWifiInfo;
            break;
        }
    }
    
    return nil;
}


/**
 *  全屏查看图片（单张）
 */

+ (void)FullScreenToSeePicture:(UIImage*)image
{
    
    [SJAvatarBrowser showImage:image];
}

/**
 *  获取当前时间
 *  @param dateFormatString 时间格式
 */

+ (NSString *)getCurrentTimeWithFormat:(NSString *)dateFormatString
{
    // 获取系统当前时间
    NSDate * date = [NSDate date];
    NSTimeInterval sec = [date timeIntervalSinceNow];
    NSDate * currentDate = [[NSDate alloc] initWithTimeIntervalSinceNow:sec];
    
    //设置时间输出格式：
    NSDateFormatter * df = [[NSDateFormatter alloc] init ];
    [df setDateFormat:dateFormatString];
    NSString * curTime = [df stringFromDate:currentDate];
    
    
    return curTime;
}

+ (BOOL)isMobileNumberClassification:(NSString*)phone
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188,1705
     * 联通：130,131,132,152,155,156,185,186,1709
     * 电信：133,1349,153,180,189,1700
     */
    //    NSString * MOBILE = @"^1((3//d|5[0-35-9]|8[025-9])//d|70[059])\\d{7}$";//总况
    
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188，1705
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d|705)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186,1709
     17         */
    NSString * CU = @"^1((3[0-2]|5[256]|8[56])\\d|709)\\d{7}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189,1700
     22         */
    NSString * CT = @"^1((33|53|8[09])\\d|349|700)\\d{7}$";
    
    
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    
    //    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    NSPredicate *regextestphs = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",PHS];
    
    if (([regextestcm evaluateWithObject:phone] == YES)
        || ([regextestct evaluateWithObject:phone] == YES)
        || ([regextestcu evaluateWithObject:phone] == YES)
        || ([regextestphs evaluateWithObject:phone] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


+ (BOOL)islogin
{
    if ([ShareManager shareInstance].userinfo ) {
        return [ShareManager shareInstance].userinfo.islogin;
    }
    return NO;
}

+ (BOOL)isTestAccount
{
    if ([[ShareManager shareInstance].userinfo.id isEqualToString:@"18046057263"]) {
        return YES;
    }
    return NO;
}

+ (void)loginWithAnimated:(BOOL)animated viewController:(UIViewController *)viewControl
{
     LoginViewController *vc = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
     UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    if (!viewControl) {
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:animated completion:nil];
      }else{
         [viewControl presentViewController:nav animated:animated completion:nil];
    }
}


+ (void)autoLoginSuccess:(void (^)(NSDictionary *))success
                    fail:(void (^)(NSString *))fail {
    
    UserInfo *userInfo = [ShareManager shareInstance].userinfo;
    if (userInfo && userInfo.islogin) {
        
        if (userInfo.password.length == 0 || [userInfo.password isEqualToString:@"<null>"]) {
            
            NSString *loginIdStr = nil;
            NSString *typeStr = nil;
            
            if (userInfo.qq_login_id.length > 0 && ![userInfo.qq_login_id isEqualToString:@"<null>"] ) {
                loginIdStr = userInfo.qq_login_id ;
                typeStr = @"qq";
            }else{
                loginIdStr = userInfo.weixin_login_id ;
                typeStr = @"weixin";
            }
            
            [HttpHelper thirdloginByWithLoginId:loginIdStr
                                  nick_name:userInfo.nick_name
                                user_header:userInfo.user_header
                                       type:typeStr
                                   jpush_id:[JPUSHService registrationID]
                                    success:^(NSDictionary *resultDic){
                                        
                                        success(resultDic);
                                    }fail:^(NSString *decretion){
                                        if (fail) {
                                            fail(decretion);
                                        }
                                    }];
        }
        else{
            [HttpHelper loginByWithMobile:userInfo.app_login_id
                             password:userInfo.password
                             jpush_id:[JPUSHService registrationID]
                              success:^(NSDictionary *resultDic){
                                  success(resultDic);
                              }fail:^(NSString *decretion){
                                  if (fail) {
                                      fail(decretion);
                                  }
                              }];
        }
    }
}

/**
 *  统一收起键盘
 */
+ (void)hideAllKeyboard
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}


/**
 *  获取数据库相关信息(用户信息)
 */
+ (void)getUserInfoFromSqlite
{
    LKDBHelper *DBHelper = [LKDBHelper getUsingLKDBHelper];
    
    if ([DBHelper getTableCreatedWithClass:[UserInfo class]]) {
        NSArray *array = [DBHelper search:[UserInfo class] where:nil orderBy:nil offset:0 count:0];
        
        if (array && array.count > 0) {
            for (UserInfo *info in array) {
                [ShareManager shareInstance].userinfo = info;
                break;
            }
        }
        
    }
}

/**
 *  存储当前账号信息，本地只保存一次，覆盖逻辑
 */
+ (void)saveUserInfoToDB:(BOOL)islogin
{
    if (islogin) {
        [ShareManager shareInstance].userinfo.islogin = YES;
    }else{
        [ShareManager shareInstance].userinfo.islogin = NO;
    }
    LKDBHelper *DBHelper = [LKDBHelper getUsingLKDBHelper];
    if([DBHelper getTableCreatedWithClass:[UserInfo class]])
    {
        [DBHelper deleteWithClass:[UserInfo class] where:nil];
    }
    
    [DBHelper insertToDB:[ShareManager shareInstance].userinfo];
}



/**
 *  指定大小压缩图片
 */
+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

/**
 * label 自适应字体大小
 */
+ (void)setFontSizeThatFits:(UILabel*)label
{
    label.adjustsFontSizeToFitWidth = YES;
}


/**
 *  32位MD5加密
 *
 *  @param string           加密字符串
 *  @param LetterCaseOption 加密选项 {UpperLetter:大写；LowerLetter:小写}
 *
 *  @return 加密后的字符串
 */
+ (NSString *)encodeUsingMD5ByString:(NSString *)srcString
                    letterCaseOption:(LetterCaseOption)letterCaseOption
{
    if (!srcString) {
        srcString = @"";
    }
    
    const char *cStr = [srcString UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5( cStr, (unsigned)strlen(cStr), digest );
    
    NSMutableString *encodeString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [encodeString appendFormat:@"%02x", digest[i]];
    
    if (letterCaseOption == UpperLetter) {
        return [encodeString uppercaseString];
    }else{
        return [encodeString lowercaseString];
    }
    
}

/*
 * 时间戳转为时间字符串
 *
 */
+ (NSString *)timeStringToDateSting:(NSString *)timestr format:(NSString *)format
{
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[timestr longLongValue]/1000];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];//
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}


/**
 *  判断号码是否是合法手机号
 *
 *  @param checkString 号码
 *
 *  @return 判断结果
 */
+ (BOOL)validateMobile:(NSString *)checkString
{
    NSString * regex = @"(^[0-9]{11}$)";
    NSPredicate * pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:checkString];
    return isMatch && (checkString.length == 11);
}


/**
 *  判断是否输入的金额是否合法
 *
 *  @param checkString 号码
 *
 *  @return 判断结果
 */
+ (BOOL)isPureFloat:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return [scan scanFloat:&val] && [scan isAtEnd];
}

/**
 *  随机生成字符串
 *
 *  @param checkString 号码
 *
 *  @return 判断结果
 */
+ (NSString *)randomlyGeneratedStrWithLength:(NSInteger)lenght
{
    char data[lenght];
    for (int x=0;x<lenght;data[x++] = (char)('a' + (arc4random_uniform(26))));
    return [[NSString alloc] initWithBytes:data length:lenght encoding:NSUTF8StringEncoding];
}

/**
 *  发送短信
 *
 *  @param viewController 从哪个viewConotroller弹出的短信窗口
 *  @param recipients     收件人
 *  @param content        短信内容
 */
+ (void)sendMessageByViewController:(UIViewController *)viewController
                         recipients:(NSArray *)recipients
                            content:(NSString *)content
{
    
    BOOL canSendSMS = [MFMessageComposeViewController canSendText];
    if (!canSendSMS) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"设备无法发送短信"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
        
        [alert show];
        
        return;
    }
    
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate = (id)viewController;
    picker.body = content;
    picker.recipients = [NSArray arrayWithArray:recipients];
    
    //    [FindMeTool presentModalFromViewController:viewController
    //                         presentViewController:picker
    //                                      animated:NO];
    [viewController presentViewController:picker animated:YES completion:nil];
}

/*
 * 校验身份证
 *
 */
+(BOOL)checkIdentityCardNo:(NSString*)cardNo
{
    BOOL flag;
    if (cardNo.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:cardNo];
}

//上架屏蔽数据判断接口
+ (void)httpGetIsShowThridView
{
    [ShareManager shareInstance].isShowThird = @"y";
    
    if ([ShareManager shareInstance].isInReview == YES){
        [ShareManager shareInstance].isShowThird = @"n";
    }
    
    return;
    
    [HttpHelper getHttpWithUrlStr:URL_GetIsSJ
                      success:^(NSDictionary *resultDic){
                          if ([[resultDic objectForKey:@"status"] integerValue] == 0) {
                              [ShareManager shareInstance].isShowThird = [[resultDic objectForKey:@"data"] objectForKey:@"is_money_pay"];
                              [ShareManager shareInstance].serverPhoneNum = [[resultDic objectForKey:@"data"] objectForKey:@"tel"];
                              [ShareManager shareInstance].domain = [[resultDic objectForKey:@"data"] objectForKey:@"domain"];
                          }
                      }fail:^(NSString *decretion){
                      }];
}

+ (void)UIAdapte:(UIView *)superview deepth:(int)deepth
{
    float rate = UIAdapteRate;
    
    for (UIView *view in superview.subviews) {
        view.width *= rate;
        view.height *= rate;
        view.left *= rate;
        view.top *= rate;
        
        if (deepth >= 2) {
            
            UIView *containerView = view;
            for (UIView *view in containerView.subviews) {
                view.width *= rate;
                view.height *= rate;
                view.left *= rate;
                view.top *= rate;
                
                if (deepth >= 3) {
                    
                    UIView *containerView = view;
                    for (UIView *view in containerView.subviews) {
                        
                        view.width *= rate;
                        view.height *= rate;
                        view.left *= rate;
                        view.top *= rate;
                    }
                }
            }
        }
    }
}

//+ (void)showWinLottery:(NSDictionary *)data
//{
//    NSString *status = [data objectForKey:@"status"];
//    if (data && [status isEqualToString:@"待发货"]) {
//        WinningLotteryAlertView *alertView = [[WinningLotteryAlertView alloc] initWithDictionary:data];
//        TYAlertController *alertController = [TYAlertController alertControllerWithAlertView:alertView preferredStyle:TYAlertControllerStyleAlert];
//        alertController.backgoundTapDismissEnable = YES;
//        alertController.backgroundColor = [UIColor colorWithWhite:0 alpha:0.9];
//        UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
//        [rootViewController presentViewController:alertController animated:YES completion:nil];
//    }
//}


@end
