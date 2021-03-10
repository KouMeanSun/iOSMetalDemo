//
//  MutilpleShaderTypes.h
//  iOSMetalDemo
//
//  Created by 高明阳 on 2021/3/9.
//

#ifndef MutilpleShaderTypes_h
#define MutilpleShaderTypes_h

typedef enum MutilpleVertexInputIndex{
    MutilpleVertexInputIndexVertices = 0,
    MutilpleVertexInputIndexViewportSize = 1,
}MutilpleVertexInputIndex;

typedef struct {
    vector_float2 position;
    vector_float4 color;
}MutilpleVertex;
#endif /* MutilpleShaderTypes_h */
