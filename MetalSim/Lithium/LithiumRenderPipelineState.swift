//
//  LithiumRenderPipeline.swift
//  MetalSim
//
//  Created by Gabriel Bernardo on 16/11/24.
//

import MetalKit

struct LithiumRenderPipelineState {
    let raw: MTLRenderPipelineState
    
    init(with device: inout LithiumDevice, from descriptor: MTLRenderPipelineDescriptor){
        do {
            let raw = try device.raw.makeRenderPipelineState(descriptor: descriptor)
            self.raw = raw
        } catch let error{
            fatalError("Could not create render pipeline state: \(error)")
        }
    }
}
