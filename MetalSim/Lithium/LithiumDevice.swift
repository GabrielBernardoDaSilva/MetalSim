//
//  LithiumDevice.swift
//  MetalSim
//
//  Created by Gabriel Bernardo on 16/11/24.
//

import MetalKit

struct LithiumDevice{
    let raw: MTLDevice
    
    init(){
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Could not create a Metal device.")
        }
        self.raw = device
    }
}
