//
//  ChangeColorRender.m
//  iOSMetalDemo
//
//  Created by 高明阳 on 2021/3/8.
//

#import "ChangeColorRender.h"

@implementation ChangeColorRender
{
    id<MTLDevice>  _device;
    id<MTLCommandQueue> _commandQueue;
}
typedef struct {
    float red,green,blue,alpha;
}Color;

- (instancetype)initWithMetalKitView:(MTKView *)mtkView{
    self = [super init];
    if (self) {
        _device = mtkView.device;
        _commandQueue = [_device newCommandQueue];
        
    }
    return self;
}

//设置颜色
-(Color)makeFancyColor{
    //增加，减小颜色的标记
    static BOOL   growing = YES;
    //颜色通道值
    static NSUInteger primaryChannel = 0;
    //颜色通道数组
    static float colorChannels[] = {1.0,0.0,0.0,1.0};
    const float DynamicColorRate = 0.015;
    if(growing){
        //动态信道索引
        NSUInteger dynamicChannelIndex = (primaryChannel+1)%3;
        //修改对应动态通道的颜色值 ，调整0.015
        colorChannels[dynamicChannelIndex] += DynamicColorRate;
        //当前颜色通道对应的颜色的值
        if(colorChannels[dynamicChannelIndex] >= 1.0){
            //设置NO
            growing = NO;
            primaryChannel = dynamicChannelIndex;
        }
    }else {
        //获取动态颜色通道
        NSUInteger dynamicChannelIndex = (primaryChannel +2 )%3;
        //修改对应动态通道的颜色值,调整0.015
        colorChannels[dynamicChannelIndex] -= DynamicColorRate;
        //当颜色值小于等于0.0
        if(colorChannels[dynamicChannelIndex] <= 0.0){
            growing = YES;
        }
    }
    
    //创建颜色
    Color color;
    //修改颜色的RBGA 值
    color.red = colorChannels[0];
    color.green = colorChannels[1];
    color.blue = colorChannels[2];
    color.alpha = colorChannels[3];
    
    return  color;
}

#pragma mark -- MTKViewDelegate methods
-(void)drawInMTKView:(MTKView *)view{
    Color color = [self makeFancyColor];
    //设置清屏颜色
    view.clearColor = MTLClearColorMake(color.red, color.green, color.blue, color.alpha);
    /**
        使用MTLCommandQueue ，创建对象，并加入到MTLCommandBuffer中去
        为当前渲染的每个渲染创建一个新的命令缓冲区
     */
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"MyCommandBuffer";
    //从视图绘制中，获得渲染描述内容
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    //判断 renderPassDescriptor 是否渲染成功，否则跳过任何渲染
    if(renderPassDescriptor != nil){
        //通过渲染描述符创建MTLRenderCommandEncoder 对象
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderEncoder.label = @"MyRenderEncoder";
        //我们可以使用MTLRenderCommandEncoder来绘制对象，这里只使用了编码，
        [renderEncoder endEncoding];
        /**
         当编码器结束后，命令缓存区就会接受两个命令
         1)present
         2)commit
         因为GPU不会直接绘制到屏幕上，因此你不给出去指令，是不会有任何内容渲染到屏幕上的
         */
        //添加最后一条命令来显示清楚的可绘制的屏幕
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    //这里完成渲染并将命令缓冲区提交给GPU
    [commandBuffer commit];
}
- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size{
    
}
@end
