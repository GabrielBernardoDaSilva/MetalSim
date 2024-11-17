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
        
        view.clearColor = MTLClearColor(red: 0.0, green: 0.0,blue: 0.0,alpha: 1.0)
        
        view.device = renderer.device
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
