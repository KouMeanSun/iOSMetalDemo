//
//  ImageFilterShaderTypes.h
//  iOSMetalDemo
//
//  Created by 高明阳 on 2021/3/9.
//

#ifndef ImageFilterShaderTypes_h
#define ImageFilterShaderTypes_h
#include <simd/simd.h>

typedef enum ImageFilterVertexInputIndex{
    ImageFilterVertexInputIndexVertices = 0,
    ImageFilterVertexInputIndexViewportSize = 1,
}ImageFilterVertexInputIndex;


typedef enum ImageFilterTextureIndex{
    ImageFilterTextureIndexInput = 0,
    ImageFilterTextureIndexOutput = 1,
}ImageFilterTextureIndex;

typedef struct {
    vector_float2 position;
    vector_float2 textureCoordinate;
}ImageFilterVertex;
#endif /* ImageFilterShaderTypes_h */
