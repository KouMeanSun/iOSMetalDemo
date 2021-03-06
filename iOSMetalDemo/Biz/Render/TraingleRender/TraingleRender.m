//
//  TraingleRender.m
//  iOSMetalDemo
//
//  Created by 高明阳 on 2021/3/8.
//

#import "TraingleRender.h"
//头 在C代码之间共享，这里执行Metal API命令，和.metal文件，这些文件使用这些类型作为着色器的输入。
#import "TraingleShanderTypes.h"

@implementation TraingleRender
{
    id<MTLDevice>               _device;
    id<MTLRenderPipelineState>  _piplineState;
    id<MTLCommandQueue>         _commandQueue;
    vector_uint2                _viewportSize;
}
- (instancetype)initWithMTKView:(MTKView *)mtkView{
    self = [super init];
    if (self) {
        NSError *error = NULL;
        _device = mtkView.device;
        // 在项目中加载所有的(.metal)着色器文件
        // 从bundle中获取.metal文件
        id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
        //从库中加载顶点函数
        id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"traingleVertexShader"];
        //从库中加载片元函数
        id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"traingleFragmentShader"];
        //配置用于创建管道配置的管道
        MTLRenderPipelineDescriptor *pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
        //管道名称
        pipelineDescriptor.label = @"Trangle PipLine";
        //可编程函数,用于处理渲染过程中的各个顶点
        pipelineDescriptor.vertexFunction = vertexFunction;
        //可编程哈数，用于处理渲染过程中的各个片元
        pipelineDescriptor.fragmentFunction = fragmentFunction;
        //一组存储颜色数据的组件
        pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;
        //同步创建并返回渲染管线状态对象
        _piplineState = [_device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&error];
        //判断是否返回了管道状态对象
        if(_piplineState == nil){
            //如果我们没有正确设置管道描述符，则管道状态创建可能失败
                        NSLog(@"Failed to created pipeline state, error %@", error);
                        return nil;
        }
        //创建命令队列
        _commandQueue = [_device newCommandQueue];
    }
    return self;
}
- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size{
    // 保存可绘制的大小，因为当我们绘制时，我们将把这些值传递给顶点着色器
        _viewportSize.x = size.width;
        _viewportSize.y = size.height;
}
- (void)drawInMTKView:(MTKView *)view{
    static TraingleVertex triangleVertices[] = {
      //2D顶点，RGBA颜色
        {{250,-250},{1,0,0,1}},
        {{-250,-250},{0,1,0,1}},
        {{0,250},{0,0,1,1}},
    };
    //为当前渲染的每个渲染传递创建一个新的命令缓冲区
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    //指定缓冲区名称
    commandBuffer.label = @"Traingle CommandBuffer";
    // MTLRenderPassDescriptor:一组渲染目标，用作渲染通道生成的像素的输出目标。
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    //判断是否为空
    if(renderPassDescriptor != nil){
        //创建渲染命令编码器
        id<MTLRenderCommandEncoder>  renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        //渲染器名称
        renderEncoder.label = @"Traingle RenderEncoder";
        //设置我们可绘制的区域
        /*
                typedef struct {
                    double originX, originY, width, height, znear, zfar;
                } MTLViewport;
                 */
        MTLViewport viewport = {
          0.0,0.0,_viewportSize.x,_viewportSize.y,-1.0,1.0
        };
        [renderEncoder setViewport:viewport];
        //设置当前渲染管道对象状态
        [renderEncoder setRenderPipelineState:_piplineState];
        //从应用程序ObJC 代码 中发送数据给Metal 顶点着色器 函数
        // This call has 3 arguments
        //   1) 指向要传递给着色器的内存的指针
        //   2) 我们想要传递的数据的内存大小
        //   3)一个整数索引，它对应于我们的“vertexShader”函数中的缓冲区属性限定符的索引。
        [renderEncoder setVertexBytes:triangleVertices length:sizeof(triangleVertices) atIndex:TraingleVertexInputIndexVertices];
        //1) 发送到顶点着色函数中,视图大小
        //2) 视图大小内存空间大小
        //3) 对应的索引
        [renderEncoder setVertexBytes:&_viewportSize length:sizeof(_viewportSize) atIndex:TraingleVertexInputIndexViewportSize];
        //画出三角形的3个顶点
        // @method drawPrimitives:vertexStart:vertexCount:
        //@brief 在不使用索引列表的情况下,绘制图元
        //@param 绘制图形组装的基元类型
        //@param 从哪个位置数据开始绘制,一般为0
        //@param 每个图元的顶点个数,绘制的图型顶点数量
        /*
            MTLPrimitiveTypePoint = 0, 点
            MTLPrimitiveTypeLine = 1, 线段
            MTLPrimitiveTypeLineStrip = 2, 线环
            MTLPrimitiveTypeTriangle = 3,  三角形
            MTLPrimitiveTypeTriangleStrip = 4, 三角型扇
         */
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
        //表示已该编码器生成的命令都已完成,并且从NTLCommandBuffer中分离
        [renderEncoder endEncoding];
        //一旦框架缓冲区完成，使用当前可绘制的进度表
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    //最后,在这里完成渲染并将命令缓冲区推送到GPU
    [commandBuffer commit];
}
@end
