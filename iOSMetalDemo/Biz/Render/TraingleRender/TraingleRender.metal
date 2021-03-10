//
//  TraingleRender.metal
//  iOSMetalDemo
//
//  Created by 高明阳 on 2021/3/8.
//

#include <metal_stdlib>
using namespace metal;
// 导入Metal shader 代码和执行Metal API命令的C代码之间共享的头
#import "TraingleShanderTypes.h"

//顶点着色器和片元着色器输入,结构体
typedef struct {
  //处理空间的顶点信息
    float4 clipSpacePosition [[position]];
    //颜色
    float4 color;
}RasterizerData;

//顶点着色函数
vertex RasterizerData traingleVertexShader(uint vertexID [[vertex_id]],
                                           constant TraingleVertex *vertices [[buffer(TraingleVertexInputIndexVertices)]],
                                           constant vector_int2 *viewportSizePointer [[buffer(TraingleVertexInputIndexViewportSize)]]){
    /*
         处理顶点数据:
            1) 执行坐标系转换,将生成的顶点剪辑空间写入到返回值中.
            2) 将顶点颜色值传递给返回值
         */
    //定义out
    RasterizerData out;
    //初始化输出剪辑空间位置
    out.clipSpacePosition = vector_float4(0.0,0.0,0.0,1.0);
    //索引到我们的数组位置以获得当前顶点
    //我们的位置实在像素维度中指定的
    float2 pixelSpacePosition = vertices[vertexID].position.xy;
    //将viewoprtSizePointer 从verctor_unit2 转换为 vector_float2类型
    vector_float2 viewportSize = vector_float2(*viewportSizePointer);
    //每个顶点着色器的输出位置在剪辑空间中（也称归一化坐标NDC，）
    /**
     剪辑空间中的(-1,-1)表示视口的左下角,而(1,1)表示视口的右上角.
     */
    //计算和写入 XY值到我们的剪辑空间位置，从像素空间的位置转换到剪辑空间的位置，我们将像素坐标除以
    //视窗大小的一半
    out.clipSpacePosition.xy = pixelSpacePosition / (viewportSize / 2.0);
    //把我们输入的颜色直接赋值给输入的颜色
    out.color =  vertices[vertexID].color;
    //完成，将结构体传递到管道的下一个阶段
    return out;
}

// 片元函数
//[[stage_in]],片元着色函数使用的单个片元输入数据是由顶点着色函数输出.然后经过光栅化生成的.单个片元输入函数数据可以使用"[[stage_in]]"属性修饰符.
//一个顶点着色函数可以读取单个顶点的输入数据,这些输入数据存储于参数传递的缓存中,使用顶点和实例ID在这些缓存中寻址.读取到单个顶点的数据.另外,单个顶点输入数据也可以通过使用"[[stage_in]]"属性修饰符的产生传递给顶点着色函数.
//被stage_in 修饰的结构体的成员不能是如下这些.Packed vectors 紧密填充类型向量,matrices 矩阵,structs 结构体,references or pointers to type 某类型的引用或指针. arrays,vectors,matrices 标量,向量,矩阵数组.

fragment float4 traingleFragmentShader(RasterizerData in [[stage_in]]){
    //返回输入的片元颜色
    return in.color;
}
