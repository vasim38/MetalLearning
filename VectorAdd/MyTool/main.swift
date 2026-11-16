import Foundation
import Metal

//Get the Apple GPU

guard let device = MTLCreateSystemDefaultDevice() else {
    fatalError("Metal is not supported !")
}

print("Using GPU: \(device.name)")

// Create command queue
let commandQueue = device.makeCommandQueue();

// Input arrays

let count = 5

let A: [Float] = [1, 2, 3, 4, 5]
let B: [Float] = [10, 20, 30, 40, 50]

let size = count * MemoryLayout<Float>.stride

//Allocate GPU Buffers

let bufferA = device.makeBuffer(bytes: A, length: size, options: .storageModeShared)!

let bufferB = device.makeBuffer(bytes: B, length: size, options: .storageModeShared)!

let bufferC = device.makeBuffer(length: size, options: .storageModeShared)!


// Load the compiled Metal Shader

let library = device.makeDefaultLibrary()
let function = library?.makeFunction(name: "vector_add")!

let pipeline = try! device.makeComputePipelineState(function: function!)

// Create command buffer
let commandBuffer = commandQueue?.makeCommandBuffer()!
let encoder = commandBuffer?.makeComputeCommandEncoder()!

// Configure GPU
encoder?.setComputePipelineState(pipeline)

encoder?.setBuffer(bufferA, offset: 0, index: 0)
encoder?.setBuffer(bufferB, offset: 0, index: 1)
encoder?.setBuffer(bufferC, offset: 0, index: 2)

// Dispatch five GPU threads
let threads = MTLSize(width: count, height: 1, depth: 1)
let group = MTLSize(width: 1, height: 1, depth: 1)

encoder?.dispatchThreads(threads, threadsPerThreadgroup: MTLSize(width: 5, height: 1, depth: 1))

encoder?.endEncoding()

// Execute GPU work
commandBuffer?.commit()
commandBuffer?.waitUntilCompleted()

// Read Results
let result = bufferC.contents().bindMemory(to: Float.self, capacity: count)

for i in 0..<count  {
    print("\(A[i]) + \(B[i]) = \(result[i])")
}
