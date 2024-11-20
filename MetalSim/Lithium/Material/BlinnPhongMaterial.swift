//
//  BlinnPhongMaterial.swift
//  MetalSim
//
//  Created by Gabriel Bernardo on 20/11/24.
//

import MetalKit
import simd

struct BlinnPhongBaseMaterial {
    var diffuseColor: simd_float3
    var specularColor: simd_float3
    var shininess: Float
    private let _padding: simd_float2 = simd_float2(0, 0)
}



class BlinnPhongMaterial {
    var baseMaterial: BlinnPhongBaseMaterial{
        didSet{
            let bufferPtr = _bufferMaterial.contents()
            memcpy(bufferPtr, &baseMaterial, MemoryLayout<BlinnPhongBaseMaterial>.size)
        }
    }
    
    private let _bufferMaterial: MTLBuffer;
    var bufferMaterial:MTLBuffer {
        get {
            return _bufferMaterial
        }
    }
    
    
    
    init(with device: LithiumDevice, material: BlinnPhongBaseMaterial) {
        
        baseMaterial = material
        
        print("Size of BlinnPhongBaseMaterial: \(MemoryLayout<BlinnPhongBaseMaterial>.size)")
        guard let buffer = device.raw.makeBuffer(bytes: &baseMaterial, length: MemoryLayout<BlinnPhongBaseMaterial>.size, options: []) else {
            fatalError("Could not create buffer")
        }
        
        buffer.label = "BlinnPhongMaterial"
        
        _bufferMaterial = buffer
        
    }
}
