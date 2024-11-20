//
//  PerspectiveCamera.swift
//  MetalSim
//
//  Created by Gabriel Bernardo on 20/11/24.
//

import simd
import MetalKit

struct Camera{
    let perspectiveCamera: float4x4
    var cameraPosition: simd_float3
    var view: float4x4
}



class PerspectiveCamera{
    var camera: Camera {
        didSet {
            let bufferPtr = _cameraBuffer.contents()
            memcpy(bufferPtr, &camera, MemoryLayout<Camera>.size)
        }
    }
    
    
    private let _cameraBuffer : MTLBuffer
    var cameraBuffer: MTLBuffer {
        get{
            _cameraBuffer
        }
    }
    
    
    init(with device: LithiumDevice, camera: Camera) {
        self.camera = camera
        guard let buffer = device.raw.makeBuffer(bytes: &self.camera, length: MemoryLayout<Camera>.size, options: .cpuCacheModeWriteCombined) else {
            fatalError("Could not create camera buffer")
        }
        
        _cameraBuffer = buffer
    }
    
    
}
