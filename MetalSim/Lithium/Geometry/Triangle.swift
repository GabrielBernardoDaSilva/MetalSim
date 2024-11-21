//
//  Triangle.swift
//  MetalSim
//
//  Created by Gabriel Bernardo on 16/11/24.
//

import MetalKit


public class Triangle: NSObject {
    private let _vertexBuffer: MTLBuffer
    private let _pipelineState: MTLRenderPipelineState
    private let _shaderLibrary: MTLLibrary
    
    private let _vertices: [Vertex] = [
        Vertex(position: [0, 1], color: [0, 0, 1]),
        Vertex(position: [-1, -1], color: [1, 1, 1]),
        Vertex(position: [1, -1], color: [1, 0, 0])]
    
    init(with device: LithiumDevice) {
        guard let buffer = device.raw.makeBuffer(bytes: _vertices, length: MemoryLayout<Vertex>.size * _vertices.count, options: .storageModeShared) else { fatalError("Could not create vertex buffer")}
        
        _vertexBuffer = buffer
        
        guard let lib = device.raw.makeDefaultLibrary() else { fatalError("Could not create shader library")}
        
        _shaderLibrary = lib
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = _shaderLibrary.makeFunction(name: "vertex_main")
        pipelineStateDescriptor.fragmentFunction = _shaderLibrary.makeFunction(name: "fragment_main")
        pipelineStateDescriptor.vertexDescriptor = Vertex.vertexDescriptor()
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        guard let pipelineState = try? device.raw.makeRenderPipelineState(descriptor: pipelineStateDescriptor) else { fatalError("Could not create render pipeline state")}
        
        _pipelineState = pipelineState
        
        
        
    }
    
}
