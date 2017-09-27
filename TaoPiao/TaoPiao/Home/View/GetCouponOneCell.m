//
//  GetCouponOneCell.m
//  TaoPiao
//
//  Created by 黎应明 on 2017/9/12.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import "GetCouponOneCell.h"

@implementation GetCouponOneCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _getCouponBtn.layer.masksToBounds = YES;
    _getCouponBtn.layer.cornerRadius = 15;
    _getCouponBtn.layer.borderWidth = 1;
    _getCouponBtn.layer.borderColor = [UIColor greenColor].CGColor;
}

-(void)setGoodModel:(HomeGoodModel *)goodModel{
    
    _couponNameLabel.text = goodModel.coupons_name;
    
    _couponGoodNameLabel.text  = goodModel.good_name;
    NSString *couponPrice =  [NSString stringWithFormat:@"售价￥%@",goodModel.coupons_value];
    
    NSString *giveBean =  [NSString stringWithFormat:@"赠%d豆",[goodModel.coupons_value intValue]*BeanExchangeRate];
    NSString *coupon = [NSString stringWithFormat:@"%@%@",couponPrice,giveBean];
    //label的富文本
    NSMutableAttributedString *couponABS = [[NSMutableAttributedString alloc] initWithString:coupon];
    [couponABS addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:[coupon rangeOfString:couponPrice]];
    [couponABS addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:[coupon rangeOfString:giveBean]];
    _couponPriceLabel.attributedText = couponABS;
    _timeLabel.text = [NSString stringWithFormat:@"有效期：%@",goodModel.valid_date];
    _goodModel = goodModel;
    
}

@end
