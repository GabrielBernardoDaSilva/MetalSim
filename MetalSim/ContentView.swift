//
//  ContentView.swift
//  MetalSim
//
//  Created by Gabriel Bernardo on 13/11/24.
//

import SwiftUI

struct ContentView: View {
    @State private var contrast: Float = 0.5
    
    
    
    var body: some View {
        ZStack {
            Color.blue
            MetalView(contrast: $contrast)
                .aspectRatio(1,contentMode: .fill)
            VStack {

                Slider(
                    value: $contrast,
                    in: 0...1,
                    label: { Text("Contrast") }
                )
                .padding(.horizontal, 40)
                .frame(maxWidth: 300)
                .cornerRadius(8)
                .padding(.bottom, 20)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 100)
           
        }
        
    }
}

#Preview {
    ContentView()
}
