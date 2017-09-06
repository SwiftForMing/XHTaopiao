//
//  HomeOddsCell.m
//  TaoPiao
//
//  Created by 黎应明 on 2017/9/5.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import "HomeOddsCell.h"

@implementation HomeOddsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.leftImageWidth.constant = ScreenWidth/2-10;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
