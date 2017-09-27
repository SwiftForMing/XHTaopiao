//
//  BaseTabBarViewController.m
//  TaoPiao
//
//  Created by 黎应明 on 2017/8/30.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import "BaseTabBarViewController.h"
#import "MyViewController.h"
#import "ClassifyViewController.h"
#import "HomeViewController.h"
#import "CouponViewController.h"
#import "BaseNavViewController.h"
#import "BaseTableViewController.h"
@interface BaseTabBarViewController ()

@end

@implementation BaseTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *tabBarImageNameNormal = @"default_tab_icon_home";
    NSString *tabBarImageNameSelected = @"select_tab_icon_home";
    NSString *title = @"首页";
    HomeViewController *homeVC = [[HomeViewController alloc] initWithTableViewStyle:1];
    BaseNavViewController *homeNav = [[BaseNavViewController alloc] initWithRootViewController:homeVC];
    UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:[UIImage imageNamed:tabBarImageNameNormal] selectedImage:[UIImage imageNamed:tabBarImageNameSelected]];
    tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -2);
    homeVC.tabBarItem = tabBarItem;
       
    ClassifyViewController *classifyVC = [[ClassifyViewController alloc] initWithNibName:@"ClassifyViewController" bundle:nil];
    BaseNavViewController *classifyNav = [[BaseNavViewController alloc] initWithRootViewController:classifyVC];
    tabBarImageNameNormal = @"default_tab_icon_classificatition";
    tabBarImageNameSelected = @"select_tab_icon_classificatition";
    title = @"分类";
    tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:[UIImage imageNamed:tabBarImageNameNormal] selectedImage:[UIImage imageNamed:tabBarImageNameSelected]];
    tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -2);
    classifyVC.tabBarItem = tabBarItem;
    
    CouponViewController *couponVC = [[CouponViewController alloc]initWithTableViewStyle:1];
    BaseNavViewController *couponNav = [[BaseNavViewController alloc] initWithRootViewController:couponVC];
    tabBarImageNameNormal = @"default_tab_icon_coupon";
    tabBarImageNameSelected = @"select_tab_icon_coupon";
    title = @"优惠劵";
    tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:[UIImage imageNamed:tabBarImageNameNormal] selectedImage:[UIImage imageNamed:tabBarImageNameSelected]];
    tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -2);
    couponVC.tabBarItem = tabBarItem;

    MyViewController *myVC = [[MyViewController alloc]initWithTableViewStyle:1];
    BaseNavViewController *myNav = [[BaseNavViewController alloc] initWithRootViewController:myVC];
    tabBarImageNameNormal = @"default_tab_icon_me";
    tabBarImageNameSelected = @"select_tab_icon_me";
    title = @"我的";
    tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:[UIImage imageNamed:tabBarImageNameNormal] selectedImage:[UIImage imageNamed:tabBarImageNameSelected]];
//    tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:nil selectedImage:nil];
    tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -2);
    myVC.tabBarItem = tabBarItem;
    
    NSArray *navArray = [NSArray arrayWithObjects:homeNav,classifyNav,couponNav,myNav, nil];
    [self setViewControllers:navArray];
   
}




@end
