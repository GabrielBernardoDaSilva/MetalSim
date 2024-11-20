//
//  MetalView.swift
//  MetalSim
//
//  Created by Gabriel Bernardo on 13/11/24.
//

import MetalKit
import SwiftUI

struct MetalView {
    @State private var renderer: Lithium = .init()
    private func makeMetalView() -> MTKView {
        let view = MTKView()

        
        view.device = renderer.lithiumDevice.raw
        view.delegate = renderer
        return view
    }
}


extension MetalView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        makeMetalView()
        
    }
    
    
   
    func updateNSView(_ nsView: NSView, context: Context) {
        
    }
    
    
}
