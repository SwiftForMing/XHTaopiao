//
//  CouponModel.h
//  TaoPiao
//
//  Created by 黎应明 on 2017/9/13.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CouponModel : NSObject
//"coupons_id" = 1005;
//"coupons_imge" = "http://zhimalegou.oss-cn-shanghai.aliyuncs.com/FtpUpload/newsIntro/1474990612450.jpg";
//"coupons_name" = "3\U74f6\U7ec4\U5408\U88c5\U2009|\U2009\U65b0\U519c\U54e5 \U6df7\U5408\U5e72\U679c\U4ec1 200g/\U74f6 \U4f18\U60e0\U5238";
//"coupons_value" = 20;
//"create_time" = "2017-09-12 10:11";
//"effct_time" = "2017-01-01";
//"good_id" = 522860622582;
//id = Tply4wB37nP4kR6azhrR;
//status = "\U672a\U4f7f\U7528";
//"transfer_user" = "<null>";
//"use_date" = "<null>";
//"valid_date" = "2018-09-12";
@property (nonatomic, strong) NSString * coupons_id;
@property (nonatomic, strong) NSString * coupons_imge;
@property (nonatomic, strong) NSString * coupons_name;
@property (nonatomic, assign) NSInteger coupons_value;
@property (nonatomic, strong) NSString * create_time;
@property (nonatomic, strong) NSString * effct_time;
@property (nonatomic, strong) NSString * good_id;
@property (nonatomic, strong) NSString * id;
@property (nonatomic, strong) NSString * status;
@property (nonatomic, strong) NSObject * transfer_user;
@property (nonatomic, strong) NSObject * use_date;
@property (nonatomic, strong) NSString * valid_date;

@end
