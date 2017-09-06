//
//  ClassifyViewController.m
//  TaoPiao
//
//  Created by 黎应明 on 2017/8/30.
//  Copyright © 2017年 黎应明. All rights reserved.
//

#import "ClassifyViewController.h"
#import "ClassifyCollectionViewCell.h"
#import "HomeViewController.h"
#import "GoodTypeModel.h"
#import "HomeTopCell.h"
#import "ClassifyTableViewController.h"
@interface ClassifyViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UISearchBarDelegate,UISearchResultsUpdating,UISearchControllerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *_dataArray;
    NSMutableArray *_searchArray;
    NSInteger _page;
    BOOL _first;
    NSString *searchKey;
    
}
@property(nonatomic,strong)UICollectionView *collectionview;



@end

@implementation ClassifyViewController



-(UICollectionView *)collectionview{
    if (!_collectionview) {
        UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc] init];
        flowlayout.minimumLineSpacing = 10;
        flowlayout.minimumInteritemSpacing = 10;
        _collectionview = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64, FullScreen.size.width, FullScreen.size.height) collectionViewLayout:flowlayout];
        _collectionview.delegate = self;
        _collectionview.dataSource = self;
        _collectionview.backgroundColor = [[UIColor alloc]initWithRed:233/255.0 green:233/255.0  blue:233/255.0 alpha:1];
    }
    return _collectionview;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.view.hidden = NO;
    self.navigationController.navigationBarHidden = YES;
    [self getData];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
  
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
    
    [self createSearchBar];
    _page = 0;
    _first = true;
    _dataArray = [NSMutableArray array];
    _searchArray = [NSMutableArray array];
    
    searchKey = @"";
    [self.view addSubview:self.collectionview];
    //注册Cell
    [self.collectionview registerNib:[UINib nibWithNibName:@"ClassifyCollectionViewCell" bundle:nil]  forCellWithReuseIdentifier:@"ClassifyCollectionViewCell"];
}

-(void)createSearchBar
{
    self.bar=[[UISearchBar alloc]init];
    //设置bar的frame
    self.bar.frame=CGRectMake(0, 20, ScreenWidth, 44);
    [self.view addSubview:self.bar];
    self.bar.placeholder = @"搜索";
    // searchBar  代理,记得签协议
    self.bar.delegate = self;
    self.bar.backgroundColor = [UIColor whiteColor];
    self.bar.barTintColor = [UIColor whiteColor];
    UITextField *searchField=[self.bar valueForKey:@"_searchField"];
    searchField.backgroundColor =  [[UIColor alloc]initWithRed:233/255.0 green:233/255.0  blue:233/255.0 alpha:1];


}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    // 创建出搜索使用的表示图控制器
    self.searchTVC = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    _searchTVC.tableView.dataSource = self;
    _searchTVC.tableView.delegate = self;
   
    // 使用表示图控制器创建出搜索控制器
    self.mySearchController = [[UISearchController alloc] initWithSearchResultsController:_searchTVC];
    // 搜索框检测代理
    //（这个需要遵守的协议是 <UISearchResultsUpdating> ，这个协议中只有一个方法，当搜索框中的值发生变化的时候，代理方法就会被调用）
    _mySearchController.searchResultsUpdater = self;
    _mySearchController.delegate = self;
    _mySearchController.searchBar.placeholder = @"搜索";
    _mySearchController.view.backgroundColor = [UIColor whiteColor];
    //  _searchController.searchBar.delegate = self;
    [self presentViewController:_mySearchController animated:YES completion:^{
        // 当模态推出这个searchController的时候,需要把之前的searchBar隐藏,如果希望搜索的时候看不到热门搜索什么的,可以把这个页面给隐藏
        self.bar.hidden = YES;
        self.view.hidden = YES;
        
    }];
}


- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    searchKey = searchController.searchBar.text;
    [self getSearchDataWithKey:searchController.searchBar.text];
}

-(void)didDismissSearchController:(UISearchController *)searchController{
    self.bar.hidden = NO;
    self.view.hidden = NO;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.bar.hidden = NO;
    self.view.hidden = NO;
}

// 设置搜索tableView section个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

// 设置搜索tableView cell个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_searchArray.count == 0) {
        MLog(@"33333");
        return 1;
    }
    return _searchArray.count;
}

