//
//  LithiumCommandQueue.swift
//  MetalSim
//
//  Created by Gabriel Bernardo on 16/11/24.
//
import MetalKit


struct LithiumCommandQueue{
    let raw: MTLCommandQueue
    
    init(in device: inout LithiumDevice){
        guard let commandQueue = device.raw.makeCommandQueue() else {
            fatalError("Could not create a Metal device")
        }
        
        self.raw = commandQueue
        
        
    }
}
