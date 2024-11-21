//
//  MetalView.swift
//  MetalSim
//
//  Created by Gabriel Bernardo on 13/11/24.
//

import MetalKit
import SwiftUI

struct MetalView {
    @State private var _renderer: Lithium = .init()
    @Binding var contrast: Float
    
    private func makeMetalView() -> MTKView {
        let view = MTKView()

        
        view.device = _renderer.lithiumDevice.raw
        view.delegate = _renderer
        return view
    }
    
    private func updateMetalView() {
        if let quad = _renderer.quad {
            quad.setContrast(contrast: contrast)
        }
    }
}


extension MetalView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        makeMetalView()
        
    }
    
    
   
    func updateNSView(_ nsView: NSView, context: Context) {
        updateMetalView()
    }
    
    
}
