//
//  VideoUtil.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import AVFoundation
import MobileCoreServices

struct VideoUtil {
    
    static func cropVideo(url: URL, destURL: URL, compressed: Bool, size: CGSize, completionHandler: @escaping NZEmptyBlock) {
        let asset = AVAsset(url: url)
        
        let videoTrack = asset.tracks(withMediaType: .video).first!
        
        let t = videoTrack.preferredTransform
        var degrees: CGFloat = 0
        if t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0 {
            // Portrait
            degrees = 90
        } else if t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0{
            // PortraitUpsideDown
            degrees = 270
        } else if t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0 {
            // LandscapeRight
            degrees = 0
        } else if t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0 {
            // LandscapeLeft
            degrees = 180
        }
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        
        var transform: CGAffineTransform = .identity
        
        if degrees == 90 {
            let width = videoTrack.naturalSize.height
            let p = size.height / size.width
            let height = width * p
            let y = (videoTrack.naturalSize.width - height) * 0.5
            transform = transform.translatedBy(x: width, y: -y)
            transform = transform.rotated(by: .pi / 2)
            videoComposition.renderSize = CGSize(width: width, height: height)
        } else if degrees == 180 {
            let width = videoTrack.naturalSize.width
            let p = size.height / size.width
            let height = width * p
            let y = (videoTrack.naturalSize.height - height) * 0.5
            transform = transform.translatedBy(x: width, y: -y)
            transform = transform.rotated(by: .pi)
            videoComposition.renderSize = CGSize(width: width, height: height)
        } else if degrees == 270 {
            let width = videoTrack.naturalSize.height
            let p = size.height / size.width
            let height = width * p
            let y = (videoTrack.naturalSize.width - height) * 0.5
            transform = transform.translatedBy(x: -y, y: width)
            transform = transform.rotated(by: .pi / 2 * 3)
            videoComposition.renderSize = CGSize(width: width, height: height)
        }
        
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        transformer.setTransform(transform, at: .zero)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        instruction.layerInstructions = [transformer]
        
        videoComposition.instructions = [instruction]
        
        let presetName = compressed ? AVAssetExportPresetMediumQuality : AVAssetExportPresetHighestQuality
        let exporter = AVAssetExportSession(asset: asset, presetName: presetName)
        exporter?.videoComposition = videoComposition
        exporter?.outputURL = destURL
        exporter?.outputFileType = .mp4
        exporter?.exportAsynchronously {
            completionHandler()
        }
    }
    
    static func videoPosterImage(url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        do {
            let cgImage = try generator.copyCGImage(at: .zero, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("\(error)")
        }
        return nil
    }
    
}

extension VideoUtil {
    
    static func angleOffsetFromPortraitOrientation(to orientation: AVCaptureVideoOrientation) -> CGFloat {
        var angle: CGFloat = 0.0
        switch orientation {
        case .portrait:
            angle = 0.0
        case .portraitUpsideDown:
            angle = .pi
        case .landscapeRight:
            angle = -(CGFloat.pi / 2)
        case .landscapeLeft:
            angle = .pi / 2
        @unknown default:
            break
        }
        return angle
    }
    
    static func transformFromVideoBufferOrientation(to orientation: AVCaptureVideoOrientation,
                                                    videoOrientation: AVCaptureVideoOrientation,
                                                    videoPosition: AVCaptureDevice.Position,
                                                    autoMirroring: Bool) -> CGAffineTransform {
        var transform: CGAffineTransform = .identity
        
        let orientationAngleOffset = angleOffsetFromPortraitOrientation(to: orientation)
        let videoOrientationAngleOffset = angleOffsetFromPortraitOrientation(to: videoOrientation)
        let angleOffset = orientationAngleOffset - videoOrientationAngleOffset
        transform = transform.rotated(by: angleOffset)
        
        if videoPosition == .front {
            if autoMirroring {
                transform = transform.scaledBy(x: -1, y: 1)
            } else {
                if UIInterfaceOrientation(rawValue: orientation.rawValue)!.isPortrait {
                    transform = transform.rotated(by: .pi)
                }
            }
        }
        
        return transform
    }
    
    static func transform(with devicePosition: AVCaptureDevice.Position) -> CGAffineTransform {
        let currentInterfaceOrientation = UIApplication.shared.statusBarOrientation
        let originalVideoPrientation: AVCaptureVideoOrientation = devicePosition == .front ? .landscapeLeft : .landscapeRight
        let transform = VideoUtil.transformFromVideoBufferOrientation(to: AVCaptureVideoOrientation(rawValue: currentInterfaceOrientation.rawValue)!, videoOrientation: originalVideoPrientation, videoPosition: devicePosition, autoMirroring: true)
        return transform
    }
    
}

extension VideoUtil {
    
    static func data(with pixelBuffer: CVPixelBuffer, attachments: CFDictionary?, imageType: CFString) -> Data? {
        let ciContext = CIContext()
        let renderedCIImage = CIImage(cvImageBuffer: pixelBuffer)
        guard let renderedCGImage = ciContext.createCGImage(renderedCIImage, from: renderedCIImage.extent) else {
            NZLogger.error("CVPixelBuffer render to image failed")
            return nil
        }
        
        guard let data = CFDataCreateMutable(kCFAllocatorDefault, 0) else {
            NZLogger.error("CFDataCreateMutable failed")
            return nil
        }
        
        guard let cgImageDestination = CGImageDestinationCreateWithData(data, imageType , 1, nil) else {
            NZLogger.error("Create CGImageDestination error")
            return nil
        }
        
        CGImageDestinationAddImage(cgImageDestination, renderedCGImage, attachments)
        if CGImageDestinationFinalize(cgImageDestination) {
            return data as Data
        }
        NZLogger.error("Finalizing CGImageDestination error")
        return nil
    }
}
