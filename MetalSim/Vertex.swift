//
//  Vertex.swift
//  MetalSim
//
//  Created by Gabriel Bernardo on 13/11/24.
//

import MetalKit

struct Vertex {
    let position: SIMD2<Float>
    let color: SIMD3<Float>
    
    
    static func vertexDescriptor() -> MTLVertexDescriptor {
        let descriptor = MTLVertexDescriptor()
        descriptor.attributes[0].format = .float2
        descriptor.attributes[0].offset = 0
        descriptor.attributes[0].bufferIndex = 0
        
        descriptor.attributes[1].format = .float3
        descriptor.attributes[1].bufferIndex = 0
        descriptor.attributes[1].offset = MemoryLayout<Vertex>.offset(of: \.color)!
        
        descriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        
        
        return descriptor
        
    }
    
    
    
}


