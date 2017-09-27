//
//  MallCollectionViewController.m
//  DuoBao
//
//  Created by clove on 5/11/17.
//  Copyright © 2017 linqsh. All rights reserved.
//

#import "MallCollectionViewController.h"
#import "MallCollectionViewCell.h"
#import "GoodsFightModel.h"
#import "YYKitMacro.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "SelectGoodsNumViewController.h"
#import "PaySuccessTableViewController.h"
#import "GoodsDetailInfoViewController.h"
#import "MallCollectionViewFlowLayout.h"

@interface MallCollectionViewController ()<SelectGoodsNumViewControllerDelegate>
@property (nonatomic, strong) NSArray *modelList;

@end

@implementation MallCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.title = @"欢乐商城";
    
    // Register cell classes
    [self.collectionView registerNib:[UINib nibWithNibName:@"MallCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    
//    MallCollectionViewFlowLayout *layout = [[MallCollectionViewFlowLayout alloc] init];
//    layout.invalidateFlowLayoutDelegateMetrics = YES;
//    
//    //设置大小
//    layout.itemSize = CGSizeMake(ScreenWidth/2-0.5, 206*UIAdapteRate);
//    layout.scrollDirection = UICollectionViewScrollDirectionVertical;    
//    layout.minimumInteritemSpacing = ScreenWidth - (ScreenWidth/2*2 -1);
//    layout.minimumLineSpacing = 1;
//    layout.sectionInset = UIEdgeInsetsZero;
//    
//    self.collectionView.collectionViewLayout = layout;
    
    [self request];
    
    [self leftNavigationItem];
    //手势返回
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;

}

- (void)leftNavigationItem
{
    UIControl *leftItemControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 20, 44)];
    [leftItemControl addTarget:self action:@selector(clickLeftItemAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *back = [[UIImageView alloc] initWithFrame:CGRectMake(0, 13, 10, 18)];
    back.image = [UIImage imageNamed:@"new_back"];
    [leftItemControl addSubview:back];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftItemControl];
}

- (void)clickLeftItemAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)request
{

    @weakify(self);
    [HttpHelper getMallGoods:1
                limitNum:100
                 success:^(NSDictionary *resultDic) {
                     @strongify(self);
                     NSLog(@"resultDic %@",resultDic);
                     NSDictionary *data = [resultDic objectForKey:@"data"];
                     NSArray *array = [data objectForKey:@"goodsList"];
                     
                     NSMutableArray *multArray = [NSMutableArray array];
                     for (NSDictionary *dictionary in array) {
                         GoodsFightModel *model = [GoodsFightModel createWithDictionary:dictionary];
                         [multArray addObject:model];
                     }
                     
                     self.modelList = multArray;
                     
                     [self.collectionView reloadData];
                     
                 } failure:^(NSString *description) {
                     
                 }];
}

- (void)purchaseGoods:(GoodsFightModel *)model
{
    UserInfo *userInfo = [ShareManager shareInstance].userinfo;
    int remainerThriceCoin = userInfo.happy_bean_num;
    int neededThriceCoin =  [model remainderCoin];
    if (neededThriceCoin > remainerThriceCoin) {
        NSString *message = [NSString stringWithFormat:@"欢乐豆余额不足，购买总需%d欢乐豆，玩三赔可获取更多欢乐豆～", neededThriceCoin];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
        [alert show];
    }
    

    SelectGoodsNumViewController *vc = [[SelectGoodsNumViewController alloc] initWithNibName:@"SelectGoodsNumViewController" bundle:nil];
    [vc reloadWithGoodsFightModel:model];
    vc.delegate = self;
    self.definesPresentationContext = YES; //self is presenting view controller
    vc.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    UIViewController * rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController presentViewController:vc animated:YES completion:nil];
}

#pragma mark - SelectGoodsNumViewControllerDelegate

