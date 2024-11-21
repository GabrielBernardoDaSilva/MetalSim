//
//  meshed.swift
//  MetalSim
//
//  Created by Gabriel Bernardo on 17/11/24.
//
import MetalKit
import simd

struct MeshObj{
    var position: SIMD3<Float>
    var normalDir: SIMD3<Float>
    
    init(position: simd_float3, normal: simd_float3, textureCoordinate: simd_float3){
        self.position = position
        self.normalDir = normal
    }
    
    
    static func meshDescription() -> MTLVertexDescriptor{
        let descriptor = MTLVertexDescriptor()
        
        descriptor.attributes[0].format = .float3
        descriptor.attributes[0].bufferIndex = 0
        descriptor.attributes[0].offset = 0
        
        
        descriptor.attributes[1].format = .float3
        descriptor.attributes[1].bufferIndex = 0
        descriptor.attributes[1].offset = MemoryLayout<Self>.offset(of: \.normalDir)!
        
        
        descriptor.layouts[0].stride = MemoryLayout<MeshObj>.stride
        
        
        return descriptor
        
  
    }
}

struct Uniform{
    var time: Float
}


struct MVP {
    var model: simd_float4x4
    var view: simd_float4x4
    var projection: simd_float4x4
    
    init (
        m : simd_float4x4,
        v : simd_float4x4,
        p : simd_float4x4
    ) {
        model = m
        view = v
        projection = p
    }
}


struct ShaderEntryPoint{
    var vertexFunctionName: String
    var fragmentFunctionName: String
}


class Mesh3d{
    
    
    let mdlMesh: [Any]
    let library: MTLLibrary
    let pipelineState: MTLRenderPipelineState
    
    var mvp: MVP {
        didSet {
            let bufferPtr = _mvpBuffer.contents()
            memcpy(bufferPtr, &mvp, MemoryLayout<MVP>.size)
        }
    }
 
    private let _uniformBuffer: MTLBuffer
    private let _mvpBuffer: MTLBuffer
    private let _camera : PerspectiveCamera?
    
    let material: BlinnPhongMaterial?
    let light: BlinnPhongLightModel?
        
    
    
    
    convenience init(with device: LithiumDevice, name objName: String, entry shaderEntryPoint: ShaderEntryPoint,  mvp: MVP){
        self.init(with: device, name: objName, entry: shaderEntryPoint, mvp: mvp, material: nil, light: nil, camera: nil)
    }
    
    init(with device: LithiumDevice, name objName: String, entry shaderEntryPoint: ShaderEntryPoint,  mvp: MVP, material: BlinnPhongMaterial?, light: BlinnPhongLightModel?, camera: PerspectiveCamera?){
        guard let url = Bundle.main.url(forResource: objName, withExtension: ".obj") else {
            fatalError("Couldn't find mesh file")
        }
        
        let vertexDescriptor = MeshObj.meshDescription()
        let modelVertexDescription = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
        
        let attrPosition = modelVertexDescription.attributes[0] as! MDLVertexAttribute
        attrPosition.name = MDLVertexAttributePosition
        modelVertexDescription.attributes[0] = attrPosition
        
        let attrNormal = modelVertexDescription.attributes[1] as! MDLVertexAttribute
        attrNormal.name = MDLVertexAttributeNormal
        modelVertexDescription.attributes[1] = attrNormal
        
        
        
        
        
        
        let bufferAllocator = MTKMeshBufferAllocator(device: device.raw)
        let assets = MDLAsset(url: url, vertexDescriptor: modelVertexDescription, bufferAllocator: bufferAllocator)
        
        
        guard let res = try? MTKMesh.newMeshes(asset: assets, device: device.raw) else {
            fatalError("Couldn't load mesh")
        }
        self.mdlMesh = res.metalKitMeshes
        
        let opts = MTLCompileOptions()
        opts.libraryType = .dynamic
        opts.installName = "mesh_shader"
        
        guard let library = device.raw.makeDefaultLibrary() else {
            fatalError("Couldn't load default library")
        }
        
        self.library = library
        
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = library.makeFunction(name: shaderEntryPoint.vertexFunctionName)
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: shaderEntryPoint.fragmentFunctionName)
        pipelineDescriptor.vertexDescriptor = MeshObj.meshDescription()
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        
        guard let pipelineState = try? device.raw.makeRenderPipelineState(descriptor: pipelineDescriptor) else {
            fatalError("Couldn't make render pipeline state")
        }
        self.pipelineState = pipelineState
        
        self.mvp = mvp
        
        
        guard let uniformBuffer = device.raw.makeBuffer(length: MemoryLayout<Uniform>.stride, options: [.cpuCacheModeWriteCombined]) else{
            fatalError("Couldn't allocate uniform buffer")
        }
        let bufferPtr = uniformBuffer.contents()
        
        var uniform = Uniform(time: 0.0)
        memcpy(bufferPtr, &uniform, MemoryLayout<Uniform>.size)
            
        _uniformBuffer = uniformBuffer
        
        
        let mvpSize = MemoryLayout<MVP>.size
        
        guard let mvpBuffer = device.raw.makeBuffer(length: mvpSize, options: [.cpuCacheModeWriteCombined]) else{
            fatalError("Couldn't allocate mvp buffer")
        }
        
        let mvpPtr = mvpBuffer.contents()
        memcpy(mvpPtr, &self.mvp, mvpSize)
        _mvpBuffer = mvpBuffer
        
        self.light = light
        self.material = material
        _camera = camera

        
    }
    
    
    
    
}



extension Mesh3d: LithiumRenderer{
    func render(in enconder: MTLRenderCommandEncoder) {
        guard let meshes = self.mdlMesh as? [MTKMesh] else {
            fatalError("Mesh3d is not a MTKMesh")
        }
        enconder.setCullMode(.none)
        enconder.setFrontFacing(.clockwise)
        enconder.setRenderPipelineState(pipelineState)
        for mesh in meshes{
            for vertexBuffer in mesh.vertexBuffers{
                enconder.setVertexBuffer(vertexBuffer.buffer, offset: vertexBuffer.offset, index: 0)
                enconder.setVertexBuffer(_mvpBuffer, offset: 0, index: 1)
                for submesh in mesh.submeshes{
                    enconder.setFragmentBuffer(_uniformBuffer, offset: 0, index: 0)
                    // send light and material buffer if it has
                    if let light = self.light{
                        enconder.setFragmentBuffer(light.lightBuffer, offset: 0, index: 1)
                    }
                    
                    if let material = self.material{
                        enconder.setFragmentBuffer(material.bufferMaterial, offset: 0, index: 2)
                    }
                    
                    if let camera = self._camera{
                        enconder.setFragmentBuffer(camera.cameraBuffer, offset: 0, index: 3)
                    }
                    
                    enconder.drawIndexedPrimitives(type: submesh.primitiveType,
                                                   indexCount: submesh.indexCount,
                                                   indexType: submesh.indexType,
                                                   indexBuffer: submesh.indexBuffer.buffer,
                                                   indexBufferOffset: submesh.indexBuffer.offset)
                }
            }
        }
        
        enconder.setCullMode(.front)
    }
    
    
}



extension Mesh3d: LithiumUpdateable{
    func update(with time: Float) {
        var uniform = Uniform(time: time)
        let bufferPtr = _uniformBuffer.contents()
        memcpy(bufferPtr, &uniform, MemoryLayout<Uniform>.size)
        
    }
    
    
}
