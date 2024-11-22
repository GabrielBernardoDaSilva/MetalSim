//
//  LithiumRenderer.swift
//  MetalSim
//
//  Created by Gabriel Bernardo on 17/11/24.
//
import MetalKit

protocol LithiumRenderer: AnyObject {
    func render(in enconder: MTLRenderCommandEncoder)
}


protocol LithiumUpdateable: AnyObject {
    func update(with time: Float)
}



protocol LithiumScene: AnyObject {
    var renderable: [LithiumRenderer] { get }
    var updatable: [LithiumUpdateable] { get }
    
    init(with device: LithiumDevice, depthStencilState: MTLDepthStencilState)
    
    func update(with time: Float, commandBuffer: MTLCommandBuffer)
}



struct LithiumSceneManager{
    var scenes: [LithiumScene]
    
    init(_ scenes: LithiumScene...) {
        self.scenes = scenes
    }
    
    
    func run(enconder rendererEnconder: MTLRenderCommandEncoder, commandBuffer: MTLCommandBuffer, _ time: Float) {
        for scene in scenes {
            scene.update(with: time, commandBuffer: commandBuffer)
            
            scene.updatable.forEach {
                $0.update(with: time)
            }
            
            scene.renderable.forEach {
                $0.render(in: rendererEnconder)
            }
        }
    }
}
