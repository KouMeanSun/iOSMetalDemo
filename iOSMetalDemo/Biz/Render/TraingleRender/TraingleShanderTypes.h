//
//  TraingleShanderTypes.h
//  iOSMetalDemo
//
//  Created by 高明阳 on 2021/3/8.
//

#ifndef TraingleShanderTypes_h
#define TraingleShanderTypes_h

// 缓存区索引值 共享与 shader 和 C 代码 为了确保Metal Shader缓存区索引能够匹配 Metal API Buffer 设置的集合调用
typedef enum TraingleVertexInputIndex{
    //顶点
    TraingleVertexInputIndexVertices = 0,
    //视图大小
    TraingleVertexInputIndexViewportSize = 1,
}TraingleVertexInputIndex;

//结构体 顶点、颜色
typedef struct {
    //像素空间位置，
    //像素中心点 （100，100）
    vector_float2 position;
    vector_float4 color;
}TraingleVertex;
#endif /* TraingleShanderTypes_h */
