//
//  HomeGoodModel.m
//  TaoPiao
//
//  Created by 黎应明 on 2017/9/5.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import "HomeGoodModel.h"

@implementation HomeGoodModel
- (NSString *)valid_date
{
    NSString *time = [Tool timeStringToDateSting:_valid_date format:@"yyyy-MM-dd "];;
    
    return time;
}
@end
