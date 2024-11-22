//
//  ShadowMap.swift
//  MetalSim
//
//  Created by Gabriel Bernardo on 21/11/24.
//


import simd
import MetalKit

func createOrthographicProjection(_ l: Float, _ r: Float, _ bottom: Float, _ top: Float, _ zNear: Float, _ zFar: Float) -> simd_float4x4 {
    var matrix = matrix_identity_float4x4
    matrix[0][0] = 2.0 / (r - l)
    matrix[1][1] = 2.0 / (top - bottom)
    matrix[2][2] = 1.0 / (zFar - zNear)
    matrix[3][0] = -(r + l) / (r - l)
    matrix[3][1] = -(top + bottom) / (top - bottom)
    matrix[3][2] = -zNear / (zFar - zNear)
    
    return matrix;
}

func createViewMatrix(eyePosition: simd_float3, targetPosition: simd_float3, upVec: simd_float3) -> simd_float4x4 {
    let forward = normalize(targetPosition - eyePosition)
    let rightVec = normalize(simd_cross(upVec, forward))
    let up = simd_cross(forward, rightVec)
    
    var matrix = matrix_identity_float4x4;
    matrix[0][0] = rightVec.x;
    matrix[1][0] = rightVec.y;
    matrix[2][0] = rightVec.z;
    matrix[0][1] = up.x;
    matrix[1][1] = up.y;
    matrix[2][1] = up.z;
    matrix[0][2] = forward.x;
    matrix[1][2] = forward.y;
    matrix[2][2] = forward.z;
    matrix[3][0] = -dot(rightVec, eyePosition);
    matrix[3][1] = -dot(up, eyePosition);
    matrix[3][2] = -dot(forward, eyePosition);
    
    return matrix;
}

class ShadowMap {
    private let _shadowMap: MTLTexture
    private let _renderPipeline: MTLRenderPassDescriptor
    private let _shaderLib: MTLLibrary
    private let _pipelineState: MTLRenderPipelineState
    private let _depthState: MTLDepthStencilState
    
    private weak var _mesh3d: Mesh3d?
    
    let lightDirection = simd_float3(0.436436, -0.872872, 0.218218)
    
    
    var shadowMap: MTLTexture{
        get {
            _shadowMap
        }
    }
    
    
    
    init(with device: LithiumDevice, depthState: MTLDepthStencilState, mesh: Mesh3d){
        _depthState = depthState
        _mesh3d = mesh
        guard let lib = device.raw.makeDefaultLibrary() else{
                fatalError("Could not create default library")
        }
        
        _shaderLib = lib
            
        
        
        let shadowMapDescriptor = MTLTextureDescriptor()
        shadowMapDescriptor.pixelFormat = .depth32Float
        shadowMapDescriptor.usage = [.shaderRead, .renderTarget]
        shadowMapDescriptor.width = 2048
        shadowMapDescriptor.height = 2048
        shadowMapDescriptor.storageMode = .private
        
        guard let shadowMapTexture = device.raw.makeTexture(descriptor: shadowMapDescriptor) else{
            fatalError("Could not create shadow map texture")
        }
        
        
        _shadowMap = shadowMapTexture
        
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.depthAttachment.texture = shadowMapTexture
        renderPassDescriptor.depthAttachment.loadAction = .clear
        renderPassDescriptor.depthAttachment.storeAction = .store
        renderPassDescriptor.depthAttachment.clearDepth = 1.0

        
        
        _renderPipeline = renderPassDescriptor
        
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = lib.makeFunction(name: "shadowVertexFunction")
        pipelineDescriptor.fragmentFunction = lib.makeFunction(name: "shadowFragmentFunction")
        pipelineDescriptor.vertexDescriptor = MeshObj.meshDescription()
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        
        guard let pipelineState = try? device.raw.makeRenderPipelineState(descriptor: pipelineDescriptor) else{
            fatalError("Could not create shadow map pipeline state")
        }
        
        
        _pipelineState = pipelineState
    }
    
    
    func renderShadowPass(commandBuffer: MTLCommandBuffer){
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: _renderPipeline) else{
            fatalError("Could not create render encoder")
        }
        
        renderEncoder.setRenderPipelineState(_pipelineState)
        
        renderEncoder.setDepthStencilState(_depthState)
        
        renderEncoder.setFrontFacing(.clockwise)
        renderEncoder.setCullMode(.back)
        
        let lightProjectionMatrix = createOrthographicProjection(-10.0, 10.0, -10.0, 10.0, -25.0, 25.0)
        let lightViewMatrix = createViewMatrix(eyePosition: -lightDirection, targetPosition: simd_float3(repeating: 0.0), upVec: simd_float3(0.0, 1.0, 0.0))
        
        if let mesh = _mesh3d {
            var mvp = mesh.shadowMvp
            
            mvp.view = lightViewMatrix
            mvp.projection = lightProjectionMatrix
            
            mesh.shadowMvp = mvp
            
            
            mesh.changePipelineState(type: .shadow)
            mesh.render(in: renderEncoder)
            mesh.changePipelineState(type: .render)
        }
        
        renderEncoder.endEncoding()
        
    }
}
