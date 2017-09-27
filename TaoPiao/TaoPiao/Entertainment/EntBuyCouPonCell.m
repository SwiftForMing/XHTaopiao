//
//  EntBuyCouPonCell.m
//  TaoPiao
//
//  Created by 黎应明 on 2017/9/20.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import "EntBuyCouPonCell.h"

@implementation EntBuyCouPonCell{
    
    int num;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

-(void)setCouponModel:(CouponModel *)couponModel{
    
    NSURL *url = [[NSURL alloc]initWithString:couponModel.good_header];
    [_goodHeader sd_setImageWithURL:url placeholderImage:nil];
    //    _priceImageView.hidden = YES;
    
    _nameLabel.text = couponModel.coupons_name;
    //    _goodNameLabel.text = couponModel.status;
    _goodNameLabel.textColor = [UIColor grayColor];
    _goodNameLabel.text = couponModel.good_name;
    _timeLabel.text = [NSString stringWithFormat:@"有效期:%@",couponModel.valid_date];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = [UIColor grayColor];
    
    NSString *price =  [NSString stringWithFormat:@"劵后价￥%@",couponModel.after_coupons_price];
    NSString *normalPrice =  [NSString stringWithFormat:@"￥%@",couponModel.good_price];
    _afterPriceLabel.text  = price;
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
    
    _priceLabel.attributedText = text1;
    _numLabel.text = @"0";
    num = 0;
    [_leftBtn addTarget:self action:@selector(subNum) forControlEvents:UIControlEventTouchUpInside];
    [_rightBtn addTarget:self action:@selector(addNum) forControlEvents:UIControlEventTouchUpInside];
    _couponModel = couponModel;
}

-(void)subNum{
    int value;
    if (num<=0) {
        num = 0;
        value = 0;
    }else{
        num -= 1;
        value = [_couponModel.coupons_price intValue]*(-1);
    }
    _numLabel.text = [NSString stringWithFormat:@"%d",num];
    [self.delegate sendValue:value Model:_couponModel];
}

-(void)addNum{
    int value;
    value = [_couponModel.coupons_price intValue];
    num ++;
    _numLabel.text = [NSString stringWithFormat:@"%d",num];

    [self.delegate sendValue:[_couponModel.coupons_price intValue] Model:_couponModel];
}
@end
