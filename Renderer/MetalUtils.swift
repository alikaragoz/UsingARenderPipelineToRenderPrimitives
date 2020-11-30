//
//  MetalUtils.swift
//  HelloTriangle
//
//  Created by Ali Karagoz on 30/11/2020.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import Metal
import MetalKit
import CoreMedia
import os.signpost

let conversionLog = OSLog(subsystem: "com.archery.mojo", category: "MTLTexture to CVPixelBuffer")

class MetalUtils: NSObject {
    @objc func mtlTextureToPixelBuffer(_ texture: MTLTexture) -> CVPixelBuffer? {
        var pixelBuffer_: CVPixelBuffer?

        CVPixelBufferCreate(
            kCFAllocatorDefault,
            texture.width,
            texture.height,
            kCVPixelFormatType_32BGRA,
            nil,
            &pixelBuffer_)

        guard let pixelBuffer = pixelBuffer_ else { return nil }

        // Lock the pixelbuffer for writing
        CVPixelBufferLockBaseAddress(pixelBuffer, [])

        let region = MTLRegionMake2D(0, 0, texture.width, texture.height)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)

        // Copy the while texture to the baseAddress
        os_signpost(.begin, log: conversionLog, name: "getBytes")
        texture.getBytes(baseAddress!, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
        os_signpost(.end, log: conversionLog, name: "getBytes")

        // And unlock said pixel buffer
        CVPixelBufferUnlockBaseAddress(pixelBuffer, [])

        return pixelBuffer
    }
}
