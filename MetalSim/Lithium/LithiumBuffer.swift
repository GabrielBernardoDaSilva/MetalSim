//
//  LithiumBuffer.swift
//  MetalSim
//
//  Created by Gabriel Bernardo on 16/11/24.
//

import MetalKit

struct LithiumBuffer<T>{
    let raw: MTLBuffer
    
    init (with device: inout LithiumDevice, content data: [T]){
        raw = withUnsafePointer(to: data){ ptr in
            guard let buffer = device.raw.makeBuffer(bytes: ptr, length: data.count * MemoryLayout<T>.stride, options: []) else {
                fatalError("Could not create buffer")
            }
            return buffer
        }
    }
}
