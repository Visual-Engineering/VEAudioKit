//
//  AudioItem.swift
//  VEAudioKit
//
//  Created by Pablo Balduz on 25/07/2019.
//

import AVFoundation

public struct AudioItem {
    let file: AVAudioFile
    let delay: Float
    
    // Duration in seconds (delay included)
    public var duration: Float {
        let lengthSamples = file.length
        let sampleRate = file.processingFormat.sampleRate
        return Float(Double(lengthSamples) / sampleRate) + delay
    }
    
    // Length
    var length: AVAudioFramePosition {
        let delayLength = AVAudioFramePosition(Double(delay) * file.processingFormat.sampleRate)
        return delayLength + file.length
    }
    
    var audioFormat: AVAudioFormat {
        return file.processingFormat
    }
    
    var sampleRate: Float {
        return Float(audioFormat.sampleRate)
    }
    
    init(file: AVAudioFile, delay: Float = 0) {
        self.file = file
        self.delay = delay
    }
}
