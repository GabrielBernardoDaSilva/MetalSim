//
//  MetalRenderer.swift
//  metal-04-swiftui
//
//  Created by Luke on 2024-01-27.
//

import simd
import MetalKit

class Lithium: NSObject, MTKViewDelegate {
    
    let vertexBuffer: MTLBuffer
    let pipelineState: MTLRenderPipelineState
    let commandQueue: MTLCommandQueue
    let device: MTLDevice
    
    var time: Float = 0.0
    
    let vertices: [Vertex] = [
        Vertex(position: [0, 1], color: [0, 0, 1]),
        Vertex(position: [-1, -1], color: [1, 1, 1]),
        Vertex(position: [1, -1], color: [1, 0, 0])]
    
    override init() {
        device = Self.createMetalDevice()
        commandQueue = Self.createCommandQueue(with: device)
        vertexBuffer = Self.createVertexBuffer(for: device, containing: vertices)
        
        let descriptor = Vertex.vertexDescriptor()
        let library = Self.createDefaultMetalLibrary(with: device)
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertex_main")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragment_main")
        pipelineDescriptor.vertexDescriptor = descriptor
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        
        pipelineState = Self.createPipelineState(with: device, from: pipelineDescriptor)
        
        super.init()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    
    func draw(in view: MTKView) {
        if let drawable = view.currentDrawable,
           let renderPassDescriptor = view.currentRenderPassDescriptor {
            
            guard let commandBuffer = commandQueue.makeCommandBuffer(),
                  let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
                fatalError("Could not set up objects for render encoding")
            }
        
            
            var model = matrix_float4x4(diagonal: [1, 1, 1, 1])
            
            model = model.translation([0.0, 0.0, 0.0])
            model = model.scale([0.1, 0.1, 0.0])
            
            time += 0.001
            
            let q = simd_quatf(angle: .pi * time, axis: [1, 0, 0])
            
            model = model * simd_float4x4( q)
            
            
            
            
            
            // transform
            renderEncoder.setRenderPipelineState(pipelineState)
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            renderEncoder.setVertexBytes(&model, length: MemoryLayout<simd_float4x4>.stride, index: 1)
            renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
            
            renderEncoder.endEncoding()
            
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
    
    private static func createMetalDevice() -> MTLDevice {
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("No GPU?")
        }
        
        return defaultDevice
    }
    
    private static func createCommandQueue(with device: MTLDevice) -> MTLCommandQueue {
        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("Could not create the command queue")
        }
        
        return commandQueue
    }
    
    private static func createVertexBuffer(for device: MTLDevice, containing data: [Vertex]) -> MTLBuffer {
        guard let buffer = device.makeBuffer(bytes: data,
                                             length: MemoryLayout<Vertex>.stride * data.count,
                                             options: []) else {
            fatalError("Could not create the vertex buffer")
        }
        
        return buffer
    }
    
    private static func createDefaultMetalLibrary(with device: MTLDevice) -> MTLLibrary {
        guard let library = device.makeDefaultLibrary() else {
            fatalError("No .metal files in the Xcode project")
        }
        
        return library
    }
    
    private static func createPipelineState(with device: MTLDevice, from descriptor: MTLRenderPipelineDescriptor) -> MTLRenderPipelineState {
        do {
            return try device.makeRenderPipelineState(descriptor: descriptor)
        } catch let error {
            fatalError("Could not create the pipeline state: \(error.localizedDescription)")
        }
    }
    
    private static func createUniformBuffer(with device: MTLDevice, contains model: [matrix_float4x4]) -> MTLBuffer {
        guard let  uniformBuffer = device.makeBuffer(bytes: model,
                                                     length: MemoryLayout<matrix_float4x4>.size,
                                                     options: []) else {
            fatalError("Could not create the uniform buffer")
        }
        
        return uniformBuffer
    }
    
}


