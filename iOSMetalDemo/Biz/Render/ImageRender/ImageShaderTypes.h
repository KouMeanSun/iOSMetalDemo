//
//  ImageShaderTypes.h
//  iOSMetalDemo
//
//  Created by 高明阳 on 2021/3/9.
//

#ifndef ImageShaderTypes_h
#define ImageShaderTypes_h
#include <simd/simd.h>

typedef enum ImageVertexInputIndex {
    ImageVertexInputIndexVertices = 0,
    ImageVertexInputIndexViewportSize = 1,
}ImageVertexInputIndex;

typedef enum ImageTextureIndex{
    ImageTextureIndexBaseColor = 0
}ImageTextureIndex;

typedef struct {
    vector_float2 position;
    vector_float2 textureCoordinate;
}ImageVertex;
#endif /* ImageShaderTypes_h */
