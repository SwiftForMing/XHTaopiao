//
//  HomeTopCell.m
//  TaoPiao
//
//  Created by 黎应明 on 2017/9/5.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import "HomeTopCell.h"

@implementation HomeTopCell

- (void)awakeFromNib {
    [super awakeFromNib];
   [_likeBtn verticalImageAndTitle:2];
}
-(void)setCouponModel:(CouponModel *)couponModel{

    NSURL *url = [[NSURL alloc]initWithString:couponModel.coupons_imge];
    [_headerImageView sd_setImageWithURL:url placeholderImage:nil];
    _priceImageView.hidden = YES;
    _couponName.text = couponModel.coupons_name;
    _goodNameLabel.text = couponModel.status;
    _couponPriceLabel.text = couponModel.valid_date;
    
}

-(void)setGoodModel:(HomeGoodModel *)goodModel{
    NSURL *url = [[NSURL alloc]initWithString:goodModel.good_header];
    [_headerImageView sd_setImageWithURL:url placeholderImage:nil];
      _couponName.text = goodModel.coupons_name;
    _goodNameLabel.text = goodModel.good_name;
    
    NSString *price =  [NSString stringWithFormat:@"劵后价￥%@",goodModel.after_coupons_price];
    NSString *normalPrice =  [NSString stringWithFormat:@"￥%@",goodModel.good_price];
    _goodPriceLabel.text  = price;
    //label的富文本
    NSMutableAttributedString *text1 = [[NSMutableAttributedString alloc] initWithString:normalPrice];
    [text1 addAttributes:@{
                         
                         NSStrikethroughStyleAttributeName:@(NSUnderlineStyleThick),
                         
                         NSForegroundColorAttributeName:
                             
                             [UIColor lightGrayColor],
                         
                         NSBaselineOffsetAttributeName:
                             
                             @(0),
                         
                         NSFontAttributeName: [UIFont systemFontOfSize:10]
                         
                         } range:[normalPrice rangeOfString:normalPrice]];
   
    _afterPriceLabel.attributedText = text1;
    
    
    NSString *couponPrice =  [NSString stringWithFormat:@"售价￥%@",goodModel.coupons_value];
    NSString *giveBean =  [NSString stringWithFormat:@"赠送%@欢乐豆",goodModel.good_price];
    NSString *coupon = [NSString stringWithFormat:@"%@%@",couponPrice,giveBean];
    //label的富文本
    NSMutableAttributedString *couponABS = [[NSMutableAttributedString alloc] initWithString:coupon];
    [couponABS addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:[coupon rangeOfString:couponPrice]];
    [couponABS addAttribute:NSForegroundColorAttributeName value:[UIColor yellowColor] range:[coupon rangeOfString:giveBean]];
    _couponPriceLabel.attributedText = couponABS;
    
    _goodModel = goodModel;
    
}


@end
