//
//  HomePageViewController.h
//  DuoBao
//
//  Created by gthl on 16/2/11.
//  Copyright © 2016年 linqsh. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HomePageViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

// 点击首页tab，刷新间隔30秒，自动刷新
- (void)autorefresh;

@end
