#include <metal_stdlib>
#include <metal_matrix>
#include <metal_math>

using namespace metal;

struct Vertex {
    float3 position [[attribute(0)]];
    float3 normal   [[attribute(1)]];
};

struct FragmentInput {
    float4 position [[position]];
    float3 normal;
};

struct Uniform{
    float time;
};

struct MVP{
    float4x4 model;
    float4x4 view;
    float4x4 projection;
};

vertex FragmentInput vertex_light_main(
                                      Vertex v [[stage_in]],
                                      constant MVP &mvp [[buffer(1)]]) {
    
    return {
        .position {mvp.projection * mvp.view * mvp.model * float4(v.position, 1.0) },
        .normal { v.normal }
    };
}

fragment float4 fragment_light_main(FragmentInput in [[stage_in]], constant Uniform& uniform [[buffer(0)]]) {
    
    float x = 1.0;
    float y = 1.0;
    float z = 1.0;
    
    return float4(x, y, z, 1.0);
}


