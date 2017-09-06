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
-(void)setGoodModel:(HomeGoodModel *)goodModel{
    
    
    NSURL *url = [[NSURL alloc]initWithString:goodModel.good_header];
    [_headerImageView sd_setImageWithURL:url placeholderImage:nil];
    
    _nameLabel.text = goodModel.good_name;
    
    NSString *price =  [NSString stringWithFormat:@"劵后价￥%@",goodModel.after_coupons_price];
    NSString *couponsPrice =  [NSString stringWithFormat:@"￥%@",goodModel.good_price];
    NSString *lastPrice = [NSString stringWithFormat:@"%@%@",price,couponsPrice];
    //label的富文本
    NSMutableAttributedString *text1 = [[NSMutableAttributedString alloc] initWithString:lastPrice];
    [text1 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, text1.length)];
    
    [text1 addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, price.length)];
    [text1 addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(price.length, couponsPrice.length)];
    
    [text1 addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineByWord] range:NSMakeRange(price.length, couponsPrice.length)];
    [text1 addAttribute:NSStrikethroughColorAttributeName value:[UIColor grayColor] range:NSMakeRange(price.length, couponsPrice.length)];
    _priceLabel.attributedText = text1;
    
    _timeLabel.text = goodModel.valid_date;
    
    _goodModel = goodModel;
    
}


@end
