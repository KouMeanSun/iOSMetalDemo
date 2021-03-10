//
//  MultipleGraphRender.m
//  iOSMetalDemo
//
//  Created by 高明阳 on 2021/3/9.
//

#import "MultipleGraphRender.h"
#import "MutilpleShaderTypes.h"

@import MetalKit;
@implementation MultipleGraphRender
{
    id<MTLDevice>               _device;
    id<MTLRenderPipelineState>  _pipelineState;
    id<MTLCommandQueue>         _commandQueue;
    id<MTLBuffer>               _vertexBuffer;
    vector_uint2                _viewportSize;
    NSInteger                   _numVertices;
}

- (instancetype)initWithMetalKitView:(MTKView *)mtkView{
    self = [super init];
    if (self) {
        _device = mtkView.device;
        [self loadMetal:mtkView];
    }
    return self;
}

-(void)loadMetal:(MTKView *)mtkView{
    mtkView.colorPixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
    id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
    id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"multipleGraphVertexShader"];
    id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"multipleGraphfragmentShader"];
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    
    pipelineStateDescriptor.label = @"Mutilple Graph Pipeline";
    pipelineStateDescriptor.vertexFunction = vertexFunction;
    pipelineStateDescriptor.fragmentFunction = fragmentFunction;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;
    
    NSError *error = NULL;
    _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&error];
    if (_pipelineState == nil) {
        NSLog(@"Failed to created pipeline state, error %@", error);
    }
    NSData *vertexData = [MultipleGraphRender generateVertexData];
    _vertexBuffer = [_device newBufferWithLength:vertexData.length options:MTLResourceStorageModeShared];
    /*
         memcpy(void *dst, const void *src, size_t n);
         dst:目的地
         src:源内容
         n: 长度
         */
    memcpy(_vertexBuffer.contents, vertexData.bytes, vertexData.length);
    _numVertices = vertexData.length / sizeof(MutilpleVertex);
    _commandQueue = [_device newCommandQueue];
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{
    // 保存可绘制的大小，因为当我们绘制时，我们将把这些值传递给顶点着色器
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
}

- (void)drawInMTKView:(MTKView *)view{
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"Multiple Graph CommandBuffer";
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    if(renderPassDescriptor != nil  ){
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderEncoder.label = @"Multiple Graph renderEncoder";
        [renderEncoder setViewport:(MTLViewport){0.0, 0.0, _viewportSize.x, _viewportSize.y, -1.0, 1.0}];
        [renderEncoder setRenderPipelineState:_pipelineState];
        [renderEncoder setVertexBuffer:_vertexBuffer offset:0 atIndex:MutilpleVertexInputIndexVertices];
        [renderEncoder setVertexBytes:&_viewportSize
                                       length:sizeof(_viewportSize)
                                      atIndex:MutilpleVertexInputIndexViewportSize];
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle
                                  vertexStart:0
                                  vertexCount:_numVertices];
                
                //表示已该编码器生成的命令都已完成,并且从NTLCommandBuffer中分离
                [renderEncoder endEncoding];
                
                //一旦框架缓冲区完成，使用当前可绘制的进度表
                [commandBuffer presentDrawable:view.currentDrawable];
    }
    [commandBuffer commit];
}

+(NSData *)generateVertexData{
    const MutilpleVertex quadVertices[] = {
        // Pixel 位置, RGBA 颜色
                { { -20,   20 },    { 1, 0, 0, 1 } },
                { {  20,   20 },    { 1, 0, 0, 1 } },
                { { -20,  -20 },    { 1, 0, 0, 1 } },
                
                { {  20,  -20 },    { 0, 0, 1, 1 } },
                { { -20,  -20 },    { 0, 0, 1, 1 } },
                { {  20,   20 },    { 0, 0, 1, 1 } },
    };
    const NSUInteger NUM_COLUMNS = 25;
    const NSUInteger NUM_ROWS    = 15;
    const NSUInteger NUM_VERTICES_PER_QUAD = sizeof(quadVertices)/sizeof(MutilpleVertex);
    const float QUAD_SPACING = 50;
    NSUInteger dataSize = sizeof(quadVertices)*NUM_COLUMNS*NUM_ROWS;
    NSMutableData *vertexData = [[NSMutableData alloc] initWithLength:dataSize];
    MutilpleVertex *currentQuad = vertexData.mutableBytes;
    for (NSUInteger row =0; row < NUM_ROWS; row++) {
        for(NSUInteger column = 0;column<NUM_COLUMNS;column++){
            //左上角的位置
                      vector_float2 upperLeftPosition;
                      
                      //计算X,Y 位置.注意坐标系基于2D笛卡尔坐标系,中心点(0,0),所以会出现负数位置
                      upperLeftPosition.x = ((-((float)NUM_COLUMNS) / 2.0) + column) * QUAD_SPACING + QUAD_SPACING/2.0;
                      
                      upperLeftPosition.y = ((-((float)NUM_ROWS) / 2.0) + row) * QUAD_SPACING + QUAD_SPACING/2.0;
                      
                      //将quadVertices数据复制到currentQuad
                      memcpy(currentQuad, &quadVertices, sizeof(quadVertices));
                      
                      //遍历vertexInQuad中的数据
                      for (NSUInteger vertexInQuad = 0; vertexInQuad < NUM_VERTICES_PER_QUAD; vertexInQuad++)
                      {
                          //修改vertexInQuad中的position
                          currentQuad[vertexInQuad].position += upperLeftPosition;
                      }
                      
                      //更新索引
                      currentQuad += 6;
        }
    }
    return vertexData;
}
@end