- (void)selectGoodsNum:(int)num goodsFightModel:(GoodsFightModel *)model
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.removeFromSuperViewOnHide = YES;
    HUD.graceTime = 0.75;
    [HUD show:YES];
    
    
    NSMutableDictionary *payResultsDictionary = [NSMutableDictionary dictionary];

    NSString *goodsFightID = model.id;
    NSString *good_period = model.good_period;
    NSString *goodsID = model.goodsModel.good_id;
    NSString *good_name = model.goodsModel.good_name;
    int purchasedThriceCoin = [model.good_single_price intValue] * num;
    int costedThriceCoin = purchasedThriceCoin;
    int purchasedTimes = 1;
    
    if (purchasedThriceCoin > 0) {
        [payResultsDictionary setObject:[NSString stringWithFormat:@"%d", purchasedThriceCoin] forKey:@"purchasedThriceCoin"];
    }
    if (costedThriceCoin > 0) {
        [payResultsDictionary setObject:[NSString stringWithFormat:@"%d", costedThriceCoin] forKey:@"costedThriceCoin"];
    }
    if (purchasedTimes > 0) {
        [payResultsDictionary setObject:[NSString stringWithFormat:@"%d", purchasedTimes] forKey:@"purchasedTimes"];
    }
    if (good_period) {
        [payResultsDictionary setObject:good_period forKey:@"good_period"];
    }
    
    [payResultsDictionary setObject:good_name?:@"" forKey:@"good_name"];

    
    @weakify(self);
    [HttpHelper purchaseWithThriceCoin:goodsFightID
                           goodsID:goodsID
                        thriceCoin:costedThriceCoin
                           success:^(NSDictionary *data) {
                               @strongify(self);

                               
                               HUD.taskInProgress = YES;
                               [HUD hide:YES];
                               
                               NSArray *results = [data objectForKey:@"results"];
                               if ([results isKindOfClass:[NSArray class]] && results.count > 0 && [results.firstObject isKindOfClass:[NSDictionary class]]) {
                                   
                                   [payResultsDictionary setObject:@"success" forKey:@"result"];
                                   PaySuccessTableViewController *vc = [PaySuccessTableViewController createWithData:payResultsDictionary];
                                   [self.navigationController pushViewController:vc animated:YES];
                               } else {
                                   
                                   [payResultsDictionary setObject:@"failure" forKey:@"result"];
                                   PaySuccessTableViewController *vc = [PaySuccessTableViewController createWithData:payResultsDictionary];
                                   [self.navigationController pushViewController:vc animated:YES];
                               }

                           } failure:^(NSString *description) {
                               
                               HUD.taskInProgress = YES;
                               [HUD hide:YES];

                               [payResultsDictionary setObject:@"failure" forKey:@"result"];
                               if (description) {
                                   [payResultsDictionary setObject:description forKey:@"description"];
                               }
                               PaySuccessTableViewController *vc = [PaySuccessTableViewController createWithData:payResultsDictionary];
                               [self.navigationController pushViewController:vc animated:YES];

                           }];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _modelList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MallCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    GoodsFightModel *model = [_modelList objectAtIndex:indexPath.row];
    
    cell.joinButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        [self purchaseGoods:model];
        return [RACSignal empty];
    }];
    
    [cell reloadWithObject:model];
    
    
    for (UIView *view in cell.contentView.subviews) {
        if (view.width < 1 || view.height < 1) {
            [view removeFromSuperview];
        }
    }
    
    [cell.contentView addSingleBorder:UIViewBorderDirectBottom color:[UIColor defaultTableViewSeparationColor] width:0.5];
    if ((indexPath.row+1) %2 == 1) {
        [cell.contentView addSingleBorder:UIViewBorderDirectRight color:[UIColor defaultTableViewSeparationColor] width:0.5];
    }
    
    return cell;
}

//定义每个Item 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.width/2, 206*UIAdapteRate);
}

//定义每个UICollectionView 的 margin
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0.0f;
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    GoodsFightModel *model = [_modelList objectAtIndex:indexPath.row];
    GoodsDetailInfoViewController *vc = [[GoodsDetailInfoViewController alloc] initWithNibName:@"GoodsDetailInfoViewController" bundle:nil];
    vc.goodId = model.id;
    [self.navigationController pushViewController:vc animated:YES];
}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
