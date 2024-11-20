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

class Quad: LithiumRenderer, LithiumUpdateable{

    
    let vertexBuffer: MTLBuffer
    let indexBuffer: MTLBuffer
    let texture: MTLTexture
    let sampler: MTLSamplerState
    let pipelineState: MTLRenderPipelineState
    let shaderLib: MTLLibrary
    
    var perspectiveCamera: matrix_float4x4
    var model: matrix_float4x4
    var view: matrix_float4x4
    
    func createPerspectiveMatrix(fov: Float, aspectRatio: Float, nearPlane: Float, farPlane: Float) -> simd_float4x4 {
        let tanHalfFov = tan(fov / 2.0);

        var matrix = simd_float4x4(0.0);
        matrix[0][0] = 1.0 / (aspectRatio * tanHalfFov);
        matrix[1][1] = 1.0 / (tanHalfFov);
        matrix[2][2] = farPlane / (farPlane - nearPlane);
        matrix[2][3] = 1.0;
        matrix[3][2] = -(farPlane * nearPlane) / (farPlane - nearPlane);
        
        return matrix;
    }
    
    init(with device: LithiumDevice){
        // read image
        let loader = MTKTextureLoader(device: device.raw)
        
        do{
            guard let url = Bundle.main.url(forResource: "AppleMetal", withExtension: "png") else{
                fatalError("Couldn't find image")
            }
            texture = try loader.newTexture(URL: url, options: nil)
        }catch let error{
            fatalError("Couldn't load image: \(error)")
        }
        
        
        let vertices = [
            QuadVertex(position: simd_float2(-0.5, -0.5), texCoords: simd_float2(0.0, 1.0)),
            QuadVertex(position: simd_float2(0.5, -0.5), texCoords: simd_float2(1.0, 1.0)),
            QuadVertex(position: simd_float2(0.5, 0.5), texCoords: simd_float2(1.0, 0.0)),
            QuadVertex(position: simd_float2(-0.5, 0.5), texCoords: simd_float2(0.0, 0.0))
        ]
        
        if let vertexBuffer = device.raw.makeBuffer(bytes: vertices, length: MemoryLayout<QuadVertex>.size * vertices.count, options:  .cpuCacheModeWriteCombined){
            
            self.vertexBuffer = vertexBuffer
        }else {
            fatalError("Couldn't create vertex buffer")
        }
        
        let indices: [ushort] = [
            0, 1, 2,
            0, 2, 3
        ]
        
        
        if let indexBuffer = device.raw.makeBuffer(bytes: indices, length: MemoryLayout<ushort>.size * indices.count, options:  .cpuCacheModeWriteCombined){
            
            self.indexBuffer = indexBuffer
        }else {
            fatalError("Couldn't create index buffer")
        }
        
        
        guard let lib = device.raw.makeDefaultLibrary() else {
            fatalError("Couldn't load default library")
        }
        
        shaderLib = lib
            
        
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = shaderLib.makeFunction(name: "vertex_quad_main")
        pipelineDescriptor.fragmentFunction = shaderLib.makeFunction(name: "fragment_quad_main")
        pipelineDescriptor.vertexDescriptor = QuadVertex.vertexDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        
        guard let pipelineState = try? device.raw.makeRenderPipelineState(descriptor: pipelineDescriptor) else {
            fatalError("Couldn't create pipeline state")
        }
        
        self.pipelineState = pipelineState
        
        let sampler = MTLSamplerDescriptor()
        sampler.magFilter = .linear
        sampler.minFilter = .linear
        sampler.mipFilter = .linear
        
        
        
        guard let texSampler = device.raw.makeSamplerState(descriptor: sampler) else {
            fatalError("Couldn't create sampler")
        }
        
        self.sampler = texSampler
        
        perspectiveCamera = float4x4(perspectiveWithAspect: 1.0, fovy: .π/5, near: 0.1, far: 100.0)
        
        
        var model = matrix_identity_float4x4
        
        model = model.scale([0.5, 0.5, 1.0])
        model = model.translation([0.0, 0.0, -5.0])
        self.model = model
        
        view = float4x4(translate: [0, 0, -8])
    }
    
    func render(in enconder: MTLRenderCommandEncoder) {
        enconder.setRenderPipelineState(pipelineState)
        enconder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        enconder.setVertexBytes(&perspectiveCamera, length: MemoryLayout<simd_float4x4>.stride, index: 1)
        enconder.setVertexBytes(&model, length: MemoryLayout<simd_float4x4>.stride, index: 2)
        enconder.setVertexBytes(&view, length: MemoryLayout<simd_float4x4>.stride, index: 3)
        enconder.setFragmentTexture(texture, index: 0)
        enconder.setFragmentSamplerState(sampler, index: 0)
        enconder.drawIndexedPrimitives(type: .triangle, indexCount: 6, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
    }
    
    func update(with time: Float) {
        let quat = simd_quatf(angle: time * 0.01, axis: [0, 1, 0])
        
        self.model *= simd_float4x4(quat)
        
    }
}
