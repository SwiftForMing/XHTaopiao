//
//  GoodsFightModel.h
//  DuoBao
//
//  Created by clove on 5/11/17.
//  Copyright © 2017 linqsh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoodsModel.h"


@interface GoodsFightModel : NSObject
@property (nonatomic, copy) NSString *id;
@property (nonatomic, strong) GoodsModel *goodsModel;
@property (nonatomic, copy) NSString *good_period;
@property (nonatomic, copy) NSString *need_people;
@property (nonatomic, copy) NSString *now_people;
@property (nonatomic, copy) NSString *progress;
@property (nonatomic, copy) NSString *good_single_price;
@property (nonatomic, copy) NSString *is_happybean_goods;       // 商品类型
@property (nonatomic, copy) NSString *part_sanpei;
@property (nonatomic, copy) NSString *add_caipiao;

+ (GoodsFightModel *)createWithDictionary:(NSDictionary *)dictionary;

- (int)minCount;
- (int)maxCount;
- (int)remainderCount;
- (int)cardinalNumber;  // 每人次的价值(抽奖币／欢乐豆)
- (NSArray *)recommendedPurchaseOptions;

// 货币单位  元／欢乐豆
- (NSString *)unitCurrency;

- (GoodsType)goodsType;

// 还需要的抽奖币／欢乐豆
- (int)remainderCoin;


@end
