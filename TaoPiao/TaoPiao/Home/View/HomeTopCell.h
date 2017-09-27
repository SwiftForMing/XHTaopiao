//
//  HomeTopCell.h
//  TaoPiao
//
//  Created by 黎应明 on 2017/9/5.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeGoodModel.h"

@interface HomeTopCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *goodPriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UIImageView *priceImageView;
@property (weak, nonatomic) IBOutlet UILabel *afterPriceLabel;
@property(nonatomic,strong)HomeGoodModel *goodModel;
@property (weak, nonatomic) IBOutlet UILabel *couponName;
@property (weak, nonatomic) IBOutlet UILabel *goodNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *couponPriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *lqBtn;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@end
