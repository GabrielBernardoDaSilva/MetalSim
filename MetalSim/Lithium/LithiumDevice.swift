//
//  LithiumDevice.swift
//  MetalSim
//
//  Created by Gabriel Bernardo on 16/11/24.
//

import MetalKit

class LithiumDevice {
    private let _raw: MTLDevice
    private let _pixelFormat: MTLPixelFormat
    private let _depthFormat: MTLPixelFormat
    
    var raw : MTLDevice {
        get{ return _raw}
    }
    
    var pixelFormat : MTLPixelFormat {
        get{ return _pixelFormat}
    }
    
    var depthFormat : MTLPixelFormat {
        get{ return _depthFormat}
    }
    
    
    
    
    init(_ pixelFormat: MTLPixelFormat, _ depthFormat: MTLPixelFormat){
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Could not create a Metal device.")
        }
        _raw = device
        _pixelFormat = pixelFormat
        _depthFormat = depthFormat
        
    }
}
