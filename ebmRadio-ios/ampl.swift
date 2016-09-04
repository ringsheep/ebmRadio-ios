//
//  ampl.swift
//  ebmRadio-ios
//
//  Created by George Zinyakov on 8/21/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import Foundation
import AVFoundation

class ampl {
    
    class func sliceAsset(asset: AVAsset?) {
        guard let asset = asset else {
            print("no asset")
            return
        }
        guard let assetTrack = asset.tracks.first else {
            print("no tracks")
            return
        }
        guard let reader = try? AVAssetReader(asset: asset) else {
            print("no reader")
            return
        }
        let outputSettingsDict: [String : AnyObject] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsNonInterleaved: false
        ]
        let readerOutput = AVAssetReaderTrackOutput(track: assetTrack, outputSettings: outputSettingsDict)
        readerOutput.alwaysCopiesSampleData = false
        reader.addOutput(readerOutput)
        
        // 16-bit samples
        reader.startReading()
        
        while reader.status == .Reading {
            guard let readSampleBuffer = readerOutput.copyNextSampleBuffer() else {
                break
            }
            guard let readBuffer = CMSampleBufferGetDataBuffer(readSampleBuffer) else {
                break
            }
            let readBufferLength = CMBlockBufferGetDataLength(readBuffer)
            
            let data = NSMutableData(length: readBufferLength)
            CMBlockBufferCopyDataBytes(readBuffer, 0, readBufferLength, data!.mutableBytes)
            CMSampleBufferInvalidate(readSampleBuffer)
            let sampleCount = readBufferLength / sizeof(Int16)
            let samples = UnsafeMutablePointer<Int16>(data!.mutableBytes)
            let rawData = samples[0]
            print(rawData)
        }
    }

    private func decibel(amplitude: CGFloat) -> CGFloat {
        return 20.0 * log10(abs(amplitude))
    }
    
}