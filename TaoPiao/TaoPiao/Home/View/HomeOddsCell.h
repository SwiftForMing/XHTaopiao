//
//  HomeOddsCell.h
//  TaoPiao
//
//  Created by 黎应明 on 2017/9/5.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeOddsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftImageWidth;
@property (weak, nonatomic) IBOutlet UIImageView *rightUPImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightDownImageView;

@end
