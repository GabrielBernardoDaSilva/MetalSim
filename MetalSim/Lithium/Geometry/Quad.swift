//
//  Quad.swift
//  MetalSim
//
//  Created by Gabriel Bernardo on 17/11/24.
//
import SwiftUI
import MetalKit
import simd

struct QuadVertex{
    var position: simd_float2
    var texCoords : simd_float2
    
    static func vertexDescriptor() -> MTLVertexDescriptor {
        let descriptor = MTLVertexDescriptor()
        descriptor.attributes[0].format = .float2
        descriptor.attributes[0].offset = 0
        descriptor.attributes[0].bufferIndex = 0
        
        descriptor.attributes[1].format = .float2
        descriptor.attributes[1].bufferIndex = 0
        descriptor.attributes[1].offset = MemoryLayout<QuadVertex>.offset(of: \.texCoords)!
        
        descriptor.layouts[0].stride = MemoryLayout<QuadVertex>.stride
        
        
        return descriptor
        
    }
}

class Quad: LithiumRenderer{

    
    private let _vertexBuffer: MTLBuffer
    private let _indexBuffer: MTLBuffer
    private var _contrast: Float = 0.5

    private let _sampler: MTLSamplerState
    private let _pipelineState: MTLRenderPipelineState
    private let _shaderLib: MTLLibrary
    
    
    private let _texture: MTLTexture

    
    init(with device: LithiumDevice, texture: MTLTexture){
        
        _texture = texture
        
        let vertices = [
            QuadVertex(position: simd_float2(-1.0, -1.0), texCoords: simd_float2(0.0, 1.0)),
            QuadVertex(position: simd_float2(1.0, -1.0), texCoords: simd_float2(1.0, 1.0)),
            QuadVertex(position: simd_float2(1.0, 1.0), texCoords: simd_float2(1.0, 0.0)),
            QuadVertex(position: simd_float2(-1.0, 1.0), texCoords: simd_float2(0.0, 0.0))
        ]
        
        guard let vertexBuffer = device.raw.makeBuffer(bytes: vertices, length: MemoryLayout<QuadVertex>.size * vertices.count, options:  .cpuCacheModeWriteCombined) else{
            fatalError("Couldn't create vertex buffer")
        }
        
        _vertexBuffer = vertexBuffer
        let indices: [ushort] = [
            0, 1, 2,
            0, 2, 3
        ]
        
        
        guard let indexBuffer = device.raw.makeBuffer(bytes: indices, length: MemoryLayout<ushort>.size * indices.count, options:  .cpuCacheModeWriteCombined) else {
            fatalError("Couldn't create index buffer")
        }
        
        _indexBuffer = indexBuffer
        
        
        guard let lib = device.raw.makeDefaultLibrary() else {
            fatalError("Couldn't load default library")
        }
        
        _shaderLib = lib
            
        
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = _shaderLib.makeFunction(name: "vertex_quad_main")
        pipelineDescriptor.fragmentFunction = _shaderLib.makeFunction(name: "fragment_quad_main")
        pipelineDescriptor.vertexDescriptor = QuadVertex.vertexDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        
        guard let pipelineState = try? device.raw.makeRenderPipelineState(descriptor: pipelineDescriptor) else {
            fatalError("Couldn't create pipeline state")
        }
        
        _pipelineState = pipelineState
        
        let sampler = MTLSamplerDescriptor()
        sampler.magFilter = .linear
        sampler.minFilter = .linear
        sampler.mipFilter = .linear
        
        
        
        guard let texSampler = device.raw.makeSamplerState(descriptor: sampler) else {
            fatalError("Couldn't create sampler")
        }
        
        _sampler = texSampler
        
        

    
    }
    
    func render(in enconder: MTLRenderCommandEncoder) {
        enconder.setRenderPipelineState(_pipelineState)
        enconder.setVertexBuffer(_vertexBuffer, offset: 0, index: 0)
        enconder.setFragmentBytes(&_contrast, length: MemoryLayout<Float>.size, index: 0)
        enconder.setFragmentTexture(_texture, index: 0)
        enconder.setFragmentSamplerState(_sampler, index: 0)
        enconder.drawIndexedPrimitives(type: .triangle, indexCount: 6, indexType: .uint16, indexBuffer: _indexBuffer, indexBufferOffset: 0)
    }
    
    func setContrast(contrast: Float){
        print("Updated contrast to \(contrast)")
        _contrast = contrast
    }
}
