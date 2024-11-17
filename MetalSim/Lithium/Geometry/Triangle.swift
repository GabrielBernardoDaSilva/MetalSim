//
//  Triangle.swift
//  MetalSim
//
//  Created by Gabriel Bernardo on 16/11/24.
//

import MetalKit


public class Triangle: NSObject {
    let vertexBuffer: MTLBuffer
    let pipelineState: LithiumRenderPipelineState
    let shaderLibrary: LithiumShaderLib
    
    let vertices: [Vertex] = [
        Vertex(position: [0, 1], color: [0, 0, 1]),
        Vertex(position: [-1, -1], color: [1, 1, 1]),
        Vertex(position: [1, -1], color: [1, 0, 0])]
    
    init(with device: inout LithiumDevice) {
        guard let buffer = device.raw.makeBuffer(bytes: vertices, length: MemoryLayout<Vertex>.size * vertices.count, options: .storageModeShared) else { fatalError("Could not create vertex buffer")}
        
        self.vertexBuffer = buffer
        
        shaderLibrary = .init(with: &device, "Shader")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = shaderLibrary.raw.makeFunction(name: "vertex_main")
        pipelineStateDescriptor.fragmentFunction = shaderLibrary.raw.makeFunction(name: "fragment_main")
        pipelineStateDescriptor.vertexDescriptor = Vertex.vertexDescriptor()
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineState = .init(with: &device, from: pipelineStateDescriptor)
        
    }
    
}
