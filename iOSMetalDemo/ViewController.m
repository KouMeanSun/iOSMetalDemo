//
//  ViewController.m
//  iOSMetalDemo
//
//  Created by 高明阳 on 2021/3/8.
//

#import "ViewController.h"
#import "Masonry.h"
#import "MainPageCell.h"
#import "ChangeBGColorController.h"
#import "TraingleController.h"
#import "MutilpleGraphController.h"
#import "ImageController.h"
#import "ImageFilterController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
///内容tableview
@property (nonatomic,strong)UITableView *tableView;
///内容数据源
@property (nonatomic,strong)NSMutableArray *dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

-(void)commonInit{
    self.title = @"Metal Learn";
    self.view.backgroundColor = [UIColor whiteColor];
    [self initDataSourceData];
    [self addMySubViews];
    [self addMyContraints];
}
-(void)initDataSourceData{
    [self.dataSource addObject:@"改变view背景色"];
    [self.dataSource addObject:@"绘制三角形"];
    [self.dataSource addObject:@"绘制多边形"];
    [self.dataSource addObject:@"图片纹理加载"];
    [self.dataSource addObject:@"图片滤镜"];
}
-(void)addMySubViews{
    [self.view addSubview:self.tableView];
}
-(void)addMyContraints{
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(84);
        make.left.bottom.right.mas_equalTo(0);
    }];
}


#pragma mark -- UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MainPageCell *cell = [tableView dequeueReusableCellWithIdentifier:MainPageCell.ID];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setCellData:self.dataSource[indexPath.row] indexPath:indexPath];
//    typeof(self) weakSelf = self;
//    [cell setBlock:^(NSIndexPath * _Nonnull cellIndexPath) {
//        typeof(weakSelf) strongSelf = weakSelf;
//        [strongSelf cellCallBlock:cellIndexPath];
//    }];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [self.navigationController pushViewController:[ChangeBGColorController new] animated:YES];
    }else if(indexPath.row == 1){
        [self.navigationController pushViewController:[TraingleController new] animated:YES];
    }else if(indexPath.row == 2){
        [self.navigationController pushViewController:[MutilpleGraphController new] animated:YES];
    }else if(indexPath.row == 3){
        [self.navigationController pushViewController:[ImageController new] animated:YES];
    }else if(indexPath.row == 4){
        [self.navigationController pushViewController:[ImageFilterController new] animated:YES];
    }
}

#pragma mark -- lazy load
-(UITableView *)tableView{
    if (_tableView == nil  ) {
        _tableView = [[UITableView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        if (@available(iOS 11.0, *)) {
            _tableView.estimatedRowHeight = 0;
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_tableView registerClass:[MainPageCell class] forCellReuseIdentifier:MainPageCell.ID];
    }
    return _tableView;
}
- (NSMutableArray *)dataSource{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray new];
    }
    return _dataSource;
}
@end
