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

-(void)setUserInfo:(UserInfo *)userInfo{
    
    if (userInfo.nick_name) {
        _nameLabel.text = [NSString stringWithFormat:@"%@",userInfo.nick_name];
    }
    
    if (userInfo.user_header) {
        NSURL *headerUrl = [[NSURL alloc]initWithString:userInfo.user_header];
        [_headImage sd_setImageWithURL:headerUrl placeholderImage:nil];
    }
    
        _moneyLabel.text = [NSString stringWithFormat:@"余额:%.2f",userInfo.user_money];
   

    
}

@end
