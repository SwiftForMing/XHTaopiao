//
//  ClassifyViewController.h
//  TaoPiao
//
//  Created by 黎应明 on 2017/8/30.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import "BaseViewController.h"

@interface ClassifyViewController : BaseViewController
// searchBar
@property (nonatomic, retain) UISearchBar *bar;
// 搜索使用的表示图控制器
@property (nonatomic, retain) UITableViewController *searchTVC;
// mySearchController
@property (nonatomic, retain) UISearchController *mySearchController;
// 存放所有数据的数组
@property (nonatomic, retain) NSMutableArray *allDataArray;
// 存放搜索出结果的数组
@property (nonatomic, retain) NSMutableArray *searchResultDataArray;
@end
