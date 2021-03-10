//
//  MutilpleGraphController.m
//  iOSMetalDemo
//
//  Created by 高明阳 on 2021/3/9.
//

#import "MutilpleGraphController.h"
#import "MultipleGraphRender.h"
#import "Masonry.h"

@interface MutilpleGraphController ()
{
    MultipleGraphRender *_render;
}
@property (nonatomic,strong)MTKView *myMTKView;

@end

@implementation MutilpleGraphController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"绘制多边形";
    self.view.backgroundColor = [UIColor whiteColor];
    [self commonInit];
}

-(void)commonInit{
    [self addMySubViews];
    [self addMyConstraints];
    [self initMetal];
}
-(void)addMySubViews{
    [self.view addSubview:self.myMTKView];
}
-(void)addMyConstraints{
    [self.myMTKView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(0);
    }];
}
-(void)initMetal{
    self.myMTKView.device = MTLCreateSystemDefaultDevice();
    if (self.myMTKView.device == nil) {
        NSLog(@"Metal is not supported on this device");
                return;
    }
    _render = [[MultipleGraphRender alloc] initWithMetalKitView:self.myMTKView];
    if (_render == nil) {
        NSLog(@"Renderer failed initialization");
                return;
    }
    [_render mtkView:self.myMTKView drawableSizeWillChange:self.myMTKView.drawableSize];
    self.myMTKView.delegate = _render;
}
#pragma mark -- lazy load
- (MTKView *)myMTKView{
    if (_myMTKView == nil) {
        _myMTKView  = [[MTKView alloc] init];
    }
    return  _myMTKView;
}
@end
