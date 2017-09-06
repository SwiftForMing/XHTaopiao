//
//  MyHeaderView.m
//  TaoPiao
//
//  Created by 黎应明 on 2017/8/31.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import "MyHeaderView.h"

@implementation MyHeaderView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.headImage.layer.cornerRadius = 40;
    self.headImage.layer.borderColor = [UIColor grayColor].CGColor;
    self.headImage.layer.borderWidth = 1;
    self.headImage.layer.masksToBounds = YES;
    
}


@end
