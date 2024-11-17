//
//  ContentView.swift
//  MetalSim
//
//  Created by Gabriel Bernardo on 13/11/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.blue
            MetalView()
                .aspectRatio(1,contentMode: .fill)
        }
        
    }
}

#Preview {
    ContentView()
}
