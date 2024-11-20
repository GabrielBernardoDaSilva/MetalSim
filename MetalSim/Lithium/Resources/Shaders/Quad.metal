#include <metal_stdlib>
#include <metal_matrix>
#include <metal_math>

using namespace metal;

struct Vertex {
    float2 position [[attribute(0)]];
    float2 texCoord [[attribute(1)]];
};

struct FragmentInput {
    float4 position [[position]];
    float2 texCoord;
};

vertex FragmentInput vertex_quad_main(
                                      Vertex v [[stage_in]],
                                      constant float4x4 &proj [[buffer(1)]],
                                      constant float4x4 &model [[buffer(2)]],
                                      constant  float4x4 &view [[buffer(3)]]) {
    
    return {
        .position {proj * view * model * float4(v.position, 0.0, 1.0) },
        .texCoord { v.texCoord }
    };
}

fragment float4 fragment_quad_main(FragmentInput in [[stage_in]], texture2d<float> tex [[texture(0)]], sampler samp [[sampler(0)]]) {
    
    float4 color = tex.sample(samp, in.texCoord);
    return float4(color.rgb, 1.0);
}

