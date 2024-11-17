//
//  simd+extensions.swift
//  MetalSim
//
//  Created by Gabriel Bernardo on 16/11/24.
//

import simd

extension matrix_float4x4 {
    func translation(_ translation: vector_float3) -> matrix_float4x4 {
        var matrix = matrix_float4x4(diagonal: [1,1,1,1])
        matrix.columns.3 = vector_float4(translation.x, translation.y, translation.z, 1)
        return self * matrix
        
    }
    
    func scale(_ scale: vector_float3) -> matrix_float4x4 {
        let matrix = matrix_float4x4(diagonal: [scale.x,scale.y,scale.z,1])
        return self * matrix
    }
}
