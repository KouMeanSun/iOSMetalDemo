//
//  MutipleShaders.metal
//  iOSMetalDemo
//
//  Created by 高明阳 on 2021/3/9.
//

#include <metal_stdlib>
using namespace metal;
#import "MutilpleShaderTypes.h"

typedef struct {
    float4 clipSpacePosition [[position]];
    float4 color;
}RasterizerData;

vertex RasterizerData multipleGraphVertexShader(uint vertexID [[vertex_id]],
                                                constant MutilpleVertex *vertices [[buffer(MutilpleVertexInputIndexVertices)]],
                                                constant vector_uint2 *viewportSizePointer [[buffer(MutilpleVertexInputIndexViewportSize)]]){
    RasterizerData out;
    out.clipSpacePosition = vector_float4(0.0,0.0,0.0,1.0);
    float2 pixelSpacePosition = vertices[vertexID].position.xy;
    vector_float2 viewportSize = vector_float2(*viewportSizePointer);
    out.clipSpacePosition.xy = pixelSpacePosition / (viewportSize/2.0);
    out.color = vertices[vertexID].color;
    return out;
}

fragment float4 multipleGraphfragmentShader(RasterizerData in [[stage_in]]){
    return in.color;
}
