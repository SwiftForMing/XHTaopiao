//
//  SimGoodCell.m
//  TaoPiao
//
//  Created by 黎应明 on 2017/9/12.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import "SimGoodCell.h"

@implementation SimGoodCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)setGoodModel:(HomeGoodModel *)goodModel{
    
    NSURL *url = [[NSURL alloc]initWithString:goodModel.good_header];
    [_goodImageView sd_setImageWithURL:url placeholderImage:nil];
    _goodNameLabel.text = goodModel.good_name;
//    _goodColorLabel.text = goodModel.
    _goodPriceLabel.text = [NSString stringWithFormat:@"¥%@",goodModel.good_price];;

}
@end
