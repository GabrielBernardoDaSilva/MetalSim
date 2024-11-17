//
//  LithiumShaderLib.swift
//  MetalSim
//
//  Created by Gabriel Bernardo on 16/11/24.
//

import MetalKit


struct LithiumShaderLib {
    let raw : MTLLibrary
    
    init(with device: inout LithiumDevice, _ path: String){
        
            guard let raw =  device.raw.makeDefaultLibrary() else {
                fatalError("Could not load library at \(path)")
            }
            self.raw = raw
      
    }
    
    
}
