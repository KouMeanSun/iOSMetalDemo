//
//  ImageRender.m
//  iOSMetalDemo
//
//  Created by 高明阳 on 2021/3/9.
//

#import "ImageRender.h"
#import "Image.h"
#import "ImageShaderTypes.h"
@import simd;
@import MetalKit;

@implementation ImageRender
{
    // 我们用来渲染的设备(又名GPU)
    id<MTLDevice> _device;
    
    // 我们的渲染管道有顶点着色器和片元着色器 它们存储在.metal shader 文件中
    id<MTLRenderPipelineState> _pipelineState;
    
    // 命令队列,从命令缓存区获取
    id<MTLCommandQueue> _commandQueue;
    
    // Metal 纹理对象
    id<MTLTexture> _texture;
    
    // 存储在 Metal buffer 顶点数据
    id<MTLBuffer> _vertices;
    
    // 顶点个数
    NSUInteger _numVertices;
    
    // 当前视图大小,这样我们才可以在渲染通道使用这个视图
    vector_uint2 _viewportSize;
    
}

- (instancetype)initWithMetalKitView:(MTKView *)mtkView
{
    self = [super init];
    if(self)
    {
        _device = mtkView.device;
        
        //获取tag的路径
        NSURL *imageFileLocation = [[NSBundle mainBundle] URLForResource:@"Image"
                                                           withExtension:@"tga"];
        //创建Image对象
        Image *image = [[Image alloc]initWithTGAFileAtLocation:imageFileLocation];
        
        if(!image)
        {
            NSLog(@"Failed to create the image from:%@",imageFileLocation.absoluteString);
            return nil;
        }
        
        //创建纹理描述对象
        MTLTextureDescriptor *textureDescriptor = [[MTLTextureDescriptor alloc]init];
        
        //表示每个像素有蓝色,绿色,红色和alpha通道.其中每个通道都是8位无符号归一化的值.(即0映射成0,255映射成1);
        textureDescriptor.pixelFormat = MTLPixelFormatBGRA8Unorm;
        
        //设置纹理的像素尺寸
        textureDescriptor.width = image.width;
        textureDescriptor.height = image.height;
        
        //使用描述符从设备中创建纹理
        _texture = [_device newTextureWithDescriptor:textureDescriptor];
        
        //计算图像每行的字节数
        NSUInteger bytesPerRow = 4 * image.width;
        
        /*
         typedef struct
         {
         MTLOrigin origin; //开始位置x,y,z
         MTLSize   size; //尺寸width,height,depth
         } MTLRegion;
         */
        
        MTLRegion region = {
            {0,0,0},
            {image.width,image.height,1}
        };
        
        //复制图片数据到texture
        [_texture replaceRegion:region mipmapLevel:0 withBytes:image.data.bytes bytesPerRow:bytesPerRow];
        
        //根据顶点/纹理坐标建立一个MTLBuffer
        static const ImageVertex quadVertices[] = {
            //像素坐标,纹理坐标
            { {  250,  -250 },  { 1.f, 0.f } },
            { { -250,  -250 },  { 0.f, 0.f } },
            { { -250,   250 },  { 0.f, 1.f } },
            
            { {  250,  -250 },  { 1.f, 0.f } },
            { { -250,   250 },  { 0.f, 1.f } },
            { {  250,   250 },  { 1.f, 1.f } },

        };
        
        //创建我们的顶点缓冲区，并用我们的Qualsits数组初始化它
        _vertices = [_device newBufferWithBytes:quadVertices
                                         length:sizeof(quadVertices)
                                        options:MTLResourceStorageModeShared];
        //通过将字节长度除以每个顶点的大小来计算顶点的数目
        _numVertices = sizeof(quadVertices) / sizeof(ImageVertex);
        
        //创建我们的渲染通道
        //从项目中加载.metal文件,创建一个library
        id<MTLLibrary>defalutLibrary = [_device newDefaultLibrary];
        
        //从库中加载顶点函数
        id<MTLFunction>vertexFunction = [defalutLibrary newFunctionWithName:@"ImageVertexShader"];
        
        //从库中加载片元函数
        id<MTLFunction> fragmentFunction = [defalutLibrary newFunctionWithName:@"ImageFragmentShader"];
        
        //配置用于创建管道状态的管道
        MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
       
        //管道名称
        pipelineStateDescriptor.label = @"Texturing Pipeline";
        //可编程函数,用于处理渲染过程中的各个顶点
        pipelineStateDescriptor.vertexFunction = vertexFunction;
        //可编程函数,用于处理渲染过程总的各个片段/片元
        pipelineStateDescriptor.fragmentFunction = fragmentFunction;
        //设置管道中存储颜色数据的组件格式
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;
        
        //同步创建并返回渲染管线对象
        NSError *error = NULL;
        _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor
                                                                 error:&error];
        //判断是否创建成功
        if (!_pipelineState)
        {
            NSLog(@"Failed to created pipeline state, error %@", error);
        }
        
        //获取顶点数据
        _commandQueue = [_device newCommandQueue];
    }
    return self;
}

//每当视图改变方向或调整大小时调用
-(void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size
{
    // 保存可绘制的大小，因为当我们绘制时，我们将把这些值传递给顶点着色器
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
    
}

- (void)drawInMTKView:(MTKView *)view
{
    //为当前渲染的每个渲染传递创建一个新的命令缓冲区
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    
    //指定缓存区名称
    commandBuffer.label = @"MyCommand";
    
    //currentRenderPassDescriptor描述符包含currentDrawable's的纹理、视图的深度、模板和sample缓冲区和清晰的值。
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    
    if(renderPassDescriptor != nil)
    {
        //创建渲染命令编码器,这样我们才可以渲染到something
        id<MTLRenderCommandEncoder> renderEncoder =
        [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        
        //渲染器名称
        renderEncoder.label = @"MyRenderEncoder";
        
        //设置我们绘制的可绘制区域
        /*
         typedef struct {
         double originX, originY, width, height, znear, zfar;
         } MTLViewport;
         */
        [renderEncoder setViewport:(MTLViewport){0.0, 0.0, _viewportSize.x, _viewportSize.y, -1.0, 1.0 }];
        
        [renderEncoder setRenderPipelineState:_pipelineState];
        
        //将数据加载到MTLBuffer --> 顶点函数
        [renderEncoder setVertexBuffer:_vertices
                                offset:0
                               atIndex:ImageVertexInputIndexVertices];
        //将数据加载到MTLBuffer --> 顶点函数
        [renderEncoder setVertexBytes:&_viewportSize
                               length:sizeof(_viewportSize)
                              atIndex:ImageVertexInputIndexViewportSize];
        
        //设置纹理对象
        [renderEncoder setFragmentTexture:_texture atIndex:ImageTextureIndexBaseColor];
       
        //绘制
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
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle
                          vertexStart:0
                          vertexCount:_numVertices];
        
        //表示已该编码器生成的命令都已完成,并且从NTLCommandBuffer中分离
        [renderEncoder endEncoding];
        
        //一旦框架缓冲区完成，使用当前可绘制的进度表
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    
    //最后,在这里完成渲染并将命令缓冲区推送到GPU
    [commandBuffer commit];
}
@end
