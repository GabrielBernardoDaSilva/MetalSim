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
    float3 worldPosition;
};

struct Light {
    float3 position;
    float3 color;
};

struct BlinnPhongBaseMaterial {
    float3 diffuseColor;
    float3 specularColor;
    float shininess;
};




struct Uniform{
    float time;
};

struct MVP{
    float4x4 model;
    float4x4 view;
    float4x4 projection;
};

struct Camera{
    float3 cameraPos;
    float4x4 view;
    float4x4 projection;
};

vertex FragmentInput vertex_mesh_main(Vertex v [[stage_in]], constant MVP &mvp [[buffer(1)]]) {
                                          
    float4 worldPosition = float4(v.position, 1.0);
    float3 normal = v.normal;
    
    
    return {
        .position { mvp.projection * mvp.view * mvp.model * float4(v.position, 1.0) },
        .normal { normal },
        .worldPosition { worldPosition.xyz }
    };
}

fragment float4 fragment_mesh_main(FragmentInput in [[stage_in]],
                                   constant Uniform& uniform [[buffer(0)]],
                                   constant Light& light [[buffer(1)]],
                                   constant BlinnPhongBaseMaterial& material [[buffer(2)]],
                                   constant Camera& camera [[buffer(3)]],
                                   constant MVP& shadowMvp [[buffer(4)]],
                                   texture2d<float> shadowMap [[texture(0)]]) {
    
    constexpr sampler colorSampler(mip_filter::linear, mag_filter::linear, min_filter::linear, address::repeat);

    
    constexpr float3 cameraPosition = float3(0, 0, -8);
    
    float3 lightPosition = light.position;
    float3 ambientColor = float3(0.01) * light.color ;
   
    float3 specularColor = material.specularColor;
    float shineness = material.shininess;
    
    float3 diffuseColor = material.diffuseColor;
    
    const float dotX = dot(in.normal, float3(1.0, 0.0, 0.0));
    
    if (dotX > 0.99)
        diffuseColor = float3(1.0, 0.0, 0.0);
    else if ( dotX < -0.99)
        diffuseColor = float3(0.0, 1.0, 0.0);
    

    
    float3 ambient = ambientColor * diffuseColor;
    float3 normal = normalize(in.normal);
    
    float3 lightDir = normalize(lightPosition - in.worldPosition);
    
    float diff = max(dot(lightDir, normal), 0.0);
    float3 diffuse = diff * diffuseColor;
    
    float3 viewDir = normalize(cameraPosition - in.worldPosition);
     
    float3 halfwayDir = normalize(lightDir + viewDir);
    float spec = pow(max(dot(viewDir, halfwayDir), 0.0), shineness);
    
    float3 specular = specularColor  * spec;
    
    
    
    float4 positionInLightSpace = shadowMvp.projection * shadowMvp.view * float4(in.worldPosition, 1.0);
    positionInLightSpace.xyz /= positionInLightSpace.w;
    float2 lightSpaceCoord = positionInLightSpace.xy * 0.5 + 0.5;
    lightSpaceCoord.y = 1.0 - lightSpaceCoord.y;
    float lightDepth = shadowMap.sample(colorSampler, lightSpaceCoord).x;
    float visibility = 1.0;
    if (positionInLightSpace.z > lightDepth)
        visibility = 0.0;
    
    float3 color = ambient + (diffuse + specular) * visibility;
    
    return float4(color, 1.0);
}




vertex float4 shadowVertexFunction(Vertex in [[stage_in]], constant MVP &mvp [[buffer(1)]]){
    return mvp.projection * mvp.view * mvp.model * float4(in.position, 1.0);
}


fragment void shadowFragmentFunction(){}
