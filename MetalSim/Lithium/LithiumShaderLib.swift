//
//  LithiumShaderLib.swift
//  MetalSim
//
//  Created by Gabriel Bernardo on 16/11/24.
//

import MetalKit


struct LithiumShaderLib {
    let raw : MTLLibrary
    
    init(with device: inout LithiumDevice, _ url: URL){
        do {
            let raw = try device.raw.makeLibrary(URL: url)
            self.raw = raw
        } catch let error {
            fatalError("Could not load library at \(url): \(error)")
        }
    }
    
    
}
