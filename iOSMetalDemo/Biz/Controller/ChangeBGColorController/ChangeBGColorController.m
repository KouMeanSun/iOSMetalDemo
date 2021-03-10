//
//  ChangeBGColorController.m
//  iOSMetalDemo
//
//  Created by 高明阳 on 2021/3/8.
//

#import "ChangeBGColorController.h"
#import "Masonry.h"
#import "ChangeColorRender.h"
@interface ChangeBGColorController ()
{
    ChangeColorRender *_render;
}
@property(nonatomic,strong)MTKView *myMTKView;
@end

@implementation ChangeBGColorController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    [self commonInit];
}
-(void)commonInit{
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
    //一个MTKDevice 对象，代表着一个gpu，通常我们可以调用方法，MTLCreateSystemDefaultDevice()来获取代表默认的GPU对象
    self.myMTKView.device = MTLCreateSystemDefaultDevice();
    if(_myMTKView == nil){
        NSLog(@"Metal is not supported on this device");
        return;
    }
    //创建Render
    _render = [[ChangeColorRender alloc] initWithMetalKitView:self.myMTKView];
    if(_render == nil){
        NSLog(@"Renderer failed initialization");
        return;
    }
    //设置MTKView 的代理
    self.myMTKView.delegate = _render;
    //视图可以根据视图属性上的帧速率，(指定时间来调用drawInMTKView方法)
    self.myMTKView.preferredFramesPerSecond = 60;
}

#pragma mark -- lazy load
- (MTKView *)myMTKView{
    if (_myMTKView == nil) {
        _myMTKView = [[MTKView alloc] init];
    }
    return _myMTKView;
}
@end
