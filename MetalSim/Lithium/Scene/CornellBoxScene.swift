//
//  CornellBoxScene.swift
//  MetalSim
//
//  Created by Gabriel Bernardo on 20/11/24.
//

import simd

class CornellBoxScene: LithiumScene {


    
    var renderable: [ LithiumRenderer]
    
    var updatable: [ LithiumUpdateable]
    
    private let _lightCube: Mesh3d
    private var _lightPosition = simd_float3(0.0, 2.0, 0.0)
    
    private let _cornellBox: Mesh3d
    
    private var _perspectiveCamera: PerspectiveCamera
    
    
    required init(with device:  LithiumDevice) {
        let perspectiveCamera = float4x4(perspectiveWithAspect: 1.0, fovy: .π/5, near: 0.1, far: 100.0)
        let view = float4x4(translate: [0, 0, -8])
                
                

     
        
        let cornellBoxMVP = {
            var model = matrix_identity_float4x4
            model = model.scale(simd_float3(repeating: 1.0))
            model = model.translation([0.0, -1.0, -2.0])
                    
            return MVP(m: model, v: view, p: perspectiveCamera)
        }
        
        let position = simd_float3(0.0, 2.0, 0.0)

        let cubeMVP = {
            var model = matrix_identity_float4x4
            model = model.scale(simd_float3(repeating: 0.1))
            model = model.translation(position)
                    
            return MVP(m: model, v: view, p: perspectiveCamera)
        }
        

        
        let shaderEntryPointCornoellBox = ShaderEntryPoint(vertexFunctionName: "vertex_mesh_main", fragmentFunctionName: "fragment_mesh_main")
        let shaderEntryPointCube = ShaderEntryPoint(vertexFunctionName: "vertex_light_main", fragmentFunctionName: "fragment_light_main")
        
        
        
        
        let light = Light(position: position, color: [1, 1, 1])
        let blinnPhongLightModel = BlinnPhongLightModel(with: device, light: light)
        
        let material = BlinnPhongBaseMaterial(diffuseColor: simd_float3(repeating: 0.8), specularColor: simd_float3(repeating: 1.0), shininess: 16)
        let blinnPhongMaterial = BlinnPhongMaterial(with: device, material: material)
        
        let camera = Camera(perspectiveCamera: perspectiveCamera, cameraPosition: simd_float3(0,0, -8), view: view )
        _perspectiveCamera = PerspectiveCamera(with: device, camera: camera)
        
        let cornellBox = Mesh3d(with: device, name: "CornellBox", entry: shaderEntryPointCornoellBox,  mvp: cornellBoxMVP(), material: blinnPhongMaterial, light: blinnPhongLightModel, camera: _perspectiveCamera)
        let cube = Mesh3d(with: device, name: "Cube", entry: shaderEntryPointCube, mvp: cubeMVP())
        
        
        renderable = [ cornellBox, cube ]
        updatable = [ cornellBox, cube ]
        
        _cornellBox = cornellBox
        _lightCube = cube
        
   
    }
    
    
    func update(with time: Float) {
        

        
        _lightPosition.x = sin(time * 10) * 5
        
        var model = matrix_identity_float4x4
        model = model.scale(simd_float3(repeating: 0.1))
        model = model.translation(_lightPosition)
        
        let newMvp = MVP(m: model, v:  _perspectiveCamera.camera.view , p: _perspectiveCamera.camera.perspectiveCamera)
        
        _lightCube.mvp = newMvp
        
        
        // now move in cornell box
        
        _cornellBox.light?.light = Light(position: _lightPosition, color: simd_float3(repeating: 1.0))
        
    }
    
    
    
   
    
}
