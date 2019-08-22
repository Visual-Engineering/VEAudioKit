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
    public var duration: Float
    
    // Length in samples (delay included)
    var length: AVAudioFramePosition
    
    var audioFormat: AVAudioFormat
    
    var sampleRate: Float
    
    init(file: AVAudioFile, delay: Float = 0) {
        self.file = file
        self.delay = delay
        self.length = AVAudioFramePosition(Double(delay) * file.processingFormat.sampleRate) + file.length
        self.audioFormat = file.processingFormat
        self.sampleRate = Float(audioFormat.sampleRate)
        self.duration = Float(length) / sampleRate
    }
}
