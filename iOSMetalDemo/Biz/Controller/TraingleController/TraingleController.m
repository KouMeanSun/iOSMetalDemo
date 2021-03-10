//
//  TraingleController.m
//  iOSMetalDemo
//
//  Created by 高明阳 on 2021/3/8.
//

#import "TraingleController.h"
#import "Masonry.h"
#import "TraingleRender.h"
@import MetalKit;

@interface TraingleController ()
{
    TraingleRender *_render;
}
@property (nonatomic,strong)MTKView *myMTKView;

@end

@implementation TraingleController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

-(void)commonInit{
    self.title = @"绘制三角形";
    self.view.backgroundColor = [UIColor whiteColor];
    [self addMySubViews];
    [self addMyContraints];
    [self initMTKView];
}
-(void)addMySubViews{
    [self.view addSubview:self.myMTKView];
}
-(void)addMyContraints{
    [self.myMTKView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(0);
    }];
}
-(void)initMTKView{
    self.myMTKView.device = MTLCreateSystemDefaultDevice();
    if(self.myMTKView == nil){
        NSLog(@"Metal is not supported on this device");
                return;
    }
    _render = [[TraingleRender alloc] initWithMTKView:self.myMTKView];
    if(_render == nil)
    {
            NSLog(@"Renderer failed initialization");
            return;
    }
    [_render mtkView:self.myMTKView drawableSizeWillChange:self.myMTKView.drawableSize];
    self.myMTKView.delegate = _render;
}
#pragma mark -- lazy load
- (MTKView *)myMTKView{
    if (_myMTKView == nil) {
        _myMTKView = [[MTKView alloc] init];
    }
    return _myMTKView;
}
@end
