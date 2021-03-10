//
//  ImageController.m
//  iOSMetalDemo
//
//  Created by 高明阳 on 2021/3/9.
//

#import "ImageController.h"
#import "ImageRender.h"
#import "Masonry.h"
@interface ImageController ()
{
    ImageRender *_renderer;
}
@property (nonatomic,strong)MTKView *myMTKView;
@end

@implementation ImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"图片渲染";
    self.view.backgroundColor = [UIColor whiteColor];
    [self commonInit];
}
-(void)commonInit{
    [self addMySubViews];
    [self addMyContraints];
    [self initMetal];
}
-(void)addMySubViews{
    [self.view addSubview:self.myMTKView];
}
-(void)addMyContraints{
    [self.myMTKView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(0);
    }];
}
-(void)initMetal{
    //一个MTLDevice 对象就代表这着一个GPU,通常我们可以调用方法MTLCreateSystemDefaultDevice()来获取代表默认的GPU单个对象.
    self.myMTKView.device = MTLCreateSystemDefaultDevice();
        
        if(!self.myMTKView.device)
        {
            NSLog(@"Metal is not supported on this device");
            return;
        }
        
        //创建Render
        _renderer = [[ImageRender alloc] initWithMetalKitView:self.myMTKView];
        
        if(!_renderer)
        {
            NSLog(@"Renderer failed initialization");
            return;
        }
        
        //用视图大小初始化渲染器
        [_renderer mtkView:self.myMTKView drawableSizeWillChange:self.myMTKView.drawableSize];
        
        //设置MTKView代理
    self.myMTKView.delegate = _renderer;
}
#pragma mark -- lazy load
- (MTKView *)myMTKView{
    if (_myMTKView == nil) {
        _myMTKView = [MTKView new];
    }
    return _myMTKView;
}
@end
