//
//  BlinnPhongModel.swift
//  MetalSim
//
//  Created by Gabriel Bernardo on 20/11/24.
//

import simd
import MetalKit

struct Light{
    var position: simd_float3
    var color: simd_float3
}


class BlinnPhongLightModel{
    var light: Light {
        didSet{
            let bufferPtr = lightBuffer.contents()
            memcpy(bufferPtr, &light, MemoryLayout<Light>.size)
        }
    }
    
    private let _lightBuffer: MTLBuffer
    var lightBuffer: MTLBuffer{
        get {
            return _lightBuffer
        }
    }
    
    init(with device: LithiumDevice, light: Light){
        
        self.light = light
        guard let buffer = device.raw.makeBuffer(bytes: &self.light, length: MemoryLayout<Light>.size, options: .storageModeShared) else {
            fatalError("Could not create buffer")
        }
        
        buffer.label = "Light Buffer"
        
        _lightBuffer = buffer
        
    }
    
    
    
    
}



