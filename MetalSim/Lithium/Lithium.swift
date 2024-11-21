//
//  MetalRenderer.swift
//  metal-04-swiftui
//
//  Created by Luke on 2024-01-27.
//

import simd
import MetalKit

class Lithium: NSObject, MTKViewDelegate {
    
    
    
    let lithiumDevice: LithiumDevice
    let commandQueue: MTLCommandQueue
    
    private let _depthState: MTLDepthStencilState
    private var _offscreenRenderTarget: MTLTexture?
    private var _quad: Quad?
    private var _renderPassDescriptor: MTLRenderPassDescriptor?
    
    
    var quad: Quad? {
        get {
            _quad
        }
    }
    
    
    let sceneManager: LithiumSceneManager
    
    
    
    
    var time: Float = 0.0
    
 
    
    override init() {
        lithiumDevice = .init(
            .bgra8Unorm,
            .depth32Float
        )
        
        
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .lessEqual
        depthStencilDescriptor.isDepthWriteEnabled = true
        
        
        guard let depthState = lithiumDevice.raw.makeDepthStencilState(descriptor: depthStencilDescriptor) else{
            fatalError("Could not set up depth state")
        }
        
        _depthState = depthState
        
        guard let commandQueue = lithiumDevice.raw.makeCommandQueue() else{
            fatalError("Could not set up command queue")
        }
        self.commandQueue = commandQueue
        
        
    
        sceneManager = .init(  CornellBoxScene(with: lithiumDevice))
        _offscreenRenderTarget = nil
        _quad = nil
        _renderPassDescriptor = nil
        
     
        super.init()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        view.colorPixelFormat = .bgra8Unorm
        view.clearColor = MTLClearColor(red: 0.0, green: 0.0,blue: 0.0,alpha: 1.0)
        view.clearDepth = 1.0
        view.depthStencilPixelFormat = .depth32Float
        
        // create texture
        
        print("drawable size: \(view.drawableSize)")
        
        var size = (1024, 1024)
        if !view.drawableSize.equalTo(CGSize(width: 0, height: 0)){
            size = (Int(view.drawableSize.width), Int(view.drawableSize.height))
        }
        

        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: view.colorPixelFormat, width: size.0 , height: size.1, mipmapped: false)
        textureDescriptor.usage = [.renderTarget, .shaderRead]
        
        guard let texture = lithiumDevice.raw.makeTexture(descriptor: textureDescriptor) else {
            fatalError("Could not set up texture")
        }
        
        _offscreenRenderTarget = texture
        _quad = Quad(with: lithiumDevice, texture: texture)
        _renderPassDescriptor = MTLRenderPassDescriptor()
        
        _renderPassDescriptor?.colorAttachments[0].texture = texture
        _renderPassDescriptor?.colorAttachments[0].loadAction = .clear
        _renderPassDescriptor?.colorAttachments[0].clearColor = view.clearColor
        _renderPassDescriptor?.colorAttachments[0].storeAction = .store
        
        
      
        let depthTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float, width: size.0 , height: size.1, mipmapped: false)
        depthTextureDescriptor.usage = [.renderTarget]
        guard let depthTexture = lithiumDevice.raw.makeTexture(descriptor: depthTextureDescriptor) else {
            fatalError("Could not set up depth texture")
        }
    
        
        _renderPassDescriptor?.depthAttachment = MTLRenderPassDepthAttachmentDescriptor()
        _renderPassDescriptor?.depthAttachment?.loadAction = .clear
        _renderPassDescriptor?.depthAttachment?.clearDepth = view.clearDepth
        _renderPassDescriptor?.depthAttachment?.clearDepth = 1.0
        _renderPassDescriptor?.depthAttachment?.storeAction = .dontCare
        _renderPassDescriptor?.depthAttachment?.texture = depthTexture
        
        
        
        
    
    }
    
    func draw(in view: MTKView) {
        
        // render scene
        {
            guard let commandBuffer = commandQueue.makeCommandBuffer(),
                  let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: _renderPassDescriptor!) else {
                fatalError("Could not set up objects for render encoding")
            }
            
            time += 0.01
            
            renderEncoder.setDepthStencilState(_depthState)
            
            sceneManager.run(enconder: renderEncoder, time)
            
            renderEncoder.endEncoding()
            commandBuffer.commit()
        }()
        
        
        
        // render quad
        if let drawable = view.currentDrawable,
           let renderPassDescriptor = view.currentRenderPassDescriptor {
            guard let commandBuffer = commandQueue.makeCommandBuffer(),
                  let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
                fatalError("Could not set up objects for render encoding")
            }
            
            _quad!.render(in: renderEncoder)
            
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


