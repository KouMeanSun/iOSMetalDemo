//
//  MainPageCell.m
//  VideoEditorDemo
//
//  Created by 高明阳 on 2021/3/1.
//

#import "MainPageCell.h"
#import "Masonry.h"

@interface MainPageCell()
@property (nonatomic,strong)UIButton *btn;
@property (nonatomic,strong)NSIndexPath *indexPath;
@end

@implementation MainPageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self commonInit];
    }
    return self;
}

-(void)commonInit{
    [self addMySubViews];
    [self addMyContraints];
}

-(void)addMySubViews{
    [self addSubview:self.btn];
}

-(void)addMyContraints{
    [self.btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(35);
        make.top.mas_equalTo(self.mas_top).offset(10);
    }];
}

#pragma mark -- click

-(void)btnClick:(UIButton *)btn{
    NSLog(@"点击了cell 的按钮");
    if (self.block) {
        self.block(self.indexPath);
    }
}


- (void)setCellData:(NSString *)title indexPath:(nonnull NSIndexPath *)indexPath{
    [self.btn setTitle:title forState:UIControlStateNormal];
    self.indexPath = indexPath;
}

+ (NSString *)ID{
    return @"MainPageCell";
}
#pragma mark -- lazy load
- (UIButton *)btn{
    if(_btn == nil){
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        _btn.backgroundColor = [UIColor orangeColor];
        [_btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn;
}
@end
