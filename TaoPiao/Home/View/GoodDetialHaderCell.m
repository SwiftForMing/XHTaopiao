//
//  GoodDetialHaderCell.m
//  TaoPiao
//
//  Created by 黎应明 on 2017/9/12.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import "GoodDetialHaderCell.h"

@implementation GoodDetialHaderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _baoyouLabel.layer.masksToBounds = YES;
    _baoyouLabel.layer.cornerRadius = 10;
    // Initialization code
}

-(void)setGoodModel:(HomeGoodModel *)goodModel{
    NSURL *url = [[NSURL alloc]initWithString:goodModel.good_header];
    [_headerImageView sd_setImageWithURL:url placeholderImage:nil];
    _goonNameLabel.text = goodModel.good_name;
    
    NSString *afterPrice = [NSString stringWithFormat:@"¥%@ 券后价",goodModel.after_coupons_price];
    NSMutableAttributedString *afterAstr = [[NSMutableAttributedString alloc]initWithString:afterPrice];
    [afterAstr addAttribute:NSStrokeColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, afterPrice.length)];
     [afterAstr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:[afterPrice rangeOfString:[NSString stringWithFormat:@"¥%@",goodModel.after_coupons_price]]];

    _afterPriceLabel.textColor = [UIColor redColor];
    _afterPriceLabel.attributedText = afterAstr;
     NSString *price = [NSString stringWithFormat:@"原价¥%@",goodModel.good_price];
    NSMutableAttributedString *aPrice = [[NSMutableAttributedString alloc]initWithString:price];
    [aPrice addAttributes:@{
                           
                           NSStrikethroughStyleAttributeName:@(NSUnderlineStyleThick),
                           
                           NSForegroundColorAttributeName:
                               
                               [UIColor lightGrayColor],
                           
                           NSBaselineOffsetAttributeName:
                               
                               @(0),
                           
                           NSFontAttributeName: [UIFont systemFontOfSize:12]
                           
                           } range:NSMakeRange(0, price.length)];
    _normalPriceLabel.attributedText = aPrice;
    
}

@end