// 设置搜索tableView的cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    if (_searchArray.count != 0) {
        HomeTopCell *cell = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:@"HomeTopCell"];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomeTopCell" owner:nil options:nil];
            cell = [nib objectAtIndex:0];
        }
        //设点点击选择的颜色(无)
        HomeGoodModel *model = [_searchArray objectAtIndex:indexPath.row];
        cell.goodModel = model;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }else{
        static NSString *cellIdentifier = @"indenfy";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.textLabel.text = @"没有查找的内容";
        cell.imageView.image = nil;
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 140;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 跳转操作
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{

    [_mySearchController.searchBar resignFirstResponder];
}


#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar

{   [searchBar resignFirstResponder];
    [self getSearchDataWithKey:searchBar.text];
   
}



-(void)getSearchDataWithKey:(NSString *)key{
    
    HttpHelper *helper = [HttpHelper helper];
    __weak ClassifyViewController *weakSelf = self;
    [helper getSearchKeyDataWithKeyWord:key success:^(NSDictionary *resultDic) {
        
        if ([[resultDic objectForKey:@"status"] integerValue] == 0) {
            MLog(@"resultDic:%@",resultDic);
            [self handleloadSearchResult:resultDic];
        }
    } fail:^(NSString *description) {
        [Tool showPromptContent:@"网络出错了" onView:weakSelf.view];
    }];
   
}
- (void)handleloadSearchResult:(NSDictionary *)resultDic
{
    NSDictionary *dic = [resultDic objectForKey:@"data"];
    NSArray *goodArray = [dic objectForKey:@"goodsSearchList"];
    if (goodArray) {
        if (_searchArray.count > 0) {
            [_searchArray removeAllObjects];
        }
        for (NSDictionary *dic in goodArray)
        {
            MLog(@"goodsSearchList:%@",dic);
            HomeGoodModel *info = [dic objectByClass:[HomeGoodModel class]];
            [_searchArray addObject:info];
        }
    }
    [_searchTVC.tableView reloadData];
    
  
}

#pragma mark 获取tableviewdata
-(void)getData{

    HttpHelper *helper = [HttpHelper helper];
    __weak ClassifyViewController *weakSelf = self;
    [helper getHttpWithUrlStr:URL_HomeBasics
                      success:^(NSDictionary *resultDic){
                          if ([[resultDic objectForKey:@"status"] integerValue] == 0) {
                              [weakSelf handleloadResult:resultDic];
                          }
                      }fail:^(NSString *decretion){
                          [Tool showPromptContent:@"网络出错了" onView:weakSelf.view];
                      }];
}

- (void)handleloadResult:(NSDictionary *)resultDic
{
    NSDictionary *dic = [resultDic objectForKey:@"data"];
    //推荐
    NSArray *tabArr = [dic objectForKey:@"goodsTypeList"];
    
    if (tabArr && tabArr.count > 0) {
        
        if (_dataArray.count > 0) {
            [_dataArray removeAllObjects];
        }
        
        for (NSDictionary *dict in tabArr)
        {
            GoodTypeModel* model = [dict objectByClass:[GoodTypeModel class]];
            
            [_dataArray addObject:model];
        }
    }
    [self.collectionview reloadData];
    
}

#pragma mark 定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark UICollectionView 的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataArray.count;
}


#pragma mark 每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ClassifyCollectionViewCell";
    
    ClassifyCollectionViewCell *cell = nil;
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil)
    {
        cell= [[[NSBundle  mainBundle]  loadNibNamed:@"ClassifyCollectionViewCell" owner:self options:nil]  firstObject];
    }
    GoodTypeModel *model = [_dataArray objectAtIndex:indexPath.row];
    cell.typeModel = model;
    
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
#pragma mark 定义每个Item 的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width/2-15, collectionView.frame.size.width/2-15);
}

#pragma mark 定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

#pragma mark 返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark 返回这个UICollectionView是否可以被选择
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ClassifyTableViewController *vc = [[ClassifyTableViewController alloc]initWithTableViewStyle:1];
    GoodTypeModel *model = _dataArray[indexPath.row];
    vc.goodID = model.id;
    vc.goodTitle = model.goods_type_name;
    [self.navigationController pushViewController:vc animated:YES];
    
    NSLog(@"%ld--%ld-%ld",(long)indexPath.item,indexPath.section,indexPath.row);
}

@end
