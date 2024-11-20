//
//  simd+extensions.swift
//  MetalSim
//
//  Created by Gabriel Bernardo on 16/11/24.
//

import simd

extension matrix_float4x4 {
    func translation(_ translation: vector_float3) -> Self {
        var matrix = matrix_float4x4(diagonal: [1,1,1,1])
        matrix.columns.3 = vector_float4(translation.x, translation.y, translation.z, 1)
        return self * matrix
        
    }
    
    func scale(_ scale: vector_float3) -> Self {
        let matrix = matrix_float4x4(diagonal: [scale.x,scale.y,scale.z,1])
        return self * matrix
    }
    
    
    static func perspectiveMatrix(_ fov: Float, _ aspect: Float, _ near: Float, _ far: Float) -> Self{
        let f = 1.0 / tan(fov * 0.5)
        let nf = 1.0 / (near - far)
        
        let matrix = matrix_float4x4(columns:
            ([f / aspect, 0,0,0],
            [0, f, 0, 0],
            [0, 0, (near + far) * nf, -1],
            [0, 0, (2.0 * near * far) * nf, 0])
        )
        
        return matrix
    }
    
    static func lookAt(_ eye: simd_float3, _ center: simd_float3, _ up: simd_float3) -> Self {
        let forward = simd_normalize(center - eye)
        let right = simd_normalize(simd_cross(up, forward))
        let cameraUp = simd_cross(forward, right)
        
        let rotation = simd_float4x4(columns: (
            simd_float4(right, 0),
            simd_float4(cameraUp, 0),
            simd_float4(-forward, 0),
            simd_float4(0, 0, 0, 1)
        ))
        
        let translation = simd_float4(-simd_dot(right, eye), -simd_dot(cameraUp, eye), -simd_dot(forward, eye), 0);
        
        
        return rotation * simd_float4x4(
                simd_float4(1, 0, 0, 0),
                simd_float4(0, 1, 0, 0),
                simd_float4(0, 0, 1, 0),
                translation
            )
    }
}




extension Double {
  /// Number of radians in *one turn*.
  @_transparent public static var τ: Double { Double.pi * 2 }
  /// Number of radians in *half a turn*.
  @_transparent public static var π: Double { Double.pi }
}

extension Float {
  /// Number of radians in *one turn*.
  @_transparent public static var τ: Float { Float(Double.τ) }
  /// Number of radians in *half a turn*.
  @_transparent public static var π: Float { Float(Double.π) }
}

extension SIMD4 {
  var xy: SIMD2<Scalar> {
    SIMD2([self.x, self.y])
  }

  var xyz: SIMD3<Scalar> {
    SIMD3([self.x, self.y, self.z])
  }
}

extension float4x4 {
  /// Creates a 4x4 matrix representing a translation given by the provided vector.
  /// - parameter vector: Vector giving the direction and magnitude of the translation.
  init(translate vector: SIMD3<Float>) {
    self.init(
      [1, 0, 0, 0],
      [0, 1, 0, 0],
      [0, 0, 1, 0],
      [vector.x, vector.y, vector.z, 1]
    )
  }

  /// Creates a 4x4 matrix representing a uniform scale given by the provided scalar.
  /// - parameter s: Scalar giving the uniform magnitude of the scale.
  init(scale s: Float) {
    self.init(diagonal: [s, s, s, 1])
  }

  /// Creates a 4x4 matrix that will rotate through the given vector and given angle.
  /// - parameter angle: The amount of radians to rotate from the given vector center.
  init(rotate axis: SIMD3<Float>, angle: Float) {
    let x = axis.x, y = axis.y, z = axis.z
    let c: Float = cos(angle)
    let s: Float = sin(angle)
    let t = 1 - c

    let x0 = t * x * x + c
    let x1 = t * x * y + z * s
    let x2 = t * x * z - y * s

    let y0 = t * x * y - z * s
    let y1 = t * y * y + c
    let y2 = t * y * z + x * s

    let z0 = t * x * z + y * s
    let z1 = t * y * z - x * s
    let z2 = t * z * z + c

    self.init(
      [x0, x1, x2, 0],
      [y0, y1, y2, 0],
      [z0, z1, z2, 0],
      [ 0,  0,  0, 1]
    )
  }

  /// Creates a perspective matrix from an aspect ratio, field of view, and near/far Z planes.
  init(perspectiveWithAspect aspect: Float, fovy: Float, near: Float, far: Float) {
    let yy = 1 / tan(fovy * 0.5)
    let xx = yy / aspect
    let zRange = far - near
    let zz = -(far + near) / zRange
    let ww = -2 * far * near / zRange

    self.init(
      [xx,  0,  0,  0],
      [ 0, yy,  0,  0],
      [ 0,  0, zz, -1],
      [ 0,  0, ww,  0]
    )
  }
}
